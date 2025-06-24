class_name ConfigManager
extends RefCounted

## 配置管理器
## 负责加载和管理各种配置文件

const API_CONFIG_PATH = "res://resources/configs/api_config.json"
const APP_CONFIG_PATH = "res://resources/configs/app_config.json"
const TRANSLATION_CONFIG_PATH = "res://resources/configs/translation_config.json"

var api_config: Dictionary
var app_config: Dictionary
var translation_config: Dictionary

func _init():
	load_all_configs()

## 加载所有配置文件
func load_all_configs():
	api_config = _load_json_config(API_CONFIG_PATH)
	app_config = _load_json_config(APP_CONFIG_PATH)
	translation_config = _load_json_config(TRANSLATION_CONFIG_PATH)

## 加载JSON配置文件
func _load_json_config(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("警告: 无法加载配置文件 ", path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("错误: 解析配置文件失败 ", path, " - ", json.error_string)
		return {}
	
	return json.data

## 保存配置文件
func save_config(config_type: String, config_data: Dictionary) -> bool:
	var path = ""
	match config_type:
		"api":
			path = API_CONFIG_PATH
			api_config = config_data
		"app":
			path = APP_CONFIG_PATH
			app_config = config_data
		"translation":
			path = TRANSLATION_CONFIG_PATH
			translation_config = config_data
		_:
			print("错误: 未知的配置类型 ", config_type)
			return false
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		print("错误: 无法保存配置文件 ", path)
		return false
	
	var json_string = JSON.stringify(config_data, "\t")
	file.store_string(json_string)
	file.close()
	return true

## 获取API配置
func get_api_config() -> Dictionary:
	return api_config

## 获取应用配置
func get_app_config() -> Dictionary:
	return app_config

## 获取翻译配置
func get_translation_config() -> Dictionary:
	return translation_config

## 获取默认服务
func get_default_service() -> String:
	return api_config.get("default_service", "openai")

## 设置默认服务
func set_default_service(service_name: String):
	api_config.default_service = service_name
	save_config("api", api_config)

## 更新API密钥
func update_api_key(service_name: String, api_key: String):
	if api_config.services.has(service_name):
		api_config.services[service_name].api_key = api_key
		save_config("api", api_config)

## 启用/禁用服务
func set_service_enabled(service_name: String, enabled: bool):
	if api_config.services.has(service_name):
		api_config.services[service_name].enabled = enabled
		save_config("api", api_config)

## 获取支持的语言列表
func get_supported_languages() -> Array:
	var base_languages = translation_config.get("languages", {}).get("supported_languages", [])
	var custom_mappings = translation_config.get("languages", {}).get("custom_language_mappings", {})
	
	# 应用自定义映射
	var final_languages = []
	for lang in base_languages:
		var lang_copy = lang.duplicate()
		var code = lang_copy.code
		
		# 如果有自定义映射，使用自定义设置
		if custom_mappings.has(code) and custom_mappings[code] is Dictionary:
			var custom = custom_mappings[code]
			if custom.has("name"):
				lang_copy.name = custom.name
			if custom.has("native_name"):
				lang_copy.native_name = custom.native_name
			if custom.has("description"):
				lang_copy.description = custom.description
		
		final_languages.append(lang_copy)
	
	return final_languages

## 获取语言名称映射（用于AI服务）
func get_language_name_map() -> Dictionary:
	var languages = get_supported_languages()
	var map = {}
	
	for lang in languages:
		var description = lang.get("description", lang.get("name", lang.code))
		map[lang.code] = description
	
	return map

## 根据语言代码获取语言名称
func get_language_name(lang_code: String) -> String:
	var languages = get_supported_languages()
	for lang in languages:
		if lang.code == lang_code:
			return lang.get("description", lang.get("name", lang_code))
	return lang_code

## 添加或更新自定义语言映射
func set_custom_language_mapping(lang_code: String, name: String, native_name: String, description: String):
	if not translation_config.has("languages"):
		translation_config["languages"] = {}
	if not translation_config.languages.has("custom_language_mappings"):
		translation_config.languages["custom_language_mappings"] = {}
	
	translation_config.languages.custom_language_mappings[lang_code] = {
		"name": name,
		"native_name": native_name,
		"description": description
	}
	
	save_config("translation", translation_config)

## 获取支持的编程语言列表
func get_supported_programming_languages() -> Array:
	return translation_config.get("game_languages", {}).get("programming_languages", [])

## 获取翻译规则
func get_translation_rules() -> Dictionary:
	return translation_config.get("translation_rules", {})

## 获取质量控制设置
func get_quality_control_settings() -> Dictionary:
	return translation_config.get("quality_control", {}) 