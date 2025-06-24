class_name AIServiceBase
extends RefCounted

## AI服务基类
## 所有AI翻译服务的基础接口

var config: Dictionary
var display_name: String
var is_enabled: bool = false

func _init(service_config: Dictionary = {}):
	config = service_config
	display_name = config.get("name", "未知服务")
	is_enabled = config.get("enabled", false)

## 翻译文本 - 必须由子类实现
func translate(text: String, source_lang: String, target_lang: String) -> Dictionary:
	push_error("translate方法必须由子类实现")
	return {"success": false, "error": "方法未实现"}

## 测试连接 - 必须由子类实现
func test_connection() -> Dictionary:
	push_error("test_connection方法必须由子类实现")
	return {"success": false, "error": "方法未实现"}

## 检查服务是否可用
func is_available() -> bool:
	return is_enabled and _validate_config()

## 验证配置 - 可由子类重写
func _validate_config() -> bool:
	return not config.is_empty()

## 获取显示名称
func get_display_name() -> String:
	return display_name

## 设置配置
func set_config(new_config: Dictionary):
	config = new_config
	display_name = config.get("name", "未知服务")
	is_enabled = config.get("enabled", false)

## 启用/禁用服务
func set_enabled(enabled: bool):
	is_enabled = enabled

## 获取语言名称（统一从配置文件获取）
func _get_language_name(lang_code: String) -> String:
	var config_manager = ConfigManager.new()
	return config_manager.get_language_name(lang_code)

## 获取专业的翻译提示词
func _get_translation_prompt(text: String, source_lang: String, target_lang: String, template_name: String = "") -> Dictionary:
	var config_manager = ConfigManager.new()
	var translation_config = config_manager.get_translation_config()
	
	# 确定使用的模板
	var template_to_use = template_name
	if template_to_use.is_empty():
		template_to_use = translation_config.get("translation_settings", {}).get("csv_prompt_template", "csv_batch")
	
	# 获取提示词模板
	var templates = translation_config.get("prompt_templates", {})
	var template = templates.get(template_to_use, templates.get("game_translation", {}))
	
	if template.is_empty():
		# 如果没有找到模板，返回默认提示词
		return {
			"system": "你是一个专业的游戏翻译专家。请准确翻译给定的文本，保持原有的格式和专业术语。只返回翻译结果，不要添加额外的解释。",
			"user": "请将以下" + _get_language_name(source_lang) + "文本翻译成" + _get_language_name(target_lang) + "：\n\n" + text
		}
	
	# 构建提示词
	var source_lang_name = _get_language_name(source_lang)
	var target_lang_name = _get_language_name(target_lang)
	
	var system_prompt = template.get("system", "")
	var user_template = template.get("user_template", "请将以下{source_language}文本翻译成{target_language}：\n\n{text}")
	
	# 替换模板变量
	var user_prompt = user_template
	user_prompt = user_prompt.replace("{source_language}", source_lang_name)
	user_prompt = user_prompt.replace("{target_language}", target_lang_name)
	user_prompt = user_prompt.replace("{text}", text)
	
	return {
		"system": system_prompt,
		"user": user_prompt
	}

## 通用HTTP请求函数
func _send_http_request(url: String, headers: Array, method: HTTPClient.Method = HTTPClient.METHOD_POST, body: String = "") -> Dictionary:
	# 创建临时场景节点来发送HTTP请求
	var temp_node = Node.new()
	var http_request = HTTPRequest.new()
	temp_node.add_child(http_request)
	Engine.get_main_loop().current_scene.add_child(temp_node)
	
	# 配置HTTPS支持
	http_request.set_use_threads(true)
	http_request.set_accept_gzip(true)
	
	print("=== HTTP请求详情 ===")
	print("URL: ", url)
	print("方法: ", method)
	print("请求头: ", headers)
	print("请求体长度: ", body.length())
	print("====================")
	
	
	# 使用引用类型解决变量作用域问题
	var status = {"completed": false, "data": {}}
	
	http_request.request_completed.connect(func(result: int, response_code: int, headers_received: PackedStringArray, response_body: PackedByteArray):
		var body_text = response_body.get_string_from_utf8()
		
		print("=== HTTP请求调试信息 ===")
		print("结果码: ", result)
		print("HTTP状态码: ", response_code)
		print("响应内容: ", body_text)
		print("=========================")
		
		if response_code == 200:
			# 特殊处理DeepSeek API的空响应问题
			if body_text.strip_edges().is_empty():
				print("❌ 检测到200状态码但响应体为空（DeepSeek API已知问题）")
				status.data = {"success": false, "error": "DeepSeek API返回空响应（状态码200但无内容）"}
			else:
				var json = JSON.new()
				var parse_result = json.parse(body_text)
				if parse_result == OK:
					print("✅ JSON解析成功，请求完成")
					status.data = {"success": true, "data": json.data}
				else:
					print("❌ JSON解析失败，响应内容: ", body_text.substr(0, 300))
					status.data = {"success": false, "error": "响应格式无效: JSON解析失败 - " + json.error_string}
		else:
			var error_msg = "HTTP错误 " + str(response_code)
			if not body_text.is_empty():
				error_msg += ": " + body_text
			status.data = {"success": false, "error": error_msg}
		
		# 最后设置完成标志
		status.completed = true
		print("🔄 请求状态已更新为完成")
	)
	
	# 发送请求
	var error = http_request.request(url, headers, method, body)
	if error != OK:
		temp_node.queue_free()
		return {"success": false, "error": "请求发送失败: " + str(error)}
	
	# 等待响应，最多等待10秒（快速测试）
	var max_wait_time = 10.0
	var wait_time = 0.0
	var delta = 0.1
	
	print("⏳ 开始等待HTTP响应，最大等待时间: ", max_wait_time, "秒")
	
	while not status.completed and wait_time < max_wait_time:
		await Engine.get_main_loop().create_timer(delta).timeout
		wait_time += delta
		
		# 每2秒显示一次等待进度
		if int(wait_time) % 2 == 0 and fmod(wait_time, 1.0) < 0.2:
			print("⏳ 等待中... ", int(wait_time), "秒 (完成状态: ", status.completed, ")")
	
	# 清理临时节点
	temp_node.queue_free()
	
	if not status.completed:
		print("❌ 等待超时，最终状态: ", status.completed, ", 等待时间: ", wait_time)
		return {"success": false, "error": "请求超时"}
	
	print("✅ 请求完成，返回结果")
	return status.data 
