extends Node

func _ready():
	print("=== 测试翻译功能 ===")
	
	# 等待一帧确保所有服务都已初始化
	await get_tree().process_frame
	
	# 获取翻译服务
	var translation_service = get_node("/root/Main/TranslationService")
	if not translation_service:
		print("错误：无法找到翻译服务")
		return
	
	# 获取知识库管理器
	var knowledge_base_manager = translation_service.knowledge_base_manager
	if not knowledge_base_manager:
		print("错误：无法找到知识库管理器")
		return
	
	print("知识库状态：", "启用" if knowledge_base_manager.is_enabled else "禁用")
	
	# 测试搜索"一键翻译"术语
	print("\n=== 测试术语搜索 ===")
	var search_results = knowledge_base_manager.search_terms("一键翻译", 5)
	print("搜索'一键翻译'的结果数量：", search_results.size())
	
	for i in range(search_results.size()):
		var result = search_results[i]
		print("结果 %d:" % (i + 1))
		print("  术语：%s" % result.term)
		print("  目标：%s" % result.target)
		print("  置信度：%.2f" % result.confidence)
		print("  源语言：%s" % result.source_lang)
		print("  目标语言：%s" % result.target_lang)
	
	# 测试翻译功能
	print("\n=== 测试翻译功能 ===")
	var source_text = "一键翻译"
	var source_lang = "zh"
	var target_lang = "en"
	var service_name = "local_model"
	var template_name = "basic"
	
	print("准备翻译：'%s' (%s -> %s)" % [source_text, source_lang, target_lang])
	
	# 连接翻译完成信号
	translation_service.translation_completed.connect(_on_translation_completed)
	translation_service.translation_failed.connect(_on_translation_failed)
	
	# 执行翻译
	translation_service.translate_text_with_template(
		source_text,
		source_lang,
		target_lang,
		service_name,
		template_name
	)

func _on_translation_completed(result: Dictionary):
	print("\n=== 翻译完成 ===")
	print("原文：%s" % result.get("source_text", ""))
	print("译文：%s" % result.get("translated_text", ""))
	print("使用的服务：%s" % result.get("service_name", ""))
	print("使用的模板：%s" % result.get("template_name", ""))
	print("是否使用了知识库：%s" % ("是" if result.get("used_knowledge_base", false) else "否"))
	
	# 检查翻译结果是否正确
	var translated_text = result.get("translated_text", "")
	if "One-Click Translation" in translated_text:
		print("✅ 翻译结果正确！包含了知识库中的术语")
	else:
		print("❌ 翻译结果可能不正确，未包含预期的术语")
	
	print("==================")

func _on_translation_failed(error_message: String):
	print("\n=== 翻译失败 ===")
	print("错误信息：%s" % error_message)
	print("================")