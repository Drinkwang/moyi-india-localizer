extends Node

## 独立的DeepSeek连接诊断工具
## 这个脚本可以独立运行来测试DeepSeek API连接

# 请在这里填入您的DeepSeek API密钥
const API_KEY = "YOUR_DEEPSEEK_API_KEY_HERE"
# 如果您有密钥，可以直接填入测试：
# const API_KEY = "sk-xxxxx"
const BASE_URL = "https://api.deepseek.com"
const MODEL = "deepseek-chat"

func _ready():
	print("=== DeepSeek连接诊断开始 ===")
	
	if API_KEY == "YOUR_DEEPSEEK_API_KEY_HERE":
		print("❌ 请在脚本中设置您的DeepSeek API密钥")
		return
	
	await test_connection()

func test_connection():
	print("1. 开始基础网络测试...")
	var network_result = await test_basic_network()
	if not network_result:
		print("❌ 基础网络测试失败，请检查网络连接")
		return
	
	print("2. 开始DeepSeek服务器连通性测试...")
	var server_result = await test_deepseek_server()
	if not server_result:
		print("❌ 无法连接到DeepSeek服务器")
		return
	
	print("3. 开始API密钥有效性测试...")
	var api_result = await test_api_key()
	if api_result:
		print("✅ DeepSeek API连接成功！")
	else:
		print("❌ API密钥验证失败")

## 测试基础网络连接
func test_basic_network() -> bool:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var completed = false
	var success = false
	
	http_request.request_completed.connect(func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
		completed = true
		print("   基础网络测试结果 - 结果码: ", result, ", HTTP状态码: ", response_code)
		success = (result == HTTPRequest.RESULT_SUCCESS and response_code == 200)
	)
	
	# 测试连接到一个简单的网站
	var error = http_request.request("https://httpbin.org/get")
	if error != OK:
		print("   无法发起网络请求: ", error)
		http_request.queue_free()
		return false
	
	# 等待响应
	await wait_for_completion(completed, 10.0)
	http_request.queue_free()
	
	return success

## 测试DeepSeek服务器连通性
func test_deepseek_server() -> bool:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var completed = false
	var success = false
	
	http_request.request_completed.connect(func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
		completed = true
		var body_text = body.get_string_from_utf8()
		print("   DeepSeek服务器测试结果 - 结果码: ", result, ", HTTP状态码: ", response_code)
		print("   响应内容预览: ", body_text.substr(0, 200))
		# DeepSeek服务器应该返回某种响应，即使是错误也表示能连通
		success = (result == HTTPRequest.RESULT_SUCCESS)
	)
	
	# 尝试连接到DeepSeek API - 测试models端点
	var headers = ["Authorization: Bearer invalid_key_for_test"]
	var error = http_request.request(BASE_URL + "/v1/models", headers)
	if error != OK:
		print("   无法发起DeepSeek服务器请求: ", error)
		http_request.queue_free()
		return false
	
	# 等待响应
	await wait_for_completion(completed, 10.0)
	http_request.queue_free()
	
	return success

## 测试API密钥有效性
func test_api_key() -> bool:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var completed = false
	var success = false
	
	http_request.request_completed.connect(func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
		completed = true
		var body_text = body.get_string_from_utf8()
		print("   API密钥测试结果 - 结果码: ", result, ", HTTP状态码: ", response_code)
		print("   完整响应内容: ", body_text)
		
		if result == HTTPRequest.RESULT_SUCCESS:
			if response_code == 200:
				success = true
				print("   ✅ API调用成功！")
			elif response_code == 401:
				print("   ❌ API密钥无效或已过期")
				# 尝试解析错误消息
				var json = JSON.new()
				if json.parse(body_text) == OK:
					var error_data = json.data
					if error_data.has("error"):
						print("   错误详情: ", error_data.error)
			elif response_code == 429:
				print("   ❌ 请求过于频繁或额度不足")
			elif response_code == 403:
				print("   ❌ 权限不足")
			elif response_code == 404:
				print("   ❌ 接口不存在，可能模型名称错误")
			else:
				print("   ❌ HTTP错误: ", response_code)
		else:
			print("   ❌ 网络请求失败: ", result)
			# 提供更详细的错误信息
			if result == HTTPRequest.RESULT_CANT_CONNECT:
				print("   详细: 无法建立连接，请检查网络和防火墙")
			elif result == HTTPRequest.RESULT_CANT_RESOLVE:
				print("   详细: DNS解析失败，请检查域名")
			elif result == HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
				print("   详细: TLS握手失败，可能是SSL问题")
	)
	
	# 发送一个简单的API请求
	var request_data = {
		"model": MODEL,
		"messages": [
			{
				"role": "user",
				"content": "Hello"
			}
		],
		"max_tokens": 5,
		"stream": false
	}
	
	var json_string = JSON.stringify(request_data)
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + API_KEY,
		"User-Agent: Godot-Translation-Tool/1.0"
	]
	
	print("   发送请求到: ", BASE_URL + "/v1/chat/completions")
	print("   请求数据: ", json_string)
	
	var error = http_request.request(BASE_URL + "/v1/chat/completions", headers, HTTPClient.METHOD_POST, json_string)
	if error != OK:
		print("   无法发起API请求: ", error)
		http_request.queue_free()
		return false
	
	# 等待响应
	await wait_for_completion(completed, 15.0)
	http_request.queue_free()
	
	return success

## 等待完成的辅助函数
func wait_for_completion(completed: bool, max_time: float):
	var wait_time = 0.0
	var delta = 0.1
	
	while not completed and wait_time < max_time:
		await Engine.get_main_loop().create_timer(delta).timeout
		wait_time += delta
	
	if wait_time >= max_time:
		print("   ⚠️ 请求超时") 