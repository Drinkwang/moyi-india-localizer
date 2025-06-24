extends Node

## UI功能测试脚本
## 用于测试密钥显示/隐藏等新功能

func _ready():
	print("=== UI功能测试 ===")
	await test_ui_features()

func test_ui_features():
	print("🧪 测试新的UI功能...")
	
	# 测试1：验证节点路径是否正确
	print("\n1. 验证节点路径...")
	var main_scene = load("res://scenes/main/main.tscn")
	if main_scene:
		print("✅ 主场景加载成功")
		var instance = main_scene.instantiate()
		add_child(instance)
		
		# 测试密钥输入框路径
		var paths_to_test = [
			"AIConfigDialog/VBoxContainer/TabContainer/OpenAI/APIKeyContainer/APIKeyInput",
			"AIConfigDialog/VBoxContainer/TabContainer/OpenAI/APIKeyContainer/ToggleVisibilityButton",
			"AIConfigDialog/VBoxContainer/TabContainer/Claude/APIKeyContainer/APIKeyInput", 
			"AIConfigDialog/VBoxContainer/TabContainer/Claude/APIKeyContainer/ToggleVisibilityButton",
			"AIConfigDialog/VBoxContainer/TabContainer/百度翻译/SecretKeyContainer/SecretKeyInput",
			"AIConfigDialog/VBoxContainer/TabContainer/百度翻译/SecretKeyContainer/ToggleVisibilityButton",
			"AIConfigDialog/VBoxContainer/TabContainer/DeepSeek/APIKeyContainer/APIKeyInput",
			"AIConfigDialog/VBoxContainer/TabContainer/DeepSeek/APIKeyContainer/ToggleVisibilityButton"
		]
		
		var success_count = 0
		for path in paths_to_test:
			var node = instance.find_child("Main", true) if instance.find_child("Main", true) else instance
			var target_node = _find_node_by_path(node, path)
			if target_node:
				print("   ✅ ", path)
				success_count += 1
			else:
				print("   ❌ ", path)
		
		print("\n节点路径测试结果: ", success_count, "/", paths_to_test.size(), " 通过")
		
		# 测试2：验证按钮功能
		print("\n2. 测试按钮功能...")
		await test_button_functionality(instance)
		
		instance.queue_free()
	else:
		print("❌ 无法加载主场景")

func test_button_functionality(scene_instance):
	print("   测试密钥显示/隐藏功能...")
	
	# 查找一个API密钥输入框和对应的按钮
	var main_node = scene_instance.find_child("Main", true) if scene_instance.find_child("Main", true) else scene_instance
	var api_key_input = _find_node_by_path(main_node, "AIConfigDialog/VBoxContainer/TabContainer/OpenAI/APIKeyContainer/APIKeyInput")
	var toggle_button = _find_node_by_path(main_node, "AIConfigDialog/VBoxContainer/TabContainer/OpenAI/APIKeyContainer/ToggleVisibilityButton")
	
	if api_key_input and toggle_button:
		# 设置测试数据
		api_key_input.text = "test-api-key-12345"
		
		# 测试初始状态
		var initial_secret = api_key_input.secret
		var initial_button_text = toggle_button.text
		print("   初始状态 - 密钥隐藏: ", initial_secret, ", 按钮文本: ", initial_button_text)
		
		# 模拟按钮点击
		if main_node.has_method("_on_toggle_visibility"):
			main_node._on_toggle_visibility(api_key_input, toggle_button)
			
			var after_click_secret = api_key_input.secret
			var after_click_button_text = toggle_button.text
			print("   点击后状态 - 密钥隐藏: ", after_click_secret, ", 按钮文本: ", after_click_button_text)
			
			# 验证状态是否改变
			if initial_secret != after_click_secret:
				print("   ✅ 密钥显示状态切换成功")
			else:
				print("   ❌ 密钥显示状态未改变")
			
			if initial_button_text != after_click_button_text:
				print("   ✅ 按钮图标切换成功")
			else:
				print("   ❌ 按钮图标未改变")
		else:
			print("   ❌ 未找到_on_toggle_visibility方法")
	else:
		print("   ❌ 未找到测试节点")
		if not api_key_input:
			print("      缺少API密钥输入框")
		if not toggle_button:
			print("      缺少切换按钮")

func _find_node_by_path(root_node: Node, path: String) -> Node:
	var parts = path.split("/")
	var current_node = root_node
	
	for part in parts:
		if not current_node:
			return null
		current_node = current_node.find_child(part)
	
	return current_node

func test_configuration_loading():
	print("\n3. 测试配置文件...")
	
	var config_path = "res://resources/configs/api_config.json"
	var file = FileAccess.open(config_path, FileAccess.READ)
	
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		if json.parse(json_string) == OK:
			var config = json.data
			print("   ✅ 配置文件格式正确")
			
			# 检查各个服务配置
			var services = ["openai", "claude", "baidu", "deepseek", "local"]
			for service in services:
				if config.services.has(service):
					print("   ✅ ", service, " 服务配置存在")
				else:
					print("   ❌ ", service, " 服务配置缺失")
		else:
			print("   ❌ 配置文件JSON格式错误")
	else:
		print("   ❌ 无法读取配置文件")

func print_summary():
	print("\n=== 测试总结 ===")
	print("新功能测试完成！")
	print("主要改进:")
	print("• ✅ 为所有API密钥输入框添加了显示/隐藏按钮")
	print("• ✅ 使用眼睛图标(👁)和遮眼图标(🙈)来表示状态")
	print("• ✅ 支持OpenAI、Claude、百度翻译、DeepSeek服务")
	print("• ✅ 点击按钮可以在隐藏和明文之间切换")
	print("================") 