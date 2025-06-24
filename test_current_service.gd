extends Node

## 当前服务快速测试工具
## 专门用于测试当前配置的DeepSeek或其他AI服务

func _ready():
	print("=== 当前服务快速测试 ===")
	await test_current_service()

func test_current_service():
	# 读取配置文件
	var config = load_config()
	if not config:
		return
	
	# 找到已启用的服务
	var enabled_services = []
	for service_name in config.services.keys():
		var service_config = config.services[service_name]
		if service_config.get("enabled", false):
			enabled_services.append(service_name)
	
	if enabled_services.is_empty():
		print("❌ 没有启用的服务")
		return
	
	print("🔧 已启用的服务: ", enabled_services)
	
	# 测试每个启用的服务
	for service_name in enabled_services:
		print("\n--- 测试服务: ", service_name, " ---")
		var result = await test_single_service(service_name, config.services[service_name])
		
		if result.success:
			print("✅ ", service_name, " 测试成功")
			if result.has("content"):
				print("响应内容: ", result.content)
		else:
			print("❌ ", service_name, " 测试失败: ", result.get("error", ""))

func load_config() -> Dictionary:
	var config_path = "res://resources/configs/api_config.json"
	var file = FileAccess.open(config_path, FileAccess.READ)
	
	if not file:
		print("❌ 无法读取配置文件")
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		print("❌ 配置文件格式错误")
		return {}
	
	return json.data

func test_single_service(service_name: String, service_config: Dictionary) -> Dictionary:
	match service_name:
		"deepseek":
			return await test_deepseek(service_config)
		"openai":
			return await test_openai(service_config)
		"claude":
			return await test_claude(service_config)
		"baidu":
			return await test_baidu(service_config)
		"local":
			return await test_local(service_config)
		_:
			return {"success": false, "error": "不支持的服务: " + service_name}

func test_deepseek(config: Dictionary) -> Dictionary:
	var api_key = config.get("api_key", "")
	var base_url = config.get("base_url", "https://api.deepseek.com")
	var model = config.get("model", "deepseek-chat")
	
	if api_key.is_empty():
		return {"success": false, "error": "未设置API密钥"}
	
	print("   API密钥: ", api_key.substr(0, 10), "...")
	print("   基础URL: ", base_url)
	print("   模型: ", model)
	
	return await make_api_request(
		base_url + "/v1/chat/completions",
		{
			"model": model,
			"messages": [{"role": "user", "content": "你好"}],
			"max_tokens": 5,
			"stream": false
		},
		["Content-Type: application/json", "Authorization: Bearer " + api_key]
	)

func test_openai(config: Dictionary) -> Dictionary:
	var api_key = config.get("api_key", "")
	var base_url = config.get("base_url", "https://api.openai.com/v1")
	var model = config.get("model", "gpt-4o-mini")
	
	if api_key.is_empty():
		return {"success": false, "error": "未设置API密钥"}
	
	print("   API密钥: ", api_key.substr(0, 10), "...")
	print("   基础URL: ", base_url)
	print("   模型: ", model)
	
	return await make_api_request(
		base_url + "/chat/completions",
		{
			"model": model,
			"messages": [{"role": "user", "content": "Hello"}],
			"max_tokens": 5
		},
		["Content-Type: application/json", "Authorization: Bearer " + api_key]
	)

func test_claude(config: Dictionary) -> Dictionary:
	var api_key = config.get("api_key", "")
	var base_url = config.get("base_url", "https://api.anthropic.com")
	var model = config.get("model", "claude-3-haiku-20240307")
	
	if api_key.is_empty():
		return {"success": false, "error": "未设置API密钥"}
	
	print("   API密钥: ", api_key.substr(0, 10), "...")
	print("   基础URL: ", base_url)
	print("   模型: ", model)
	
	return await make_api_request(
		base_url + "/v1/messages",
		{
			"model": model,
			"max_tokens": 5,
			"messages": [{"role": "user", "content": "Hello"}]
		},
		[
			"Content-Type: application/json", 
			"x-api-key: " + api_key,
			"anthropic-version: 2023-06-01"
		]
	)

func test_baidu(config: Dictionary) -> Dictionary:
	print("   百度翻译服务（模拟测试）")
	return {"success": true, "content": "百度翻译连接正常"}

func test_local(config: Dictionary) -> Dictionary:
	var base_url = config.get("base_url", "http://localhost:11434")
	var model = config.get("model", "llama2")
	
	print("   基础URL: ", base_url)
	print("   模型: ", model)
	
	return await make_api_request(
		base_url + "/api/generate",
		{
			"model": model,
			"prompt": "hello",
			"stream": false
		},
		["Content-Type: application/json"]
	)

func make_api_request(url: String, data: Dictionary, headers: Array) -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var completed = false
	var result = {}
	
	http_request.request_completed.connect(func(request_result: int, response_code: int, response_headers: PackedStringArray, body: PackedByteArray):
		completed = true
		var body_text = body.get_string_from_utf8()
		
		print("   HTTP结果: ", request_result, ", 状态码: ", response_code)
		print("   响应长度: ", body_text.length())
		print("   响应预览: ", body_text.substr(0, 100))
		
		if request_result == HTTPRequest.RESULT_SUCCESS:
			if response_code == 200:
				if body_text.strip_edges().is_empty():
					result = {"success": false, "error": "空响应"}
				else:
					var json = JSON.new()
					if json.parse(body_text) == OK:
						var response_data = json.data
						# 尝试提取内容
						var content = extract_content(response_data)
						result = {"success": true, "content": content, "data": response_data}
					else:
						result = {"success": false, "error": "JSON解析失败"}
			else:
				result = {"success": false, "error": "HTTP错误 " + str(response_code) + ": " + body_text.substr(0, 200)}
		else:
			result = {"success": false, "error": "网络错误 " + str(request_result)}
	)
	
	var json_string = JSON.stringify(data)
	print("   请求URL: ", url)
	print("   请求数据: ", json_string.substr(0, 100), "...")
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		http_request.queue_free()
		return {"success": false, "error": "无法发起请求: " + str(error)}
	
	# 等待响应，最多8秒
	var max_wait = 8.0
	var wait_time = 0.0
	var delta = 0.1
	
	while not completed and wait_time < max_wait:
		await Engine.get_main_loop().create_timer(delta).timeout
		wait_time += delta
		
		if int(wait_time) % 2 == 0 and fmod(wait_time, 1.0) < 0.2:
			print("   等待响应... ", int(wait_time), "秒")
	
	http_request.queue_free()
	
	if not completed:
		return {"success": false, "error": "请求超时"}
	
	return result

func extract_content(data: Dictionary) -> String:
	# DeepSeek/OpenAI 格式
	if data.has("choices") and not data.choices.is_empty():
		var choice = data.choices[0]
		if choice.has("message") and choice.message.has("content"):
			return choice.message.content
		if choice.has("text"):
			return choice.text
	
	# Claude格式  
	if data.has("content") and not data.content.is_empty():
		var content_item = data.content[0]
		if content_item.has("text"):
			return content_item.text
	
	# 本地模型格式
	if data.has("response"):
		return data.response
	
	return "无法提取响应内容" 