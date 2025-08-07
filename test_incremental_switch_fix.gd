extends SceneTree

## 测试增量翻译开关修复

func _init():
	print("=== 测试增量翻译开关修复 ===")
	
	# 创建主场景实例
	var main_scene = preload("res://scenes/main/main.tscn").instantiate()
	
	# 添加到场景树
	get_root().add_child(main_scene)
	
	# 等待一帧让UI初始化
	await get_tree().process_frame
	
	# 测试增量翻译开关
	await _test_incremental_switch(main_scene)
	
	print("\n=== 测试完成 ===")
	quit()

## 测试增量翻译开关功能
func _test_incremental_switch(main_scene):
	print("\n1. 🔍 检查增量翻译开关节点:")
	
	var incremental_check = main_scene.get_node_or_null("AIConfigDialog/VBoxContainer/GeneralSettingsContainer/IncrementalTranslationContainer/IncrementalTranslationCheck")
	
	if incremental_check:
		print("   ✅ 增量翻译开关节点存在")
		print("   当前状态: ", incremental_check.button_pressed)
		
		# 检查信号连接
		var signals = incremental_check.get_signal_list()
		var has_toggled_signal = false
		for signal_info in signals:
			if signal_info.name == "toggled":
				has_toggled_signal = true
				break
		
		if has_toggled_signal:
			print("   ✅ toggled 信号存在")
			
			# 检查信号连接
			var connections = incremental_check.get_signal_connection_list("toggled")
			if connections.size() > 0:
				print("   ✅ 信号已连接到处理函数")
				print("   连接数量: ", connections.size())
				for connection in connections:
					print("   连接到: ", connection.callable.get_method())
			else:
				print("   ❌ 信号未连接")
		else:
			print("   ❌ toggled 信号不存在")
		
		# 测试开关功能
		print("\n2. 🧪 测试开关功能:")
		
		var config_manager = ConfigManager.new()
		var initial_state = config_manager.is_incremental_translation_enabled()
		print("   初始配置状态: ", initial_state)
		
		# 测试切换到启用状态
		print("\n   测试启用增量翻译:")
		incremental_check.button_pressed = true
		incremental_check.toggled.emit(true)
		await get_tree().process_frame
		
		var enabled_state = config_manager.is_incremental_translation_enabled()
		print("   配置状态: ", enabled_state)
		if enabled_state:
			print("   ✅ 启用功能正常")
		else:
			print("   ❌ 启用功能异常")
		
		# 测试切换到禁用状态
		print("\n   测试禁用增量翻译:")
		incremental_check.button_pressed = false
		incremental_check.toggled.emit(false)
		await get_tree().process_frame
		
		var disabled_state = config_manager.is_incremental_translation_enabled()
		print("   配置状态: ", disabled_state)
		if not disabled_state:
			print("   ✅ 禁用功能正常")
		else:
			print("   ❌ 禁用功能异常")
		
		# 恢复初始状态
		incremental_check.button_pressed = initial_state
		incremental_check.toggled.emit(initial_state)
		await get_tree().process_frame
		
		print("\n3. 📊 测试结果总结:")
		if enabled_state and not disabled_state:
			print("   ✅ 增量翻译开关功能正常")
			print("   ✅ 事件处理正确")
			print("   ✅ 配置保存正常")
		else:
			print("   ❌ 增量翻译开关存在问题")
			
	else:
		print("   ❌ 增量翻译开关节点不存在")
		print("   检查节点路径: AIConfigDialog/VBoxContainer/GeneralSettingsContainer/IncrementalTranslationContainer/IncrementalTranslationCheck")