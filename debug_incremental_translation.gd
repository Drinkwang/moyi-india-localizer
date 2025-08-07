extends SceneTree

## 调试增量翻译功能

func _init():
	print("=== 调试增量翻译功能 ===")
	
	# 创建配置管理器
	var config_manager = ConfigManager.new()
	
	# 1. 检查当前配置状态
	print("\n1. 检查配置状态:")
	var is_enabled = config_manager.is_incremental_translation_enabled()
	print("   增量翻译启用状态: ", is_enabled)
	
	# 2. 模拟翻译逻辑测试
	print("\n2. 模拟翻译逻辑测试:")
	
	# 测试数据
	var source_text = "Hello World"
	var existing_target_with_content = "你好世界"
	var existing_target_empty = ""
	
	print("   源文本: '", source_text, "'")
	print("   已有翻译: '", existing_target_with_content, "'")
	print("   空翻译: '", existing_target_empty, "'")
	
	# 测试场景1：增量翻译启用，有现有翻译
	print("\n   场景1: 增量翻译启用 + 有现有翻译")
	config_manager.set_incremental_translation_enabled(true)
	var should_skip = _should_skip_translation(source_text, existing_target_with_content, config_manager)
	print("     增量翻译状态: ", config_manager.is_incremental_translation_enabled())
	print("     是否跳过翻译: ", should_skip)
	print("     预期结果: 应该跳过 (true)")
	if should_skip:
		print("     ✅ 正确：跳过已有翻译")
	else:
		print("     ❌ 错误：应该跳过已有翻译")
	
	# 测试场景2：增量翻译启用，无现有翻译
	print("\n   场景2: 增量翻译启用 + 无现有翻译")
	should_skip = _should_skip_translation(source_text, existing_target_empty, config_manager)
	print("     增量翻译状态: ", config_manager.is_incremental_translation_enabled())
	print("     是否跳过翻译: ", should_skip)
	print("     预期结果: 不应该跳过 (false)")
	if not should_skip:
		print("     ✅ 正确：翻译空白内容")
	else:
		print("     ❌ 错误：不应该跳过空白内容")
	
	# 测试场景3：增量翻译禁用，有现有翻译
	print("\n   场景3: 增量翻译禁用 + 有现有翻译")
	config_manager.set_incremental_translation_enabled(false)
	should_skip = _should_skip_translation(source_text, existing_target_with_content, config_manager)
	print("     增量翻译状态: ", config_manager.is_incremental_translation_enabled())
	print("     是否跳过翻译: ", should_skip)
	print("     预期结果: 不应该跳过 (false)")
	if not should_skip:
		print("     ✅ 正确：重新翻译已有内容")
	else:
		print("     ❌ 错误：应该重新翻译已有内容")
	
	# 测试场景4：增量翻译禁用，无现有翻译
	print("\n   场景4: 增量翻译禁用 + 无现有翻译")
	should_skip = _should_skip_translation(source_text, existing_target_empty, config_manager)
	print("     增量翻译状态: ", config_manager.is_incremental_translation_enabled())
	print("     是否跳过翻译: ", should_skip)
	print("     预期结果: 不应该跳过 (false)")
	if not should_skip:
		print("     ✅ 正确：翻译空白内容")
	else:
		print("     ❌ 错误：不应该跳过空白内容")
	
	# 3. 检查配置文件内容
	print("\n3. 检查配置文件:")
	var api_config = config_manager.get_api_config()
	print("   配置文件中的增量翻译值: ", api_config.get("incremental_translation", "未设置"))
	
	# 4. 测试设置和获取
	print("\n4. 测试设置和获取:")
	print("   设置为true...")
	config_manager.set_incremental_translation_enabled(true)
	print("   获取结果: ", config_manager.is_incremental_translation_enabled())
	
	print("   设置为false...")
	config_manager.set_incremental_translation_enabled(false)
	print("   获取结果: ", config_manager.is_incremental_translation_enabled())
	
	print("\n=== 调试完成 ===")
	quit()

## 模拟TranslationService中的跳过逻辑
func _should_skip_translation(source_text: String, existing_target: String, config_manager: ConfigManager) -> bool:
	# 源文本为空时总是跳过
	if source_text.strip_edges().is_empty():
		return true
	
	# 增量翻译启用且目标已有翻译时跳过
	if not existing_target.strip_edges().is_empty() and config_manager.is_incremental_translation_enabled():
		return true
	
	# 其他情况不跳过
	return false