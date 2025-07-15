extends Node

## 语言管理器
## 处理UI多语言切换和本地化功能

signal language_changed(new_language: String)

const TRANSLATION_CSV_PATH = "res://resources/languages/ui_translations.csv"
const CONFIG_FILE_PATH = "user://language_config.cfg"

var current_language: String = "en"
var translations: Dictionary = {}
var supported_languages: Array[String] = ["en", "zh"]

func _ready():
	load_translations()
	load_saved_language()
	auto_detect_language()

## 加载翻译数据
func load_translations():
	translations.clear()
	
	if not FileAccess.file_exists(TRANSLATION_CSV_PATH):
		print("❌ 翻译文件不存在: " + TRANSLATION_CSV_PATH)
		return
	
	var file = FileAccess.open(TRANSLATION_CSV_PATH, FileAccess.READ)
	if not file:
		print("❌ 无法打开翻译文件: " + TRANSLATION_CSV_PATH)
		return
	
	var headers = file.get_csv_line()
	if headers.size() < 3:
		print("❌ CSV格式不正确")
		file.close()
		return
	
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() >= 3:
			var key = line[0]
			var en_text = line[1]
			var zh_text = line[2]
			
			translations[key] = {
				"en": en_text,
				"zh": zh_text
			}
	
	file.close()
	print("✅ 翻译数据加载完成，共加载 " + str(translations.size()) + " 条翻译")

## 自动检测语言
func auto_detect_language():
	var locale = OS.get_locale()
	print("🌍 系统区域设置: " + locale)
	
	# 检测中文区域
	var is_chinese_region = locale.begins_with("zh") or locale.begins_with("CN") or \
							locale.contains("HK") or locale.contains("TW") or \
							locale.contains("MO")
	
	if is_chinese_region:
		set_language("zh")
	else:
		set_language("en")

## 设置语言
func set_language(language: String) -> bool:
	if not language in supported_languages:
		print("❌ 不支持的语言: " + language)
		return false
	
	current_language = language
	save_language_config()
	language_changed.emit(current_language)
	print("🌐 语言已切换为: " + current_language)
	return true

## 获取翻译文本
func tr(key: String) -> String:
	if translations.has(key) and translations[key].has(current_language):
		return translations[key][current_language]
	
	return key

## 保存语言配置
func save_language_config():
	var config = ConfigFile()
	config.set_value("language", "current", current_language)
	config.save(CONFIG_FILE_PATH)
	print("💾 语言配置已保存")

## 加载保存的语言配置
func load_saved_language():
	var config = ConfigFile()
	if config.load(CONFIG_FILE_PATH) == OK:
		var saved_language = config.get_value("language", "current", "")
		if saved_language in supported_languages:
			current_language = saved_language
			print("💾 已加载保存的语言配置: " + current_language)

## 获取当前语言
func get_current_language() -> String:
	return current_language

## 切换语言
func toggle_language():
	if current_language == "en":
		set_language("zh")
	else:
		set_language("en")