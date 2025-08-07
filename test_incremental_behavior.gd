extends SceneTree

## 测试增量翻译的实际行为

func _ready():
	print("=== 测试增量翻译实际行为 ===")
	
	# 加载配置管理器
	var config_manager = preload("res://scripts/core/config_manager.gd").new()
	
	# 检查当前增量翻译状态
	print("\n1. 检查当前配置状态:")
	var is_incremental_enabled = config_manager.is_incremental_translation_enabled()
	print("   增量翻译启用状态: ", is_incremental_enabled)
	
	# 模拟翻译服务的判断逻辑
	print("\n2. 模拟翻译判断逻辑:")
	
	# 测试场景1：有源文本，有目标翻译，增量翻译启用
	var source_text = "Hello World"
	var existing_target = "你好世界"
	
	print("   场景1: 源文本='", source_text, "', 目标翻译='", existing_target, "'")
	print("   增量翻译启用: ", is_incremental_enabled)
	
	var should_skip = _should_skip_translation(source_text, existing_target, config_manager)
	print("   判断结果: ", should_skip ? "跳过翻译" : "执行翻译")
	print("   预期结果: ", is_incremental_enabled ? "跳过翻译" : "执行翻译")
	
	if should_skip == is_incremental_enabled:
		print("   ✅ 判断逻辑正确")
	else:
		print("   ❌ 判断逻辑错误")
	
	# 测试场景2：有源文本，无目标翻译，增量翻译启用
	print("\n   场景2: 源文本='", source_text, "', 目标翻译=''")
	var empty_target = ""
	should_skip = _should_skip_translation(source_text, empty_target, config_manager)
	print("   判断结果: ", should_skip ? "跳过翻译" : "执行翻译")
	print("   预期结果: 执行翻译")
	
	if not should_skip:
		print("   ✅ 判断逻辑正确")
	else:
		print("   ❌ 判断逻辑错误")
	
	# 测试场景3：无源文本
	print("\n   场景3: 源文本='', 目标翻译='", existing_target, "'")
	var empty_source = ""
	should_skip = _should_skip_translation(empty_source, existing_target, config_manager)
	print("   判断结果: ", should_skip ? "跳过翻译" : "执行翻译")
	print("   预期结果: 跳过翻译")
	
	if should_skip:
		print("   ✅ 判断逻辑正确")
	else:
		print("   ❌ 判断逻辑错误")
	
	# 测试禁用增量翻译的情况
	print("\n3. 测试禁用增量翻译:")
	config_manager.set_incremental_translation_enabled(false)
	print("   设置增量翻译为: false")
	
	should_skip = _should_skip_translation(source_text, existing_target, config_manager)
	print("   场景: 源文本='", source_text, "', 目标翻译='", existing_target, "'")
	print("   判断结果: ", should_skip ? "跳过翻译" : "执行翻译")
	print("   预期结果: 执行翻译")
	
	if not should_skip:
		print("   ✅ 判断逻辑正确")
	else:
		print("   ❌ 判断逻辑错误")
	
	# 恢复原始设置
	config_manager.set_incremental_translation_enabled(is_incremental_enabled)
	
	print("\n=== 测试完成 ===")
	quit()

## 模拟TranslationService中的跳过逻辑
func _should_skip_translation(source_text: String, existing_target: String, config_manager) -> bool:
	# 源文本为空时总是跳过
	if source_text.strip_edges().is_empty():
		return true
	
	# 增量翻译启用且目标已有翻译时跳过
	if not existing_target.strip_edges().is_empty() and config_manager.is_incremental_translation_enabled():
		return true
	
	# 其他情况不跳过
	return false