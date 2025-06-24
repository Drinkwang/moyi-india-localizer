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
	
	# 首先测试基本的OpenAI服务器连通性
	var server_test = await _test_openai_server()
	if not server_test.success:
		return server_test
	
	# 发送简单的测试请求
	var test_data = {
		"model": model,
		"messages": [
			{
				"role": "user",
				"content": "Hi"
			}
		],
		"max_tokens": 5
	}
	
	var response = await _send_request(test_data)
	
	if response.success:
		print("✅ OpenAI连接测试成功")
		return {"success": true, "error": ""}
	else:
		print("❌ OpenAI连接测试失败: ", response.error)
		
		# 分析常见错误
		var error_msg = response.get("error", "")
		if "401" in error_msg:
			return {"success": false, "error": "API密钥无效或已过期。请检查密钥是否正确。"}
		elif "403" in error_msg:
			return {"success": false, "error": "没有权限访问此服务。请检查API密钥权限。"}
		elif "429" in error_msg:
			return {"success": false, "error": "请求过于频繁或额度不足。请稍后重试。"}
		elif "404" in error_msg:
			return {"success": false, "error": "模型不存在。请检查模型名称: " + model}
		elif "timeout" in error_msg.to_lower():
			return {"success": false, "error": "连接超时。请检查网络连接。"}
		else:
			return {"success": false, "error": "连接失败: " + error_msg}
	
	return {"success": false, "error": response.get("error", "未知错误")}

## 测试OpenAI服务器连通性
func _test_openai_server() -> Dictionary:
	# 创建临时节点进行连接测试
	var temp_node = Node.new()
	var http_request = HTTPRequest.new()
	temp_node.add_child(http_request)
	Engine.get_main_loop().current_scene.add_child(temp_node)
	
	var request_completed = false
	var response_data = {}
	
	http_request.request_completed.connect(func(result: int, response_code: int, headers_received: PackedStringArray, body: PackedByteArray):
		request_completed = true
		print("OpenAI服务器测试 - 结果码: ", result, ", HTTP状态码: ", response_code)
		if result == HTTPRequest.RESULT_SUCCESS:
			response_data = {"success": true}
		else:
			var error_msg = "无法连接到OpenAI服务器 (结果码: " + str(result) + ")"
			response_data = {"success": false, "error": error_msg}
	)
	
	# 测试连接到OpenAI API根URL
	var test_url = base_url.replace("/v1", "") if base_url.ends_with("/v1") else base_url
	var headers = ["Authorization: Bearer " + api_key]
	var error = http_request.request(test_url, headers)
	
	if error != OK:
		temp_node.queue_free()
		return {"success": false, "error": "无法发起OpenAI服务器连接测试: " + str(error)}
	
	# 等待响应
	var max_wait_time = 10.0
	var wait_time = 0.0
	var delta = 0.1
	
	while not request_completed and wait_time < max_wait_time:
		await Engine.get_main_loop().create_timer(delta).timeout
		wait_time += delta
	
	temp_node.queue_free()
	
	if not request_completed:
		return {"success": false, "error": "OpenAI服务器连接测试超时"}
	
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
		"Authorization: Bearer " + api_key
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
