class_name OpenAIService
extends AIServiceBase

## OpenAI翻译服务实现
## 使用OpenAI API进行文本翻译

const API_ENDPOINT = "/chat/completions"

var http_request: HTTPRequest
var api_key: String
var base_url: String
var model: String
var max_tokens: int
var temperature: float

func _init(service_config: Dictionary = {}):
	super(service_config)
	
	api_key = config.get("api_key", "")
	base_url = config.get("base_url", "https://api.openai.com/v1")
	model = config.get("model", "gpt-3.5-turbo")
	max_tokens = config.get("max_tokens", 2000)
	temperature = config.get("temperature", 0.3)
	
	# 创建HTTP请求节点
	http_request = HTTPRequest.new()

## 翻译文本
func translate(text: String, source_lang: String, target_lang: String) -> Dictionary:
	# 使用默认模板
	return await translate_with_template(text, source_lang, target_lang, "")

## 使用知识库增强翻译文本
func translate_with_knowledge_base(text: String, source_lang: String, target_lang: String, knowledge_base_manager: KnowledgeBaseManager) -> Dictionary:
	return await translate_with_template_and_knowledge_base(text, source_lang, target_lang, "", knowledge_base_manager)

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
		"temperature": temperature
	}
	
	# 发送请求
	var response = await _send_request(request_data)
	
	if response.success:
		return _parse_translation_response(response.data)
	else:
		return {"success": false, "error": response.error}

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
		"temperature": temperature
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
	
	print("=== OpenAI连接测试开始 ===")
	print("API密钥: ", api_key.substr(0, 20) + "...")
	print("基础URL: ", base_url)
	print("模型: ", model)
	print("=============================")
	
	# 直接测试API端点，而不是先测试服务器连通性
	# 发送简单的测试请求
	var test_data = {
		"model": model,
		"messages": [
			{
				"role": "user",
				"content": "Hello"
			}
		],
		"max_tokens": 5,
		"temperature": 0.1
	}
	
	var response = await _send_request(test_data)
	
	if response.success:
		print("✅ OpenAI连接测试成功")
		return {"success": true, "error": ""}
	else:
		print("❌ OpenAI连接测试失败: ", response.error)
		return _analyze_openai_error(response.error)

## 分析OpenAI错误并提供解决建议
func _analyze_openai_error(error_msg: String) -> Dictionary:
	if "401" in error_msg:
		return {"success": false, "error": "API密钥无效或已过期。\n解决方案：\n1. 检查API密钥是否正确\n2. 确认API密钥是否有效\n3. 检查是否有足够的配额"}
	elif "403" in error_msg:
		return {"success": false, "error": "没有权限访问此服务。\n解决方案：\n1. 检查API密钥权限\n2. 确认账户状态是否正常"}
	elif "429" in error_msg:
		return {"success": false, "error": "请求过于频繁或额度不足。\n解决方案：\n1. 稍后重试\n2. 检查API配额\n3. 升级计费方案"}
	elif "404" in error_msg:
		return {"success": false, "error": "模型不存在。\n解决方案：\n1. 检查模型名称: " + model + "\n2. 尝试使用 gpt-4o-mini 或 gpt-3.5-turbo"}
	elif "timeout" in error_msg.to_lower() or "超时" in error_msg:
		return {"success": false, "error": "连接超时。\n可能原因：\n1. 网络连接不稳定\n2. 防火墙阻止HTTPS连接\n3. 在中国大陆可能需要科学上网\n4. OpenAI服务器繁忙\n\n解决方案：\n1. 检查网络连接\n2. 尝试在浏览器访问: " + base_url + "\n3. 如在中国大陆，请使用科学上网工具\n4. 稍后重试"}
	elif "ssl" in error_msg.to_lower() or "certificate" in error_msg.to_lower():
		return {"success": false, "error": "SSL证书验证失败。\n解决方案：\n1. 更新Godot版本\n2. 检查系统时间是否正确\n3. 检查网络环境"}
	elif "can't connect" in error_msg.to_lower() or "无法连接" in error_msg:
		return {"success": false, "error": "无法连接到OpenAI服务器。\n可能原因：\n1. 网络连接问题\n2. DNS解析失败\n3. 防火墙阻止\n4. 在中国大陆访问限制\n\n解决方案：\n1. 检查网络连接\n2. 尝试更换DNS（如8.8.8.8）\n3. 检查防火墙设置\n4. 如在中国大陆，需要科学上网"}
	else:
		return {"success": false, "error": "连接失败: " + error_msg + "\n\n通用解决方案：\n1. 检查API密钥是否正确\n2. 确认网络连接正常\n3. 如在中国大陆，建议使用科学上网\n4. 稍后重试"}

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

## 发送HTTP请求（优化版）
func _send_request(data: Dictionary) -> Dictionary:
	var json_string = JSON.stringify(data)
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key,
		"User-Agent: Godot-OpenAI-Client/1.0"
	]
	
	var url = base_url + API_ENDPOINT
	print("🌐 正在连接: ", url)
	
	# 使用更长的超时时间，特别针对网络环境较差的情况
	return await _send_http_request_with_timeout(url, headers, HTTPClient.METHOD_POST, json_string, 20.0)

## 发送HTTP请求（带超时控制）
func _send_http_request_with_timeout(url: String, headers: PackedStringArray, method: HTTPClient.Method, body: String, timeout_seconds: float = 20.0) -> Dictionary:
	# 创建临时节点
	var temp_node = Node.new()
	var http_request = HTTPRequest.new()
	
	# 设置HTTPRequest的超时时间
	http_request.timeout = timeout_seconds
	
	temp_node.add_child(http_request)
	Engine.get_main_loop().current_scene.add_child(temp_node)
	
	var status = {"completed": false, "data": {}}
	
	http_request.request_completed.connect(func(result: int, response_code: int, headers_received: PackedStringArray, body_received: PackedByteArray):
		print("🔍 HTTP请求完成 - 结果码: ", result, ", HTTP状态码: ", response_code)
		
		var body_text = body_received.get_string_from_utf8()
		
		if result == HTTPRequest.RESULT_SUCCESS:
			if response_code == 200:
				var json = JSON.new()
				if json.parse(body_text) == OK:
					print("✅ 成功解析JSON响应")
					status.data = {"success": true, "data": json.data}
				else:
					print("❌ JSON解析失败: ", body_text.substr(0, 200))
					status.data = {"success": false, "error": "响应格式无效"}
			else:
				var error_msg = "HTTP错误 " + str(response_code)
				if not body_text.is_empty():
					error_msg += ": " + body_text
				print("❌ HTTP错误: ", error_msg)
				status.data = {"success": false, "error": error_msg}
		else:
			var error_msg = _get_detailed_http_error(result)
			print("❌ HTTP请求失败: ", error_msg)
			status.data = {"success": false, "error": error_msg}
		
		status.completed = true
	)
	
	# 发送请求
	var request_error = http_request.request(url, headers, method, body)
	if request_error != OK:
		temp_node.queue_free()
		return {"success": false, "error": "请求发送失败: " + str(request_error)}
	
	# 等待响应
	var wait_time = 0.0
	var delta = 0.1
	
	print("⏳ 等待OpenAI响应，最大等待时间: ", timeout_seconds, "秒")
	
	while not status.completed and wait_time < timeout_seconds:
		await Engine.get_main_loop().create_timer(delta).timeout
		wait_time += delta
		
		# 每5秒显示一次等待进度
		if int(wait_time) % 5 == 0 and fmod(wait_time, 1.0) < 0.2:
			print("⏳ 等待中... ", int(wait_time), "秒")
	
	temp_node.queue_free()
	
	if not status.completed:
		print("❌ 请求超时，等待时间: ", wait_time, "秒")
		return {"success": false, "error": "请求超时（超过" + str(timeout_seconds) + "秒）"}
	
	return status.data

## 获取详细的HTTP错误信息
func _get_detailed_http_error(result: int) -> String:
	match result:
		HTTPRequest.RESULT_CANT_CONNECT:
			return "无法连接到服务器（网络不可达或服务器拒绝连接）"
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "DNS解析失败（无法解析域名）"
		HTTPRequest.RESULT_CONNECTION_ERROR:
			return "连接错误（网络中断或连接被重置）"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "TLS握手失败（SSL/TLS证书问题）"
		HTTPRequest.RESULT_NO_RESPONSE:
			return "服务器无响应（请求已发送但未收到响应）"
		HTTPRequest.RESULT_REQUEST_FAILED:
			return "请求失败（一般性网络错误）"
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			return "重定向次数过多"
		HTTPRequest.RESULT_TIMEOUT:
			return "连接超时"
		_:
			return "未知网络错误（代码: " + str(result) + "）"

## 解析翻译响应
func _parse_translation_response(data: Dictionary) -> Dictionary:
	if not data.has("choices") or data.choices.is_empty():
		return {"success": false, "error": "响应格式错误"}
	
	var choice = data.choices[0]
	if not choice.has("message") or not choice.message.has("content"):
		return {"success": false, "error": "响应内容错误"}
	
	var translated_text = choice.message.content.strip_edges()
	return {"success": true, "translated_text": translated_text}
