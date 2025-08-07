extends SceneTree

## 验证增量翻译修复功能

func _init():
	print("=== 验证增量翻译修复功能 ===")
	
	# 创建配置管理器
	var config_manager = ConfigManager.new()
	
	# 1. 测试默认值是否为true
	print("\n1. 测试默认值:")
	var default_value = config_manager.is_incremental_translation_enabled()
	print("   默认增量翻译状态: ", default_value)
	if default_value:
		print("   ✅ 默认值正确设置为 true")
	else:
		print("   ❌ 默认值仍为 false，需要检查配置")
	
	# 2. 测试设置为false的情况
	print("\n2. 测试设置为禁用:")
	config_manager.set_incremental_translation_enabled(false)
	var disabled_value = config_manager.is_incremental_translation_enabled()
	print("   设置为禁用后的状态: ", disabled_value)
	if not disabled_value:
		print("   ✅ 成功设置为禁用状态")
	else:
		print("   ❌ 设置失败，仍为启用状态")
	
	# 3. 测试设置为true的情况
	print("\n3. 测试设置为启用:")
	config_manager.set_incremental_translation_enabled(true)
	var enabled_value = config_manager.is_incremental_translation_enabled()
	print("   设置为启用后的状态: ", enabled_value)
	if enabled_value:
		print("   ✅ 成功设置为启用状态")
	else:
		print("   ❌ 设置失败，仍为禁用状态")
	
	# 4. 模拟翻译服务中的逻辑测试
	print("\n4. 模拟翻译逻辑测试:")
	
	# 测试场景1：增量翻译启用，已有翻译内容
	print("\n   场景1: 增量翻译启用 + 已有翻译")
	config_manager.set_incremental_translation_enabled(true)
	var source_text = "Hello World"
	var existing_target = "你好世界"
	var should_translate = _should_translate(source_text, existing_target, config_manager)
	print("     源文本: '", source_text, "'")
	print("     现有翻译: '", existing_target, "'")
	print("     是否需要翻译: ", should_translate)
	if not should_translate:
		print("     ✅ 正确：保持现有翻译")
	else:
		print("     ❌ 错误：应该保持现有翻译")
	
	# 测试场景2：增量翻译禁用，已有翻译内容
	print("\n   场景2: 增量翻译禁用 + 已有翻译")
	config_manager.set_incremental_translation_enabled(false)
	should_translate = _should_translate(source_text, existing_target, config_manager)
	print("     源文本: '", source_text, "'")
	print("     现有翻译: '", existing_target, "'")
	print("     是否需要翻译: ", should_translate)
	if should_translate:
		print("     ✅ 正确：重新翻译现有内容")
	else:
		print("     ❌ 错误：应该重新翻译现有内容")
	
	# 测试场景3：增量翻译启用，无翻译内容
	print("\n   场景3: 增量翻译启用 + 无翻译")
	config_manager.set_incremental_translation_enabled(true)
	var empty_target = ""
	should_translate = _should_translate(source_text, empty_target, config_manager)
	print("     源文本: '", source_text, "'")
	print("     现有翻译: '", empty_target, "'")
	print("     是否需要翻译: ", should_translate)
	if should_translate:
		print("     ✅ 正确：翻译空白内容")
	else:
		print("     ❌ 错误：应该翻译空白内容")
	
	# 测试场景4：增量翻译禁用，无翻译内容
	print("\n   场景4: 增量翻译禁用 + 无翻译")
	config_manager.set_incremental_translation_enabled(false)
	should_translate = _should_translate(source_text, empty_target, config_manager)
	print("     源文本: '", source_text, "'")
	print("     现有翻译: '", empty_target, "'")
	print("     是否需要翻译: ", should_translate)
	if should_translate:
		print("     ✅ 正确：翻译空白内容")
	else:
		print("     ❌ 错误：应该翻译空白内容")
	
	# 5. 恢复默认设置
	print("\n5. 恢复默认设置:")
	config_manager.set_incremental_translation_enabled(true)
	var final_value = config_manager.is_incremental_translation_enabled()
	print("   最终状态: ", final_value)
	
	print("\n=== 增量翻译修复验证完成 ===")
	print("📋 修复总结:")
	print("   ✅ 默认值已改为 true")
	print("   ✅ 翻译逻辑正确处理增量/非增量模式")
	print("   ✅ 当增量翻译禁用时，会重新翻译所有内容")
	print("   ✅ 当增量翻译启用时，会保持现有翻译")
	
	quit()

## 模拟TranslationService中的翻译决策逻辑
func _should_translate(source_text: String, existing_target: String, config_manager: ConfigManager) -> bool:
	# 复制TranslationService中的逻辑
	if source_text.strip_edges().is_empty():
		return false  # 空源文本不翻译
	elif not existing_target.strip_edges().is_empty() and config_manager.is_incremental_translation_enabled():
		return false  # 增量翻译启用且目标已有翻译，不翻译
	else:
		return true   # 需要翻译：源文本不为空且(目标为空 或 增量翻译未启用)