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
	
	# OpenAI服务
	if api_config.services.openai.enabled:
		services["openai"] = OpenAIService.new(api_config.services.openai)
	
	# Claude服务
	if api_config.services.claude.enabled:
		services["claude"] = ClaudeService.new(api_config.services.claude)
	
	# 百度翻译服务
	if api_config.services.baidu.enabled:
		services["baidu"] = BaiduTranslateService.new(api_config.services.baidu)
	
	# 腾讯翻译服务
	if api_config.services.tencent.enabled:
		services["tencent"] = TencentTranslateService.new(api_config.services.tencent)
	
	# 本地模型服务
	if api_config.services.local.enabled:
		services["local"] = LocalModelService.new(api_config.services.local)
	
	# DeepSeek服务
	if api_config.services.deepseek.enabled:
		services["deepseek"] = DeepSeekService.new(api_config.services.deepseek)

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
		if services[name].is_available():
			available.append({
				"name": name,
				"display_name": services[name].get_display_name(),
				"service": services[name]
			})
	return available

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
