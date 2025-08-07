extends SceneTree

## 测试增量翻译开关功能

func _init():
	print("=== 测试增量翻译开关功能 ===")
	
	# 创建配置管理器
	var config_manager = ConfigManager.new()
	
	# 测试默认值
	print("1. 测试默认值:")
	var default_value = config_manager.is_incremental_translation_enabled()
	print("   默认增量翻译状态: ", default_value)
	
	# 测试设置为true
	print("\n2. 测试设置为启用:")
	var set_result = config_manager.set_incremental_translation_enabled(true)
	print("   设置结果: ", set_result)
	var enabled_value = config_manager.is_incremental_translation_enabled()
	print("   当前状态: ", enabled_value)
	
	# 测试设置为false
	print("\n3. 测试设置为禁用:")
	set_result = config_manager.set_incremental_translation_enabled(false)
	print("   设置结果: ", set_result)
	var disabled_value = config_manager.is_incremental_translation_enabled()
	print("   当前状态: ", disabled_value)
	
	# 测试翻译服务中的逻辑
	print("\n4. 测试翻译服务中的逻辑:")
	var translation_service = TranslationService.new()
	
	# 模拟增量翻译启用的情况
	config_manager.set_incremental_translation_enabled(true)
	print("   增量翻译启用时:")
	print("   - 配置状态: ", config_manager.is_incremental_translation_enabled())
	
	# 模拟增量翻译禁用的情况
	config_manager.set_incremental_translation_enabled(false)
	print("   增量翻译禁用时:")
	print("   - 配置状态: ", config_manager.is_incremental_translation_enabled())
	
	print("\n=== 测试完成 ===")
	
	# 退出
	quit()