extends SceneTree

## 检查配置文件路径和内容

func _init():
	print("=== 检查配置文件路径和内容 ===")
	
	# 1. 检查文件路径
	print("\n1. 检查文件路径:")
	var res_path = "res://resources/configs/api_config.json"
	var abs_path = "d:/Pro/translate/resources/configs/api_config.json"
	
	print("   res:// 路径存在: ", FileAccess.file_exists(res_path))
	print("   绝对路径存在: ", FileAccess.file_exists(abs_path))
	print("   res:// 全局化路径: ", ProjectSettings.globalize_path(res_path))
	
	# 2. 读取res://路径的内容
	print("\n2. 读取res://路径的内容:")
	var file = FileAccess.open(res_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		print("   内容长度: ", content.length())
		
		var json = JSON.new()
		var parse_result = json.parse(content)
		if parse_result == OK:
			var data = json.data
			print("   incremental_translation 值: ", data.get("incremental_translation", "未找到"))
		else:
			print("   JSON解析失败: ", json.error_string)
	else:
		print("   无法打开res://路径文件")
	
	# 3. 读取绝对路径的内容
	print("\n3. 读取绝对路径的内容:")
	file = FileAccess.open(abs_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		print("   内容长度: ", content.length())
		
		var json = JSON.new()
		var parse_result = json.parse(content)
		if parse_result == OK:
			var data = json.data
			print("   incremental_translation 值: ", data.get("incremental_translation", "未找到"))
		else:
			print("   JSON解析失败: ", json.error_string)
	else:
		print("   无法打开绝对路径文件")
	
	# 4. 使用ConfigManager检查
	print("\n4. 使用ConfigManager检查:")
	var config_manager = ConfigManager.new()
	var api_config = config_manager.get_api_config()
	print("   ConfigManager中的incremental_translation值: ", api_config.get("incremental_translation", "未找到"))
	print("   is_exported: ", config_manager.is_exported)
	
	print("\n=== 检查完成 ===")
	quit()