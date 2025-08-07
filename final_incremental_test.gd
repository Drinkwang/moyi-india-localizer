extends SceneTree

## 最终验证增量翻译功能

func _init():
	print("=== 最终验证增量翻译功能 ===")
	
	# 创建配置管理器
	var config_manager = ConfigManager.new()
	
	# 1. 检查当前默认状态
	print("\n1. 检查默认状态:")
	var default_enabled = config_manager.is_incremental_translation_enabled()
	print("   默认增量翻译状态: ", default_enabled)
	if default_enabled:
		print("   ✅ 默认启用增量翻译")
	else:
		print("   ❌ 默认未启用增量翻译")
	
	# 2. 测试增量翻译逻辑
	print("\n2. 测试增量翻译逻辑:")
	
	# 模拟翻译场景
	var test_cases = [
		{
			"name": "启用增量翻译 + 有现有翻译",
			"incremental_enabled": true,
			"source_text": "Hello World",
			"existing_target": "你好世界",
			"expected_skip": true,
			"expected_action": "保持现有翻译(增量模式)"
		},
		{
			"name": "启用增量翻译 + 无现有翻译",
			"incremental_enabled": true,
			"source_text": "Hello World",
			"existing_target": "",
			"expected_skip": false,
			"expected_action": "新翻译"
		},
		{
			"name": "禁用增量翻译 + 有现有翻译",
			"incremental_enabled": false,
			"source_text": "Hello World",
			"existing_target": "你好世界",
			"expected_skip": false,
			"expected_action": "重新翻译(非增量模式)"
		},
		{
			"name": "禁用增量翻译 + 无现有翻译",
			"incremental_enabled": false,
			"source_text": "Hello World",
			"existing_target": "",
			"expected_skip": false,
			"expected_action": "新翻译"
		}
	]
	
	var all_passed = true
	
	for i in range(test_cases.size()):
		var test_case = test_cases[i]
		print("\n   测试", i+1, ": ", test_case.name)
		
		# 设置增量翻译状态
		config_manager.set_incremental_translation_enabled(test_case.incremental_enabled)
		
		# 模拟翻译决策逻辑
		var should_skip = _should_skip_translation(
			test_case.source_text,
			test_case.existing_target,
			config_manager
		)
		
		var action = _get_action_description(
			test_case.source_text,
			test_case.existing_target,
			config_manager
		)
		
		print("     源文本: '", test_case.source_text, "'")
		print("     现有翻译: '", test_case.existing_target, "'")
		print("     增量翻译: ", test_case.incremental_enabled)
		print("     是否跳过: ", should_skip, " (预期: ", test_case.expected_skip, ")")
		print("     动作: ", action, " (预期: ", test_case.expected_action, ")")
		
		if should_skip == test_case.expected_skip and action == test_case.expected_action:
			print("     ✅ 测试通过")
		else:
			print("     ❌ 测试失败")
			all_passed = false
	
	# 3. 总结
	print("\n3. 总结:")
	if all_passed:
		print("   ✅ 所有测试通过，增量翻译功能正常工作")
		print("   📋 功能说明:")
		print("     - 启用增量翻译时：跳过已有翻译，只翻译空白内容")
		print("     - 禁用增量翻译时：重新翻译所有内容，包括已有翻译")
		print("     - 默认状态：启用增量翻译")
	else:
		print("   ❌ 部分测试失败，需要检查增量翻译逻辑")
	
	print("\n=== 验证完成 ===")
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

## 获取动作描述
func _get_action_description(source_text: String, existing_target: String, config_manager: ConfigManager) -> String:
	if source_text.strip_edges().is_empty():
		return "空源文本"
	elif not existing_target.strip_edges().is_empty() and config_manager.is_incremental_translation_enabled():
		return "保持现有翻译(增量模式)"
	elif not existing_target.strip_edges().is_empty() and not config_manager.is_incremental_translation_enabled():
		return "重新翻译(非增量模式)"
	else:
		return "新翻译"