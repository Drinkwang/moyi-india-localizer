class_name ConfigManager
extends RefCounted

## 配置管理器
## 负责加载和管理各种配置文件

# 默认资源路径（打包前路径）
const API_CONFIG_PATH = "res://resources/configs/api_config.json"
const APP_CONFIG_PATH = "res://resources/configs/app_config.json" 
const TRANSLATION_CONFIG_PATH = "res://resources/configs/translation_config.json"

# 用户数据路径（打包后使用）
const USER_CONFIG_DIR = "user://configs/"
const USER_API_CONFIG_PATH = USER_CONFIG_DIR + "api_config.json"
const USER_APP_CONFIG_PATH = USER_CONFIG_DIR + "app_config.json"
const USER_TRANSLATION_CONFIG_PATH = USER_CONFIG_DIR + "translation_config.json"

# 应用程序名称（确保与project.godot中的config/name一致）
const APP_NAME = "moyi_translate_py"

var api_config: Dictionary
var app_config: Dictionary
var translation_config: Dictionary
var is_exported: bool = false

func _init():
	# 检查是否为导出版本
	is_exported = OS.has_feature("standalone")
	if is_exported:
		print("检测到导出环境，将使用用户配置目录")
	
	# 确保用户配置目录存在
	_ensure_user_config_dir()
	
	# 如果是导出版本且用户配置不存在，则复制默认配置
	if is_exported:
		_copy_default_configs_if_needed()
	
	# 加载配置
	load_all_configs()

## 确保用户配置目录存在
func _ensure_user_config_dir():
	if not DirAccess.dir_exists_absolute(USER_CONFIG_DIR):
		var dir = DirAccess.open("user://")
		if dir:
			dir.make_dir_recursive("configs")
			print("创建用户配置目录: " + USER_CONFIG_DIR)

## 如果需要，将默认配置复制到用户目录
func _copy_default_configs_if_needed():
	_copy_config_if_needed(API_CONFIG_PATH, USER_API_CONFIG_PATH)
	_copy_config_if_needed(APP_CONFIG_PATH, USER_APP_CONFIG_PATH)
	_copy_config_if_needed(TRANSLATION_CONFIG_PATH, USER_TRANSLATION_CONFIG_PATH)

## 如果用户配置不存在，则复制默认配置
func _copy_config_if_needed(src_path: String, dst_path: String):
	if FileAccess.file_exists(dst_path):
		return
	
	if FileAccess.file_exists(src_path):
		var src_file = FileAccess.open(src_path, FileAccess.READ)
		if src_file:
			var content = src_file.get_as_text()
			src_file.close()
			
			var dst_file = FileAccess.open(dst_path, FileAccess.WRITE)
			if dst_file:
				dst_file.store_string(content)
				dst_file.close()
				print("复制默认配置到: " + dst_path)
			else:
				print("警告: 无法创建配置文件: " + dst_path)
	else:
		print("警告: 默认配置文件不存在: " + src_path)

## 加载所有配置文件
func load_all_configs():
	if is_exported:
		# 导出环境下使用用户配置
		api_config = _load_json_config(USER_API_CONFIG_PATH)
		app_config = _load_json_config(USER_APP_CONFIG_PATH)
		translation_config = _load_json_config(USER_TRANSLATION_CONFIG_PATH)
	else:
		# 开发环境使用资源配置
		api_config = _load_json_config(API_CONFIG_PATH)
		app_config = _load_json_config(APP_CONFIG_PATH)
		translation_config = _load_json_config(TRANSLATION_CONFIG_PATH)

## 加载JSON配置文件
func _load_json_config(path: String) -> Dictionary:
	# 尝试打开配置文件
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("警告: 无法加载配置文件 ", path)
		print("  - 文件存在检查: ", FileAccess.file_exists(path))
		print("  - 完整路径: ", ProjectSettings.globalize_path(path))
		
		# 如果是用户配置文件，尝试从默认配置复制
		if is_exported and path.begins_with(USER_CONFIG_DIR):
			var default_path = ""
			if path == USER_API_CONFIG_PATH:
				default_path = API_CONFIG_PATH
			elif path == USER_APP_CONFIG_PATH:
				default_path = APP_CONFIG_PATH
			elif path == USER_TRANSLATION_CONFIG_PATH:
				default_path = TRANSLATION_CONFIG_PATH
				
			if not default_path.is_empty():
				print("  - 尝试从默认配置复制: ", default_path)
				_copy_config_if_needed(default_path, path)
				
				# 重新尝试打开
				file = FileAccess.open(path, FileAccess.READ)
				if not file:
					print("  - 复制后仍无法打开: ", path)
					return {}
		else:
			return {}
	
	# 读取并解析配置
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("错误: 解析配置文件失败 ", path, " - ", json.error_string)
		return {}
	
	print("✅ 成功加载配置: ", path)
	return json.data

## 保存配置文件
func save_config(config_type: String, config_data: Dictionary) -> bool:
	var path = ""
	
	# 根据环境和配置类型确定保存路径
	if is_exported:
		# 导出环境下使用用户配置路径
		match config_type:
			"api":
				path = USER_API_CONFIG_PATH
				api_config = config_data
			"app":
				path = USER_APP_CONFIG_PATH
				app_config = config_data
			"translation":
				path = USER_TRANSLATION_CONFIG_PATH
				translation_config = config_data
			_:
				print("错误: 未知的配置类型 ", config_type)
				return false
	else:
		# 开发环境使用资源路径
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
	
	# 确保目录存在
	if is_exported:
		_ensure_user_config_dir()
	
	# 保存配置
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		print("错误: 无法保存配置文件 ", path)
		return false
	
	var json_string = JSON.stringify(config_data, "\t")
	file.store_string(json_string)
	file.close()
	print("✅ 已保存配置到: " + path)
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
	
	var final_languages = []
	var processed_codes = []

	# 1. 处理基础语言列表，并应用自定义修改
	for lang in base_languages:
		var lang_copy = lang.duplicate()
		var code = lang_copy.code
		
		if custom_mappings.has(code) and custom_mappings[code] is Dictionary:
			var custom = custom_mappings[code]
			if custom.has("name"):
				lang_copy.name = custom.name
			if custom.has("native_name"):
				lang_copy.native_name = custom.native_name
			if custom.has("description"):
				lang_copy.description = custom.description
		
		final_languages.append(lang_copy)
		processed_codes.append(code)

	# 2. 添加不在基础列表中的全新自定义语言
	for code in custom_mappings:
		if not code in processed_codes:
			var custom_lang = custom_mappings[code]
			var new_lang_entry = {
				"code": code,
				"name": custom_lang.get("name", code),
				"native_name": custom_lang.get("native_name", code),
				"description": custom_lang.get("description", code)
			}
			final_languages.append(new_lang_entry)
			
	return final_languages

## 获取知识库配置
func get_knowledge_base_config() -> Dictionary:
	return app_config.get("knowledge_base", {
		"enabled": false,
		"root_path": "data/knowledge_base/",
		"auto_backup": true,
		"max_cache_size": 1000,
		"similarity_threshold": 0.6
	})

## 设置知识库启用状态
func set_knowledge_base_enabled(enabled: bool) -> bool:
	if not app_config.has("knowledge_base"):
		app_config["knowledge_base"] = {}
	
	app_config.knowledge_base.enabled = enabled
	return save_config("app", app_config)

## 获取知识库启用状态
func is_knowledge_base_enabled() -> bool:
	var kb_config = get_knowledge_base_config()
	return kb_config.get("enabled", false)

## 设置知识库根路径
func set_knowledge_base_root_path(path: String) -> bool:
	if not app_config.has("knowledge_base"):
		app_config["knowledge_base"] = {}
	
	# 确保路径以/结尾
	if not path.ends_with("/"):
		path += "/"
	
	app_config.knowledge_base.root_path = path
	return save_config("app", app_config)

## 获取知识库根路径
func get_knowledge_base_root_path() -> String:
	var kb_config = get_knowledge_base_config()
	return kb_config.get("root_path", "data/knowledge_base/")

## 设置知识库相似度阈值
func set_knowledge_base_similarity_threshold(threshold: float) -> bool:
	if not app_config.has("knowledge_base"):
		app_config["knowledge_base"] = {}
	
	app_config.knowledge_base.similarity_threshold = threshold
	return save_config("app", app_config)

## 设置知识库缓存大小
func set_knowledge_base_cache_size(size: int) -> bool:
	if not app_config.has("knowledge_base"):
		app_config["knowledge_base"] = {}
	
	app_config.knowledge_base.max_cache_size = size
	return save_config("app", app_config)

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

## 获取配置路径信息（用于调试）
func get_config_paths_info() -> String:
	var info = "配置路径信息:"
	info += "\n- 应用程序名称: " + APP_NAME
	info += "\n- 运行环境: " + ("导出版本" if is_exported else "开发环境")
	info += "\n- 项目位置: " + OS.get_executable_path().get_base_dir()
	info += "\n- 用户数据: " + OS.get_user_data_dir()
	info += "\n- 用户配置目录: " + ProjectSettings.globalize_path(USER_CONFIG_DIR)
	
	info += "\n\nAPI配置:"
	info += "\n- 路径: " + (USER_API_CONFIG_PATH if is_exported else API_CONFIG_PATH)
	info += "\n- 存在: " + str(FileAccess.file_exists(USER_API_CONFIG_PATH if is_exported else API_CONFIG_PATH))
	
	info += "\n\n应用配置:"
	info += "\n- 路径: " + (USER_APP_CONFIG_PATH if is_exported else APP_CONFIG_PATH)
	info += "\n- 存在: " + str(FileAccess.file_exists(USER_APP_CONFIG_PATH if is_exported else APP_CONFIG_PATH))
	
	info += "\n\n翻译配置:"
	info += "\n- 路径: " + (USER_TRANSLATION_CONFIG_PATH if is_exported else TRANSLATION_CONFIG_PATH)
	info += "\n- 存在: " + str(FileAccess.file_exists(USER_TRANSLATION_CONFIG_PATH if is_exported else TRANSLATION_CONFIG_PATH))
	
	return info 
