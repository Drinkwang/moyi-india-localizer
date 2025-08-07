extends SceneTree

## 通过ConfigManager设置增量翻译为true

func _init():
	print("=== 通过ConfigManager设置增量翻译 ===")
	
	# 创建配置管理器
	var config_manager = ConfigManager.new()
	
	# 1. 检查当前状态
	print("\n1. 当前状态:")
	var current_value = config_manager.is_incremental_translation_enabled()
	print("   当前增量翻译状态: ", current_value)
	
	# 2. 设置为true
	print("\n2. 设置增量翻译为true:")
	var set_result = config_manager.set_incremental_translation_enabled(true)
	print("   设置结果: ", set_result)
	
	# 3. 验证设置
	print("\n3. 验证设置:")
	var new_value = config_manager.is_incremental_translation_enabled()
	print("   新的增量翻译状态: ", new_value)
	
	# 4. 检查配置文件内容
	print("\n4. 检查配置文件内容:")
	var api_config = config_manager.get_api_config()
	print("   配置文件中的incremental_translation值: ", api_config.get("incremental_translation", "未找到"))
	
	if new_value:
		print("\n✅ 增量翻译已成功设置为启用状态")
	else:
		print("\n❌ 增量翻译设置失败")
	
	print("\n=== 设置完成 ===")
	quit()