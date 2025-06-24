extends Node

## DeepSeek API 200响应问题专门诊断工具
## 这个脚本专门用来诊断和解决DeepSeek API返回200但响应异常的问题

# 在这里设置您的DeepSeek API密钥
const API_KEY = "YOUR_DEEPSEEK_API_KEY_HERE"
const BASE_URL = "https://api.deepseek.com"
const MODEL = "deepseek-chat"

func _ready():
	print("=== DeepSeek API 200响应问题诊断开始 ===")
	
	if API_KEY == "YOUR_DEEPSEEK_API_KEY_HERE":
		print("❌ 请在脚本中设置您的DeepSeek API密钥")
		return
	
	await test_deepseek_200_issue()

func test_deepseek_200_issue():
	print("开始多次测试DeepSeek API以诊断200响应问题...")
	
	var successful_calls = 0
	var failed_calls = 0
	var empty_response_calls = 0
	var total_tests = 5
	
	for i in range(total_tests):
		print("\n--- 测试 ", i + 1, "/", total_tests, " ---")
		var result = await make_single_api_call()
		
		if result.success:
			successful_calls += 1
			print("✅ 测试 ", i + 1, " 成功")
		elif "空响应" in result.error:
			empty_response_calls += 1
			failed_calls += 1
			print("❌ 测试 ", i + 1, " 失败: 200状态码但空响应")
		else:
			failed_calls += 1
			print("❌ 测试 ", i + 1, " 失败: ", result.error)
		
		# 在测试之间等待1秒
		if i < total_tests - 1:
			await Engine.get_main_loop().create_timer(1.0).timeout
	
	print("\n=== 测试结果总结 ===")
	print("总测试次数: ", total_tests)
	print("成功次数: ", successful_calls)
	print("失败次数: ", failed_calls)
	print("空响应次数: ", empty_response_calls)
	print("成功率: ", float(successful_calls) / total_tests * 100, "%")
	
	if empty_response_calls > 0:
		print("\n⚠️ 检测到DeepSeek API的200空响应问题")
		print("这是DeepSeek服务端的已知问题，建议：")
		print("1. 使用重试机制")
		print("2. 检查账户余额")
		print("3. 联系DeepSeek官方支持")
	
	if successful_calls > 0:
		print("\n✅ DeepSeek API在某些情况下工作正常")
		print("建议在项目中使用重试机制来处理间歇性问题")

func make_single_api_call() -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var completed = false
	var response_data = {}
	
	http_request.request_completed.connect(func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
		completed = true
		var body_text = body.get_string_from_utf8()
		
		print("   HTTP结果码: ", result)
		print("   HTTP状态码: ", response_code)
		print("   响应长度: ", body_text.length())
		print("   响应内容预览: ", body_text.substr(0, 100))
		
		if result == HTTPRequest.RESULT_SUCCESS:
			if response_code == 200:
				if body_text.strip_edges().is_empty():
					response_data = {"success": false, "error": "DeepSeek API返回200但空响应"}
				else:
					var json = JSON.new()
					if json.parse(body_text) == OK:
						var data = json.data
						if data.has("choices") and not data.choices.is_empty():
							response_data = {"success": true, "data": data}
						else:
							response_data = {"success": false, "error": "响应格式不完整"}
					else:
						response_data = {"success": false, "error": "JSON解析失败: " + json.error_string}
			elif response_code == 401:
				response_data = {"success": false, "error": "API密钥无效"}
			elif response_code == 402:
				response_data = {"success": false, "error": "账户余额不足"}
			elif response_code == 429:
				response_data = {"success": false, "error": "请求频率限制"}
			else:
				response_data = {"success": false, "error": "HTTP错误 " + str(response_code)}
		else:
			response_data = {"success": false, "error": "网络请求失败 " + str(result)}
	)
	
	# 构建请求
	var request_data = {
		"model": MODEL,
		"messages": [
			{
				"role": "user",
				"content": "Hello, please respond with 'Hi'"
			}
		],
		"max_tokens": 10,
		"stream": false
	}
	
	var json_string = JSON.stringify(request_data)
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + API_KEY
	]
	
	var url = BASE_URL + "/v1/chat/completions"
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	
	if error != OK:
		http_request.queue_free()
		return {"success": false, "error": "无法发起请求: " + str(error)}
	
	# 等待响应，最多15秒
	var max_wait = 15.0
	var wait_time = 0.0
	var delta = 0.1
	
	while not completed and wait_time < max_wait:
		await Engine.get_main_loop().create_timer(delta).timeout
		wait_time += delta
	
	http_request.queue_free()
	
	if not completed:
		return {"success": false, "error": "请求超时"}
	
	return response_data 