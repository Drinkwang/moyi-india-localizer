extends SceneTree

## 测试增量翻译UI功能

func _init():
	print("=== 测试增量翻译UI功能 ===")
	
	# 创建主场景实例
	var main_scene = preload("res://scenes/main/main.tscn").instantiate()
	
	# 添加到场景树
	get_root().add_child(main_scene)
	
	# 等待一帧让UI初始化
	await get_tree().process_frame
	
	# 获取增量翻译开关节点
	var incremental_check = main_scene.get_node("AIConfigDialog/VBoxContainer/GeneralSettingsContainer/IncrementalTranslationContainer/IncrementalTranslationCheck")
	
	if incremental_check:
		print("✅ 找到增量翻译开关节点")
		print("   节点类型: ", incremental_check.get_class())
		print("   当前状态: ", incremental_check.button_pressed)
		print("   节点文本: ", incremental_check.text)
		
		# 测试开关状态变化
		print("\n🧪 测试开关状态变化:")
		
		# 设置为启用
		incremental_check.button_pressed = true
		print("   设置为启用: ", incremental_check.button_pressed)
		
		# 设置为禁用
		incremental_check.button_pressed = false
		print("   设置为禁用: ", incremental_check.button_pressed)
		
		# 测试配置保存和加载
		print("\n🧪 测试配置保存和加载:")
		var config_manager = ConfigManager.new()
		
		# 设置配置
		incremental_check.button_pressed = true
		config_manager.set_incremental_translation_enabled(true)
		print("   保存启用状态: ", config_manager.is_incremental_translation_enabled())
		
		incremental_check.button_pressed = false
		config_manager.set_incremental_translation_enabled(false)
		print("   保存禁用状态: ", config_manager.is_incremental_translation_enabled())
		
		print("\n✅ 增量翻译UI功能测试完成")
	else:
		print("❌ 未找到增量翻译开关节点")
		print("   检查节点路径: AIConfigDialog/VBoxContainer/GeneralSettingsContainer/IncrementalTranslationContainer/IncrementalTranslationCheck")
	
	# 检查其他相关UI组件
	var ai_config_dialog = main_scene.get_node("AIConfigDialog")
	if ai_config_dialog:
		print("\n📋 AI配置对话框信息:")
		print("   对话框存在: ✅")
		
		var general_container = main_scene.get_node_or_null("AIConfigDialog/VBoxContainer/GeneralSettingsContainer")
		if general_container:
			print("   通用设置容器: ✅")
			print("   子节点数量: ", general_container.get_child_count())
			
			for i in range(general_container.get_child_count()):
				var child = general_container.get_child(i)
				print("     - ", child.name, " (", child.get_class(), ")")
		else:
			print("   通用设置容器: ❌")
	
	print("\n=== 测试完成 ===")
	quit()