extends SceneTree

func _ready():
	print("=== 知识库启用开关测试 ===")
	
	# 加载主场景
	var main_scene = load("res://scenes/main/main.tscn")
	var main_instance = main_scene.instantiate()
	
	# 等待一帧让UI初始化
	await get_process_frame()
	
	# 测试知识库UI交互
	test_knowledge_base_ui_interaction(main_instance)
	
	# 清理并退出
	main_instance.queue_free()
	quit()

func test_knowledge_base_ui_interaction(main_instance):
	print("\n🔍 测试知识库UI交互...")
	
	# 查找知识库相关的UI元素
	var kb_enabled_check = main_instance.get_node_or_null("VBoxContainer/TabContainer/知识库/VBoxContainer/EnabledContainer/KBEnabledCheck")
	var apply_button = main_instance.get_node_or_null("VBoxContainer/TabContainer/知识库/VBoxContainer/ConfigContainer/ButtonContainer/ApplyButton")
	
	if not kb_enabled_check:
		print("❌ 未找到知识库启用开关")
		return
	
	if not apply_button:
		print("❌ 未找到应用更改按钮")
		return
	
	print("✅ 找到UI元素")
	
	# 测试初始状态
	print("\n📋 初始状态:")
	print("  知识库启用: ", kb_enabled_check.button_pressed)
	print("  应用按钮禁用: ", apply_button.disabled)
	
	# 测试启用知识库
	print("\n🔄 测试启用知识库...")
	kb_enabled_check.button_pressed = true
	kb_enabled_check.emit_signal("toggled", true)
	
	await get_process_frame()
	
	print("  知识库启用后:")
	print("  知识库启用: ", kb_enabled_check.button_pressed)
	print("  应用按钮禁用: ", apply_button.disabled)
	
	if apply_button.disabled:
		print("❌ 问题：启用知识库后应用按钮仍然禁用")
	else:
		print("✅ 正确：启用知识库后应用按钮可用")
	
	# 测试禁用知识库
	print("\n🔄 测试禁用知识库...")
	kb_enabled_check.button_pressed = false
	kb_enabled_check.emit_signal("toggled", false)
	
	await get_process_frame()
	
	print("  知识库禁用后:")
	print("  知识库启用: ", kb_enabled_check.button_pressed)
	print("  应用按钮禁用: ", apply_button.disabled)
	
	if not apply_button.disabled:
		print("❌ 问题：禁用知识库后应用按钮仍然可用")
	else:
		print("✅ 正确：禁用知识库后应用按钮禁用")
	
	print("\n=== 测试完成 ===")

## 测试知识库启用功能

func _ready():
	print("🧪 测试知识库启用功能...")
	
	# 初始化配置管理器
	var config_manager = ConfigManager.new()
	config_manager.initialize()
	
	print("\n=== 测试配置管理器知识库功能 ===")
	
	# 1. 测试默认状态
	print("1. 默认启用状态:", config_manager.is_knowledge_base_enabled())
	
	# 2. 测试启用知识库
	print("2. 启用知识库...")
	var enable_result = config_manager.set_knowledge_base_enabled(true)
	print("   设置结果:", enable_result)
	print("   当前状态:", config_manager.is_knowledge_base_enabled())
	
	# 3. 测试知识库配置
	var kb_config = config_manager.get_knowledge_base_config()
	print("3. 知识库配置:")
	print("   启用状态:", kb_config.get("enabled", false))
	print("   根路径:", kb_config.get("root_path", ""))
	print("   缓存大小:", kb_config.get("max_cache_size", 0))
	print("   相似度阈值:", kb_config.get("similarity_threshold", 0))
	
	# 4. 测试知识库管理器初始化
	print("\n=== 测试知识库管理器 ===")
	var kb_manager = KnowledgeBaseManager.new()
	kb_manager.initialize(config_manager)
	
	# 5. 测试术语搜索（启用状态）
	print("4. 测试术语搜索（启用状态）:")
	var search_results = kb_manager.search_terms("start", 3)
	print("   搜索 'start' 结果数量:", search_results.size())
	for result in search_results:
		print("   - ", result.term.source, " → ", result.term.target.get("zh", ""))
	
	# 6. 测试禁用知识库
	print("\n5. 禁用知识库...")
	config_manager.set_knowledge_base_enabled(false)
	print("   当前状态:", config_manager.is_knowledge_base_enabled())
	
	# 7. 测试术语搜索（禁用状态）
	print("6. 测试术语搜索（禁用状态）:")
	var search_results_disabled = kb_manager.search_terms("start", 3)
	print("   搜索 'start' 结果数量:", search_results_disabled.size())
	
	# 8. 测试提示增强
	print("\n=== 测试提示增强功能 ===")
	
	# 重新启用知识库
	config_manager.set_knowledge_base_enabled(true)
	print("7. 重新启用知识库")
	
	var base_prompt = "请将以下英文翻译成中文："
	var enhanced_prompt = kb_manager.enhance_prompt("start game", "en", "zh", base_prompt)
	print("8. 提示增强测试:")
	print("   原始提示:", base_prompt)
	print("   增强后提示:")
	print(enhanced_prompt)
	
	# 9. 测试禁用状态下的提示增强
	config_manager.set_knowledge_base_enabled(false)
	var disabled_prompt = kb_manager.enhance_prompt("start game", "en", "zh", base_prompt)
	print("9. 禁用状态下的提示增强:")
	print("   结果:", disabled_prompt == base_prompt)
	
	print("\n✅ 知识库启用功能测试完成!")
	quit()