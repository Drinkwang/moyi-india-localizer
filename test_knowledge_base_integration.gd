extends Node

## 简化的知识库功能测试

func _ready():
	print("🧪 开始知识库功能测试...")
	test_knowledge_base_basic()
	print("✅ 测试完成!")

func test_knowledge_base_basic():
	print("\n=== 基础功能测试 ===")
	
	# 测试配置管理器
	print("📋 测试配置管理器...")
	var config_manager = ConfigManager.new()
	config_manager.initialize()
	
	# 测试知识库启用/禁用
	config_manager.set_knowledge_base_enabled(true)
	print("  ✅ 知识库启用状态:", config_manager.is_knowledge_base_enabled())
	
	config_manager.set_knowledge_base_enabled(false)
	print("  ✅ 知识库禁用状态:", config_manager.is_knowledge_base_enabled())
	
	# 重新启用
	config_manager.set_knowledge_base_enabled(true)
	
	# 测试知识库管理器
	print("\n📚 测试知识库管理器...")
	var kb_manager = KnowledgeBaseManager.new()
	kb_manager.initialize(config_manager)
	
	# 测试添加术语
	print("  📝 测试添加术语...")
	var result = kb_manager.add_term("Test", {"zh": "测试"}, "测试术语", "test")
	print("    结果:", result)
	
	# 测试搜索
	print("  🔍 测试搜索功能...")
	var search_results = kb_manager.search_terms("Test", 5)
	print("    搜索结果数量:", search_results.size())
	
	# 测试提示增强
	print("  🚀 测试提示增强...")
	var base_prompt = "请翻译："
	var enhanced = kb_manager.enhance_prompt("Test", "en", "zh", base_prompt)
	print("    原始提示长度:", base_prompt.length())
	print("    增强提示长度:", enhanced.length())
	print("    是否增强:", enhanced != base_prompt)
	
	print("\n🎉 基础功能测试完成!")