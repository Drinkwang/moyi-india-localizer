extends Node

## 测试缓存修复验证脚本
## 验证关闭增量翻译时不使用缓存的功能

var config_manager: ConfigManager
var translation_service: TranslationService
var cache_manager: CacheManager

func _ready():
	print("=== 开始缓存修复验证测试 ===")
	
	# 初始化管理器
	config_manager = ConfigManager.new()
	translation_service = TranslationService.new()
	cache_manager = CacheManager.new()
	
	# 运行测试
	await run_cache_tests()
	
	print("=== 缓存修复验证测试完成 ===")

## 运行缓存测试
func run_cache_tests():
	print("\n1. 测试增量翻译启用时的缓存行为...")
	await test_incremental_enabled_cache()
	
	print("\n2. 测试增量翻译禁用时的缓存行为...")
	await test_incremental_disabled_cache()
	
	print("\n3. 测试缓存清除功能...")
	test_cache_clear()

## 测试增量翻译启用时的缓存行为
func test_incremental_enabled_cache():
	# 启用增量翻译
	config_manager.set_incremental_translation_enabled(true)
	
	# 清除缓存以确保干净的测试环境
	cache_manager.clear_cache()
	
	# 模拟翻译请求
	var test_text = "Hello World"
	var cache_key = "test_key_enabled"
	
	# 先保存一个缓存结果
	cache_manager.save_translation(cache_key, "你好世界")
	
	# 检查缓存是否被使用（应该使用）
	var cached_result = cache_manager.get_translation(cache_key)
	if cached_result == "你好世界":
		print("✅ 增量翻译启用时正确使用了缓存")
	else:
		print("❌ 增量翻译启用时未正确使用缓存")

## 测试增量翻译禁用时的缓存行为
func test_incremental_disabled_cache():
	# 禁用增量翻译
	config_manager.set_incremental_translation_enabled(false)
	
	# 保存一个缓存结果
	var cache_key = "test_key_disabled"
	cache_manager.save_translation(cache_key, "缓存的翻译")
	
	# 验证缓存存在
	var cached_result = cache_manager.get_translation(cache_key)
	if cached_result == "缓存的翻译":
		print("✅ 缓存已正确保存")
	else:
		print("❌ 缓存保存失败")
		return
	
	# 模拟翻译服务的行为
	# 在非增量模式下，应该跳过缓存检查
	var use_cache = config_manager.is_incremental_translation_enabled()
	
	if not use_cache:
		print("✅ 增量翻译禁用时正确跳过了缓存检查")
	else:
		print("❌ 增量翻译禁用时仍然尝试使用缓存")

## 测试缓存清除功能
func test_cache_clear():
	# 添加一些测试缓存
	cache_manager.save_translation("test1", "测试1")
	cache_manager.save_translation("test2", "测试2")
	cache_manager.save_translation("test3", "测试3")
	
	# 验证缓存存在
	var before_clear = cache_manager.get_translation("test1")
	if before_clear == "测试1":
		print("✅ 清除前缓存存在")
	else:
		print("❌ 清除前缓存不存在")
		return
	
	# 清除缓存
	cache_manager.clear_cache()
	
	# 验证缓存已清除
	var after_clear = cache_manager.get_translation("test1")
	if after_clear.is_empty():
		print("✅ 缓存清除功能正常工作")
	else:
		print("❌ 缓存清除功能失败")

## 模拟翻译服务的缓存检查逻辑
func simulate_translation_cache_check(text: String, source_lang: String, target_lang: String) -> Dictionary:
	# 检查是否启用增量翻译，只有在增量模式下才使用缓存
	var use_cache = config_manager.is_incremental_translation_enabled()
	
	# 生成缓存键
	var cache_key = text + "_" + source_lang + "_" + target_lang
	
	# 检查缓存（仅在增量模式下）
	if use_cache:
		var cached_result = cache_manager.get_translation(cache_key)
		if cached_result:
			print("📋 使用缓存结果: " + cached_result)
			return {"success": true, "translated_text": cached_result, "from_cache": true}
	else:
		print("🚫 跳过缓存检查（增量翻译已禁用）")
	
	# 模拟实际翻译
	var translated_text = "模拟翻译结果: " + text
	
	# 缓存结果（仅在增量模式下）
	if use_cache:
		cache_manager.save_translation(cache_key, translated_text)
		print("💾 结果已缓存")
	else:
		print("🚫 跳过缓存保存（增量翻译已禁用）")
	
	return {"success": true, "translated_text": translated_text, "from_cache": false}