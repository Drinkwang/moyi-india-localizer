extends Node

## 快速DeepSeek API测试
## 跳过复杂的网络测试，直接测试DeepSeek API连接

func _ready():
	print("=== 快速DeepSeek API测试 ===")
	await quick_test_deepseek()

func quick_test_deepseek():
	# 直接从配置文件读取API密钥
	var config_path = "res://resources/configs/api_config.json"
	var file = FileAccess.open(config_path, FileAccess.READ)
	
	if not file:
		print("❌ 无法读取配置文件")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		print("❌ 配置文件格式错误")
		return
	
	var config = json.data
	if not config.has("services") or not config.services.has("deepseek"):
		print("❌ 找不到DeepSeek配置")
		return
	
	var deepseek_config = config.services.deepseek
	var api_key = deepseek_config.get("api_key", "")
	var base_url = deepseek_config.get("base_url", "https://api.deepseek.com")
	var model = deepseek_config.get("model", "deepseek-chat")
	
	if api_key.is_empty():
		print("❌ 未设置DeepSeek API密钥")
		print("请在配置中设置API密钥")
		return
	
	print("🔧 DeepSeek配置信息:")
	print("   API密钥: ", api_key.substr(0, 10), "...")
	print("   基础URL: ", base_url)
	print("   模型: ", model)
	print()
	
	# 直接测试DeepSeek API
	print("🚀 开始测试DeepSeek API...")
	var result = await test_deepseek_api(api_key, base_url, model)
	
	if result.success:
		print("✅ DeepSeek API测试成功！")
		print("响应内容: ", result.get("content", ""))
	else:
		print("❌ DeepSeek API测试失败")
		print("错误信息: ", result.get("error", ""))
		
		# 提供故障排除建议
		print("\n🔧 故障排除建议:")
		var error_msg = result.get("error", "")
		if "401" in error_msg:
			print("- 检查API密钥是否正确")
			print("- 登录DeepSeek官网验证密钥状态")
		elif "402" in error_msg:
			print("- 检查账户余额")
			print("- 前往DeepSeek官网充值")
		elif "空响应" in error_msg:
			print("- 这是DeepSeek API的已知间歇性问题")
			print("- 建议稍后重试")
		elif "超时" in error_msg:
			print("- 检查网络连接")
			print("- 尝试使用VPN（如果在网络受限地区）")
		else:
			print("- 检查网络连接")
			print("- 确认防火墙设置")

func test_deepseek_api(api_key: String, base_url: String, model: String) -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var completed = false
	var result = {}
	
	http_request.request_completed.connect(func(request_result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
		completed = true
		var body_text = body.get_string_from_utf8()
		
		print("📊 请求结果:")
		print("   结果码: ", request_result)
		print("   HTTP状态码: ", response_code)
		print("   响应长度: ", body_text.length())
		print("   响应预览: ", body_text.substr(0, 150))
		
		if request_result == HTTPRequest.RESULT_SUCCESS:
			if response_code == 200:
				if body_text.strip_edges().is_empty():
					result = {"success": false, "error": "DeepSeek API返回200但空响应（已知问题）"}
				else:
					var json = JSON.new()
					if json.parse(body_text) == OK:
						var data = json.data
						if data.has("choices") and not data.choices.is_empty():
							var content = data.choices[0].get("message", {}).get("content", "")
							result = {"success": true, "content": content, "data": data}
						else:
							result = {"success": false, "error": "响应格式不完整"}
					else:
						result = {"success": false, "error": "JSON解析失败"}
			elif response_code == 401:
				result = {"success": false, "error": "401 - API密钥无效"}
			elif response_code == 402:
				result = {"success": false, "error": "402 - 账户余额不足"}
			elif response_code == 429:
				result = {"success": false, "error": "429 - 请求频率限制"}
			else:
				result = {"success": false, "error": "HTTP错误 " + str(response_code)}
		else:
			result = {"success": false, "error": "网络请求失败 " + str(request_result)}
	)
	
	# 构建请求
	var request_data = {
		"model": model,
		"messages": [
			{
				"role": "user",
				"content": "你好，请回复'测试成功'"
			}
		],
		"max_tokens": 10,
		"stream": false
	}
	
	var json_string = JSON.stringify(request_data)
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]
	
	var url = base_url + "/v1/chat/completions"
	print("📤 发送请求到: ", url)
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		http_request.queue_free()
		return {"success": false, "error": "无法发起请求: " + str(error)}
	
	# 等待响应
	var max_wait = 15.0
	var wait_time = 0.0
	var delta = 0.1
	
	while not completed and wait_time < max_wait:
		await Engine.get_main_loop().create_timer(delta).timeout
		wait_time += delta
		
		# 每3秒显示进度
		if int(wait_time) % 3 == 0 and fmod(wait_time, 1.0) < 0.2:
			print("⏳ 等待响应中... ", int(wait_time), "秒")
	
	http_request.queue_free()
	
	if not completed:
		return {"success": false, "error": "请求超时"}
	
	return result 