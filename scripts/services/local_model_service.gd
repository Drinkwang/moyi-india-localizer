class_name LocalModelService
extends AIServiceBase

## 本地模型服务实现
## 支持Ollama、LocalAI等本地大语言模型

const OLLAMA_CHAT_ENDPOINT = "/api/chat"
const OLLAMA_GENERATE_ENDPOINT = "/api/generate"

var http_request: HTTPRequest
var base_url: String
var model: String
var provider: String

func _init(service_config: Dictionary = {}):
	super(service_config)
	
	base_url = config.get("base_url", "http://localhost:11434")
	model = config.get("model", "llama2")
	provider = config.get("provider", "ollama")
	
	# 创建HTTP请求节点
	http_request = HTTPRequest.new()

## 翻译文本
func translate(text: String, source_lang: String, target_lang: String) -> Dictionary:
	if not _validate_config():
		return {"success": false, "error": "配置无效"}
	
	# 构建翻译提示
	var prompt = _build_translation_prompt(text, source_lang, target_lang)
	
	# 根据提供商选择不同的请求格式
	var response = Dictionary()
	match provider.to_lower():
		"ollama":
			response = await _send_ollama_request(prompt)
		"localai":
			response = await _send_localai_request(prompt)
		_:
			response = await _send_ollama_request(prompt)  # 默认使用Ollama格式
	
	if response.success:
		return _parse_translation_response(response.data)
	else:
		return {"success": false, "error": response.error}

## 测试连接
func test_connection() -> Dictionary:
	if not _validate_config():
		return {"success": false, "error": "配置无效: 缺少模型配置"}
	
	# 发送简单的测试请求
	match provider.to_lower():
		"ollama":
			var response = await _send_ollama_request("Hello")
			return {"success": response.success, "error": response.get("error", "")}
		"localai":
			var response = await _send_localai_request("Hello")
			return {"success": response.success, "error": response.get("error", "")}
		_:
			return {"success": false, "error": "不支持的提供商: " + provider}

## 验证配置
func _validate_config() -> bool:
	return not base_url.is_empty() and not model.is_empty()

## 构建翻译提示
func _build_translation_prompt(text: String, source_lang: String, target_lang: String) -> String:
	var source_name = _get_language_name(source_lang)
	var target_name = _get_language_name(target_lang)
	
	return "请将以下%s文本翻译成%s，只返回翻译结果，不要添加额外的解释：\n\n%s" % [source_name, target_name, text]

## 获取语言名称（使用基类的统一配置）
# 此方法已由基类 AIServiceBase 提供，无需重复定义

## 发送Ollama请求
func _send_ollama_request(prompt: String) -> Dictionary:
	var request_data = {
		"model": model,
		"prompt": prompt,
		"stream": false
	}
	
	var json_string = JSON.stringify(request_data)
	var headers = [
		"Content-Type: application/json"
	]
	
	var url = base_url + OLLAMA_GENERATE_ENDPOINT
	return await _send_http_request(url, headers, HTTPClient.METHOD_POST, json_string)

## 发送LocalAI请求
func _send_localai_request(prompt: String) -> Dictionary:
	var request_data = {
		"model": model,
		"messages": [
			{
				"role": "user",
				"content": prompt
			}
		]
	}
	
	var json_string = JSON.stringify(request_data)
	var headers = [
		"Content-Type: application/json"
	]
	
	var url = base_url + "/v1/chat/completions"
	return await _send_http_request(url, headers, HTTPClient.METHOD_POST, json_string)

## 解析翻译响应
func _parse_translation_response(data: Dictionary) -> Dictionary:
	var translated_text = ""
	
	match provider.to_lower():
		"ollama":
			if data.has("response"):
				translated_text = data.response.strip_edges()
			else:
				return {"success": false, "error": "Ollama响应格式错误"}
		
		"localai":
			if data.has("choices") and not data.choices.is_empty():
				var choice = data.choices[0]
				if choice.has("message") and choice.message.has("content"):
					translated_text = choice.message.content.strip_edges()
				else:
					return {"success": false, "error": "LocalAI响应格式错误"}
			else:
				return {"success": false, "error": "LocalAI响应格式错误"}
		
		_:
			return {"success": false, "error": "未知的提供商格式"}
	
	if translated_text.is_empty():
		return {"success": false, "error": "翻译结果为空"}
	
	return {"success": true, "translated_text": translated_text}

## 使用知识库增强翻译文本
func translate_with_knowledge_base(text: String, source_lang: String, target_lang: String, knowledge_base_manager: KnowledgeBaseManager) -> Dictionary:
	return await translate_with_template_and_knowledge_base(text, source_lang, target_lang, "csv_batch", knowledge_base_manager)

## 使用指定模板翻译文本
func translate_with_template(text: String, source_lang: String, target_lang: String, template_name: String = "") -> Dictionary:
	if not _validate_config():
		return {"success": false, "error": "配置无效"}
	
	# 获取专业翻译提示词，传递模板名称
	var prompts = _get_translation_prompt(text, source_lang, target_lang, template_name)
	var full_prompt = prompts.system + "\n\n" + prompts.user
	
	# 根据提供商选择不同的请求格式
	var response = Dictionary()
	match provider.to_lower():
		"ollama":
			response = await _send_ollama_request(full_prompt)
		"localai":
			response = await _send_localai_request(full_prompt)
		_:
			response = await _send_ollama_request(full_prompt)  # 默认使用Ollama格式
	
	if response.success:
		return _parse_translation_response(response.data)
	else:
		return {"success": false, "error": response.error}

## 使用模板和知识库增强翻译文本
func translate_with_template_and_knowledge_base(text: String, source_lang: String, target_lang: String, template_name: String = "", knowledge_base_manager: KnowledgeBaseManager = null) -> Dictionary:
	if not _validate_config():
		return {"success": false, "error": "配置无效"}
	
	# 获取专业翻译提示词，传递模板名称和知识库管理器
	var prompts = _get_translation_prompt(text, source_lang, target_lang, template_name, knowledge_base_manager)
	var full_prompt = prompts.system + "\n\n" + prompts.user
	
	# 根据提供商选择不同的请求格式
	var response = Dictionary()
	match provider.to_lower():
		"ollama":
			response = await _send_ollama_request(full_prompt)
		"localai":
			response = await _send_localai_request(full_prompt)
		_:
			response = await _send_ollama_request(full_prompt)  # 默认使用Ollama格式
	
	if response.success:
		return _parse_translation_response(response.data)
	else:
		return {"success": false, "error": response.error}