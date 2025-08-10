class_name ClaudeService
extends AIServiceBase

## Claude翻译服务实现
## 使用Anthropic Claude API进行文本翻译

const API_ENDPOINT = "/v1/messages"

var http_request: HTTPRequest
var api_key: String
var base_url: String
var model: String
var max_tokens: int
var temperature: float

func _init(service_config: Dictionary = {}):
	super(service_config)
	
	api_key = config.get("api_key", "")
	base_url = config.get("base_url", "https://api.anthropic.com")
	model = config.get("model", "claude-3-haiku-20240307")
	max_tokens = config.get("max_tokens", 2000)
	temperature = config.get("temperature", 0.3)
	
	# 创建HTTP请求节点
	http_request = HTTPRequest.new()

## 翻译文本
func translate(text: String, source_lang: String, target_lang: String) -> Dictionary:
	if not _validate_config():
		return {"success": false, "error": "配置无效"}
	
	# 获取专业翻译提示词
	var prompts = _get_translation_prompt(text, source_lang, target_lang, "csv_batch")
	
	# Claude API将system message合并到user content中
	var full_prompt = prompts.system + "\n\n" + prompts.user
	
	# 构建请求数据
	var request_data = {
		"model": model,
		"max_tokens": max_tokens,
		"temperature": temperature,
		"messages": [
			{
				"role": "user",
				"content": full_prompt
			}
		]
	}
	
	# 发送请求
	var response = await _send_request(request_data)
	
	if response.success:
		return _parse_translation_response(response.data)
	else:
		return {"success": false, "error": response.error}

## 使用知识库增强翻译文本
func translate_with_knowledge_base(text: String, source_lang: String, target_lang: String, knowledge_base_manager: KnowledgeBaseManager) -> Dictionary:
	return await translate_with_template_and_knowledge_base(text, source_lang, target_lang, "csv_batch", knowledge_base_manager)

## 使用指定模板翻译文本
func translate_with_template(text: String, source_lang: String, target_lang: String, template_name: String = "") -> Dictionary:
	if not _validate_config():
		return {"success": false, "error": "配置无效"}
	
	# 获取专业翻译提示词，传递模板名称
	var prompts = _get_translation_prompt(text, source_lang, target_lang, template_name)
	
	# Claude API将system message合并到user content中
	var full_prompt = prompts.system + "\n\n" + prompts.user
	
	# 构建请求数据
	var request_data = {
		"model": model,
		"max_tokens": max_tokens,
		"temperature": temperature,
		"messages": [
			{
				"role": "user",
				"content": full_prompt
			}
		]
	}
	
	# 发送请求
	var response = await _send_request(request_data)
	
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
	
	# Claude API将system message合并到user content中
	var full_prompt = prompts.system + "\n\n" + prompts.user
	
	# 构建请求数据
	var request_data = {
		"model": model,
		"max_tokens": max_tokens,
		"temperature": temperature,
		"messages": [
			{
				"role": "user",
				"content": full_prompt
			}
		]
	}
	
	# 发送请求
	var response = await _send_request(request_data)
	
	if response.success:
		return _parse_translation_response(response.data)
	else:
		return {"success": false, "error": response.error}

## 测试连接
func test_connection() -> Dictionary:
	if not _validate_config():
		return {"success": false, "error": "配置无效: 缺少API密钥"}
	
	# 发送简单的测试请求
	var test_data = {
		"model": model,
		"max_tokens": 10,
		"messages": [
			{
				"role": "user",
				"content": "Hello"
			}
		]
	}
	
	var response = await _send_request(test_data)
	return {"success": response.success, "error": response.get("error", "")}

## 验证配置
func _validate_config() -> bool:
	return not api_key.is_empty() and not base_url.is_empty()

## 构建翻译提示
func _build_translation_prompt(text: String, source_lang: String, target_lang: String) -> String:
	var source_name = _get_language_name(source_lang)
	var target_name = _get_language_name(target_lang)
	
	return "请将以下%s文本翻译成%s，保持原有格式和专业术语：\n\n%s" % [source_name, target_name, text]

## 获取语言名称（使用基类的统一配置）
# 此方法已由基类 AIServiceBase 提供，无需重复定义

## 发送HTTP请求
func _send_request(data: Dictionary) -> Dictionary:
	var json_string = JSON.stringify(data)
	var headers = [
		"Content-Type: application/json",
		"x-api-key: " + api_key,
		"anthropic-version: 2023-06-01"
	]
	
	var url = base_url + API_ENDPOINT
	return await _send_http_request(url, headers, HTTPClient.METHOD_POST, json_string)

## 解析翻译响应
func _parse_translation_response(data: Dictionary) -> Dictionary:
	if not data.has("content") or data.content.is_empty():
		return {"success": false, "error": "响应格式错误"}
	
	var content = data.content[0]
	if not content.has("text"):
		return {"success": false, "error": "响应内容错误"}
	
	var translated_text = content.text.strip_edges()
	return {"success": true, "translated_text": translated_text}
