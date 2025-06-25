class_name AIServiceManager
extends RefCounted

## AI服务管理器
## 负责管理和协调各种AI翻译服务

var services: Dictionary = {}
var config_manager: ConfigManager

func _init():
	config_manager = ConfigManager.new()
	_initialize_services()

## 初始化所有AI服务
func _initialize_services():
	var api_config = config_manager.get_api_config()
	
	print("=== 初始化AI服务 ===")
	
	# 总是创建所有服务实例，不依赖enabled字段
	# 服务的可用性通过is_available()方法判断
	
	# OpenAI服务
	if api_config.services.has("openai"):
		services["openai"] = OpenAIService.new(api_config.services.openai)
		print("✅ OpenAI服务已创建")
	
	# Claude服务
	if api_config.services.has("claude"):
		services["claude"] = ClaudeService.new(api_config.services.claude)
		print("✅ Claude服务已创建")
	
	# 百度翻译服务
	if api_config.services.has("baidu"):
		services["baidu"] = BaiduTranslateService.new(api_config.services.baidu)
		print("✅ 百度翻译服务已创建")
	
	# 腾讯翻译服务
	if api_config.services.has("tencent"):
		services["tencent"] = TencentTranslateService.new(api_config.services.tencent)
		print("✅ 腾讯翻译服务已创建")
	
	# 本地模型服务
	if api_config.services.has("local"):
		services["local"] = LocalModelService.new(api_config.services.local)
		print("✅ 本地模型服务已创建")
	
	# DeepSeek服务
	if api_config.services.has("deepseek"):
		services["deepseek"] = DeepSeekService.new(api_config.services.deepseek)
		print("✅ DeepSeek服务已创建")
	
	print("总共创建了 ", services.size(), " 个AI服务")
	print("===================")

## 获取指定的AI服务
func get_service(service_name: String = "") -> AIServiceBase:
	if service_name.is_empty():
		service_name = config_manager.get_default_service()
	
	if services.has(service_name):
		return services[service_name]
	
	# 如果指定的服务不可用，尝试获取任何可用的服务
	for service in services.values():
		if service.is_available():
			return service
	
	return null

## 获取所有可用的服务
func get_available_services() -> Array:
	var available = []
	for name in services.keys():
		var service = services[name]
		var is_configured = service.is_available()
		var display_name = service.get_display_name()
		
		# 如果服务未配置，在显示名称中添加提示
		if not is_configured:
			display_name += " (未配置)"
		
		available.append({
			"name": name,
			"display_name": display_name,
			"service": service,
			"is_configured": is_configured
		})
	
	print("可用服务列表:")
	for service_info in available:
		var status = "✅ 已配置" if service_info.is_configured else "⚠️ 未配置"
		print("  ", service_info.display_name, " - ", status)
	
	return available

## 获取已配置的服务（真正可用的）
func get_configured_services() -> Array:
	var configured = []
	for name in services.keys():
		if services[name].is_available():
			configured.append({
				"name": name,
				"display_name": services[name].get_display_name(),
				"service": services[name]
			})
	return configured

## 测试服务连接
func test_service(service_name: String) -> Dictionary:
	if not services.has(service_name):
		return {"success": false, "error": "服务不存在"}
	
	var service = services[service_name]
	return await service.test_connection()

## 重新加载服务配置
func reload_services():
	services.clear()
	_initialize_services()

## 添加自定义服务
func add_custom_service(name: String, service: AIServiceBase):
	services[name] = service

## 移除服务
func remove_service(name: String):
	if services.has(name):
		services.erase(name) 
