class_name DeepSeekService
extends AIServiceBase

## DeepSeek翻译服务实现
## 使用DeepSeek API进行文本翻译

const API_ENDPOINT = "/v1/chat/completions"

var http_request: HTTPRequest
var api_key: String
var base_url: String
var model: String
var max_tokens: int
var temperature: float

func _init(service_config: Dictionary = {}):
	super(service_config)
	
	api_key = config.get("api_key", "")
	base_url = config.get("base_url", "https://api.deepseek.com/v1")
	model = config.get("model", "deepseek-chat")
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
	
	# 构建请求数据
	var request_data = {
		"model": model,
		"messages": [
			{
				"role": "system",
				"content": prompts.system
			},
			{
				"role": "user",
				"content": prompts.user
			}
		],
		"max_tokens": max_tokens,
		"temperature": temperature,
		"stream": false
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
	
	# 构建请求数据
	var request_data = {
		"model": model,
		"messages": [
			{
				"role": "system",
				"content": prompts.system
			},
			{
				"role": "user",
				"content": prompts.user
			}
		],
		"max_tokens": max_tokens,
		"temperature": temperature,
		"stream": false
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
	
	# 构建请求数据
	var request_data = {
		"model": model,
		"messages": [
			{
				"role": "system",
				"content": prompts.system
			},
			{
				"role": "user",
				"content": prompts.user
			}
		],
		"max_tokens": max_tokens,
		"temperature": temperature,
		"stream": false
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
	
	print("=== DeepSeek连接测试开始 ===")
	print("API密钥: ", api_key.substr(0, 20) + "...")
	print("基础URL: ", base_url)
	print("模型: ", model)
	print("=============================")
	
	# 直接测试DeepSeek API，不进行复杂的服务器连通性测试
	print("开始DeepSeek API快速测试...")
	
	var test_data = {
		"model": model,
		"messages": [
			{
				"role": "user", 
				"content": "hi"
			}
		],
		"max_tokens": 3,
		"stream": false
	}
	
	# 单次快速测试，如果失败就失败
	var response = await _send_request(test_data)
	
	if response.success:
		print("✅ DeepSeek连接测试成功")
		return {"success": true, "error": ""}
	else:
		print("❌ DeepSeek连接测试失败: ", response.error)
		
		# 分析常见错误
		var error_msg = response.get("error", "")
		if "401" in error_msg:
			return {"success": false, "error": "API密钥无效或已过期。请检查密钥是否正确。"}
		elif "402" in error_msg:
			return {"success": false, "error": "账户余额不足。请前往DeepSeek官网充值。"}
		elif "403" in error_msg:
			return {"success": false, "error": "没有权限访问此服务。请检查API密钥权限。"}
		elif "422" in error_msg:
			return {"success": false, "error": "请求参数错误。请检查模型名称和参数设置。"}
		elif "429" in error_msg:
			return {"success": false, "error": "请求过于频繁或达到速率限制。请稍后重试。"}
		elif "404" in error_msg:
			return {"success": false, "error": "模型不存在。请检查模型名称: " + model}
		elif "500" in error_msg:
			return {"success": false, "error": "DeepSeek服务器内部错误。请稍后重试。"}
		elif "503" in error_msg:
			return {"success": false, "error": "DeepSeek服务器繁忙。请稍后重试。"}
		elif "timeout" in error_msg.to_lower():
			return {"success": false, "error": "连接超时。请检查网络连接。"}
		elif "ssl" in error_msg.to_lower() or "certificate" in error_msg.to_lower():
			return {"success": false, "error": "SSL证书验证失败。可能需要更新Godot版本或检查系统时间。"}
		elif "空响应" in error_msg or "响应格式无效" in error_msg:
			return {"success": false, "error": "DeepSeek API已知问题：" + error_msg + "\n这是DeepSeek服务端的已知问题，请稍后重试或联系DeepSeek官方。"}
		else:
			return {"success": false, "error": "连接失败: " + error_msg}
	
	return {"success": false, "error": response.get("error", "未知错误")}

## 测试DeepSeek服务器连通性
func _test_deepseek_server() -> Dictionary:
	# 创建临时节点进行连接测试
	var temp_node = Node.new()
	var http_request = HTTPRequest.new()
	temp_node.add_child(http_request)
	Engine.get_main_loop().current_scene.add_child(temp_node)
	
	var request_completed = false
	var response_data = {}
	
	http_request.request_completed.connect(func(result: int, response_code: int, headers_received: PackedStringArray, body: PackedByteArray):
		request_completed = true
		var body_text = body.get_string_from_utf8()
		print("DeepSeek服务器测试 - 结果码: ", result, ", HTTP状态码: ", response_code)
		print("响应内容预览: ", body_text.substr(0, 200))
		
		if result == HTTPRequest.RESULT_SUCCESS:
			# 特殊处理：DeepSeek API可能返回200但响应体为空的问题
			if response_code == 200:
				if body_text.strip_edges().is_empty():
					print("❌ DeepSeek API返回200但响应体为空（已知问题）")
					response_data = {"success": false, "error": "DeepSeek API返回空响应（状态码200但无内容）"}
				else:
					# 检查是否为有效JSON
					var json = JSON.new()
					if json.parse(body_text) == OK:
						response_data = {"success": true}
					else:
						print("❌ DeepSeek API返回200但JSON格式无效")
						response_data = {"success": false, "error": "响应格式无效：" + body_text.substr(0, 100)}
			else:
				# 401表示能连通服务器但密钥无效，这也算"连通"
				response_data = {"success": true}
		else:
			var error_msg = "无法连接到DeepSeek服务器 (结果码: " + str(result) + ")"
			if result == HTTPRequest.RESULT_CANT_CONNECT:
				error_msg += " - 无法建立连接，请检查网络"
			elif result == HTTPRequest.RESULT_CANT_RESOLVE:
				error_msg += " - DNS解析失败，请检查域名"
			elif result == HTTPRequest.RESULT_CONNECTION_ERROR:
				error_msg += " - 连接错误"
			elif result == HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
				error_msg += " - TLS握手失败，可能是SSL问题"
			elif result == HTTPRequest.RESULT_NO_RESPONSE:
				error_msg += " - 服务器无响应"
			elif result == HTTPRequest.RESULT_REQUEST_FAILED:
				error_msg += " - 请求失败"
			elif result == HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
				error_msg += " - 重定向次数过多"
			
			response_data = {"success": false, "error": error_msg}
	)
	
	# 测试连接到DeepSeek API
	var test_url = base_url + "/v1/models"  # 使用models端点测试连通性
	var headers = ["Authorization: Bearer " + api_key]
	var error = http_request.request(test_url, headers)
	
	if error != OK:
		temp_node.queue_free()
		var error_msg = "无法发起DeepSeek服务器连接测试: " + str(error)
		if error == ERR_INVALID_PARAMETER:
			error_msg += " - 参数无效"
		elif error == ERR_CANT_CONNECT:
			error_msg += " - 无法连接"
		elif error == ERR_CANT_RESOLVE:
			error_msg += " - DNS解析失败"
		return {"success": false, "error": error_msg}
	
	# 等待响应
	var max_wait_time = 10.0
	var wait_time = 0.0
	var delta = 0.1
	
	while not request_completed and wait_time < max_wait_time:
		await Engine.get_main_loop().create_timer(delta).timeout
		wait_time += delta
	
	temp_node.queue_free()
	
	if not request_completed:
		return {"success": false, "error": "DeepSeek服务器连接测试超时"}
	
	return response_data

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
		"Authorization: Bearer " + api_key,
		"User-Agent: Godot-Translation-Tool/1.0"
	]
	
	var url = base_url + API_ENDPOINT
	return await _send_http_request(url, headers, HTTPClient.METHOD_POST, json_string)

## 解析翻译响应
func _parse_translation_response(data: Dictionary) -> Dictionary:
	if not data.has("choices") or data.choices.is_empty():
		return {"success": false, "error": "响应格式错误"}
	
	var choice = data.choices[0]
	if not choice.has("message") or not choice.message.has("content"):
		return {"success": false, "error": "响应内容错误"}
	
	var translated_text = choice.message.content.strip_edges()
	return {"success": true, "translated_text": translated_text}

## 获取服务特定信息
func get_service_info() -> Dictionary:
	return {
		"provider": "DeepSeek",
		"model": model,
		"max_tokens": max_tokens,
		"temperature": temperature,
		"pricing": "高性价比",
		"features": ["支持长文本", "多语言翻译", "专业术语处理"]
	}
