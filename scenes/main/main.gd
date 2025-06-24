extends Control

## AI翻译游戏开发工具 - 主界面控制器
## 
## 作者: 鹏砚 (Drinkwang)
## B站: https://space.bilibili.com/13061595
## GitHub: https://github.com/Drinkwang
## 
## 开发方式: 人机协作 (与Claude AI共同开发)
## 许可证: MIT License
## 
## 功能: 管理整个应用的主界面和核心翻译功能

@onready var translation_service: TranslationService
@onready var config_manager: ConfigManager

# UI节点引用
@onready var file_dialog: FileDialog = $FileDialog
@onready var save_file_dialog: FileDialog = $SaveFileDialog
@onready var progress_bar: ProgressBar = $VBoxContainer/ControlsContainer/ProgressContainer/ProgressBar
@onready var status_label: Label = $VBoxContainer/ControlsContainer/StatusLabel
@onready var source_text_edit: TextEdit = $VBoxContainer/TranslationContainer/SourceContainer/SourceTextEdit
@onready var target_text_edit: TextEdit = $VBoxContainer/TranslationContainer/TargetContainer/TargetTextEdit
@onready var translate_button: Button = $VBoxContainer/ControlsContainer/ButtonsContainer/TranslateButton
@onready var pause_button: Button = $VBoxContainer/ControlsContainer/ButtonsContainer/PauseButton
@onready var resume_button: Button = $VBoxContainer/ControlsContainer/ButtonsContainer/ResumeButton
@onready var cancel_button: Button = $VBoxContainer/ControlsContainer/ButtonsContainer/CancelButton
@onready var progress_label: Label = $VBoxContainer/ControlsContainer/ProgressContainer/ProgressLabel
@onready var current_translation_container: VBoxContainer = $VBoxContainer/ControlsContainer/CurrentTranslationContainer
@onready var current_original_label: Label = $VBoxContainer/ControlsContainer/CurrentTranslationContainer/CurrentOriginalLabel
@onready var current_translated_label: Label = $VBoxContainer/ControlsContainer/CurrentTranslationContainer/CurrentTranslatedLabel
@onready var language_option_source: OptionButton = $VBoxContainer/SettingsContainer/BasicSettingsContainer/LanguageContainer/LanguageOptionSource
@onready var language_option_target: OptionButton = $VBoxContainer/SettingsContainer/BasicSettingsContainer/LanguageContainer/LanguageOptionTarget
@onready var service_option: OptionButton = $VBoxContainer/SettingsContainer/BasicSettingsContainer/ServiceContainer/ServiceOption

# 新增的UI节点引用
@onready var mode_option: OptionButton = $VBoxContainer/SettingsContainer/ModeContainer/ModeOption
@onready var basic_settings_container: HBoxContainer = $VBoxContainer/SettingsContainer/BasicSettingsContainer
@onready var godot_settings_container: VBoxContainer = $VBoxContainer/SettingsContainer/GodotSettingsContainer
@onready var file_button: Button = $VBoxContainer/SettingsContainer/GodotSettingsContainer/FileContainer/FileButton
@onready var source_lang_input: LineEdit = $VBoxContainer/SettingsContainer/GodotSettingsContainer/LanguageInputContainer/SourceLangInput
@onready var target_langs_input: LineEdit = $VBoxContainer/SettingsContainer/GodotSettingsContainer/LanguageInputContainer/TargetLangsInput
@onready var service_config_button: Button = $VBoxContainer/SettingsContainer/ModeContainer/ServiceConfigButton
@onready var language_config_button: Button = $VBoxContainer/SettingsContainer/ModeContainer/LanguageConfigButton
@onready var service_option_csv: OptionButton = $VBoxContainer/SettingsContainer/GodotSettingsContainer/ServiceContainer/ServiceOptionCSV
@onready var output_path_label: Label = $VBoxContainer/SettingsContainer/GodotSettingsContainer/OutputContainer/OutputPathLabel
@onready var save_as_button: Button = $VBoxContainer/SettingsContainer/GodotSettingsContainer/OutputContainer/SaveAsButton

# AI配置对话框节点引用
@onready var ai_config_dialog: AcceptDialog = $AIConfigDialog
@onready var openai_enabled: CheckBox = $AIConfigDialog/VBoxContainer/TabContainer/OpenAI/EnabledCheck
@onready var openai_api_key: LineEdit = $AIConfigDialog/VBoxContainer/TabContainer/OpenAI/APIKeyContainer/APIKeyInput
@onready var openai_base_url: LineEdit = $AIConfigDialog/VBoxContainer/TabContainer/OpenAI/BaseURLInput
@onready var openai_model: LineEdit = $AIConfigDialog/VBoxContainer/TabContainer/OpenAI/ModelInput
@onready var claude_enabled: CheckBox = $AIConfigDialog/VBoxContainer/TabContainer/Claude/EnabledCheck
@onready var claude_api_key: LineEdit = $AIConfigDialog/VBoxContainer/TabContainer/Claude/APIKeyContainer/APIKeyInput
@onready var claude_base_url: LineEdit = $AIConfigDialog/VBoxContainer/TabContainer/Claude/BaseURLInput
@onready var claude_model: LineEdit = $AIConfigDialog/VBoxContainer/TabContainer/Claude/ModelInput
@onready var baidu_enabled: CheckBox = $"AIConfigDialog/VBoxContainer/TabContainer/百度翻译/EnabledCheck"
@onready var baidu_app_id: LineEdit = $"AIConfigDialog/VBoxContainer/TabContainer/百度翻译/AppIDInput"
@onready var baidu_secret_key: LineEdit = $"AIConfigDialog/VBoxContainer/TabContainer/百度翻译/SecretKeyContainer/SecretKeyInput"
@onready var local_enabled: CheckBox = $"AIConfigDialog/VBoxContainer/TabContainer/本地模型/EnabledCheck"
@onready var local_base_url: LineEdit = $"AIConfigDialog/VBoxContainer/TabContainer/本地模型/BaseURLInput"
@onready var local_model: LineEdit = $"AIConfigDialog/VBoxContainer/TabContainer/本地模型/ModelInput"
@onready var local_provider: OptionButton = $"AIConfigDialog/VBoxContainer/TabContainer/本地模型/ProviderOption"
@onready var deepseek_enabled: CheckBox = $"AIConfigDialog/VBoxContainer/TabContainer/DeepSeek/EnabledCheck"
@onready var deepseek_api_key: LineEdit = $"AIConfigDialog/VBoxContainer/TabContainer/DeepSeek/APIKeyContainer/APIKeyInput"
@onready var deepseek_base_url: LineEdit = $"AIConfigDialog/VBoxContainer/TabContainer/DeepSeek/BaseURLInput"
@onready var deepseek_model: LineEdit = $"AIConfigDialog/VBoxContainer/TabContainer/DeepSeek/ModelInput"

# 显示/隐藏密钥按钮引用
@onready var openai_toggle_button: Button = $AIConfigDialog/VBoxContainer/TabContainer/OpenAI/APIKeyContainer/ToggleVisibilityButton
@onready var claude_toggle_button: Button = $AIConfigDialog/VBoxContainer/TabContainer/Claude/APIKeyContainer/ToggleVisibilityButton
@onready var baidu_toggle_button: Button = $"AIConfigDialog/VBoxContainer/TabContainer/百度翻译/SecretKeyContainer/ToggleVisibilityButton"
@onready var deepseek_toggle_button: Button = $"AIConfigDialog/VBoxContainer/TabContainer/DeepSeek/APIKeyContainer/ToggleVisibilityButton"
@onready var test_button: Button = $AIConfigDialog/VBoxContainer/ButtonContainer/TestButton
@onready var save_button: Button = $AIConfigDialog/VBoxContainer/ButtonContainer/SaveButton
@onready var reset_button: Button = $AIConfigDialog/VBoxContainer/ButtonContainer/ResetButton

# 语言配置对话框节点引用
@onready var language_config_dialog: AcceptDialog = $LanguageConfigDialog
@onready var language_list: VBoxContainer = $LanguageConfigDialog/VBoxContainer/ScrollContainer/LanguageList
@onready var code_input: LineEdit = $LanguageConfigDialog/VBoxContainer/AddLanguageContainer/CodeInput
@onready var name_input: LineEdit = $LanguageConfigDialog/VBoxContainer/AddLanguageContainer/NameInput
@onready var add_language_button: Button = $LanguageConfigDialog/VBoxContainer/AddLanguageContainer/AddButton
@onready var save_language_button: Button = $LanguageConfigDialog/VBoxContainer/ButtonContainer/SaveLanguageButton
@onready var reset_language_button: Button = $LanguageConfigDialog/VBoxContainer/ButtonContainer/ResetLanguageButton

# 翻译模式
enum TranslationMode {
	BASIC,    # 基础文本翻译
	GODOT_CSV # Godot CSV翻译
}

var current_mode: TranslationMode = TranslationMode.BASIC
var selected_csv_file: String = ""
var output_csv_file: String = ""

func _ready():
	_initialize_services()
	_setup_ui()
	_connect_signals()

## 初始化服务
func _initialize_services():
	translation_service = TranslationService.new()
	config_manager = ConfigManager.new()
	print("✅ 服务初始化完成")

## 设置UI
func _setup_ui():
	_debug_ui_nodes()
	_setup_mode_options()
	_populate_language_options()
	_populate_service_options()
	_load_ui_settings()
	_update_ui_for_mode()
	_check_service_status()

## 连接翻译服务信号
func _connect_translation_service_signals():
	if translation_service:
		translation_service.translation_completed.connect(_on_translation_completed)
		translation_service.translation_failed.connect(_on_translation_failed)
		translation_service.translation_progress.connect(_on_translation_progress)
		translation_service.translation_item_started.connect(_on_translation_item_started)
		translation_service.translation_item_completed.connect(_on_translation_item_completed)
		translation_service.translation_paused.connect(_on_translation_paused)
		translation_service.translation_resumed.connect(_on_translation_resumed)
		translation_service.translation_cancelled.connect(_on_translation_cancelled)
		print("✅ 翻译服务信号连接完成")
	else:
		print("❌ 翻译服务未初始化，无法连接信号")

## 连接信号
func _connect_signals():
	_connect_translation_service_signals()
	
	if translate_button:
		translate_button.pressed.connect(_on_translate_button_pressed)
		print("✅ 翻译按钮信号连接完成")
	
	if pause_button:
		pause_button.pressed.connect(_on_pause_button_pressed)
		print("✅ 暂停按钮信号连接完成")
	
	if resume_button:
		resume_button.pressed.connect(_on_resume_button_pressed)
		print("✅ 恢复按钮信号连接完成")
	
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_button_pressed)
		print("✅ 取消按钮信号连接完成")
	
	if mode_option:
		mode_option.item_selected.connect(_on_mode_changed)
	
	if file_button:
		file_button.pressed.connect(_on_file_button_pressed)
	
	if file_dialog:
		file_dialog.file_selected.connect(_on_csv_file_selected)
	
	if save_as_button:
		save_as_button.pressed.connect(_on_save_as_button_pressed)
	
	if save_file_dialog:
		save_file_dialog.file_selected.connect(_on_output_file_selected)
	
	if service_config_button:
		service_config_button.pressed.connect(_on_service_config_button_pressed)
	
	if language_config_button:
		language_config_button.pressed.connect(_on_language_config_button_pressed)
	
	if save_button:
		save_button.pressed.connect(_on_save_config_pressed)
	
	if test_button:
		test_button.pressed.connect(_on_test_connection_pressed)
	
	if reset_button:
		reset_button.pressed.connect(_on_reset_config_pressed)
	
	if add_language_button:
		add_language_button.pressed.connect(_on_add_language_pressed)
	
	if save_language_button:
		save_language_button.pressed.connect(_on_save_language_config_pressed)
	
	if reset_language_button:
		reset_language_button.pressed.connect(_on_reset_language_config_pressed)
	
	# 连接密钥显示/隐藏按钮信号
	if openai_toggle_button:
		openai_toggle_button.pressed.connect(_on_toggle_visibility.bind(openai_api_key, openai_toggle_button))
	if claude_toggle_button:
		claude_toggle_button.pressed.connect(_on_toggle_visibility.bind(claude_api_key, claude_toggle_button))
	if baidu_toggle_button:
		baidu_toggle_button.pressed.connect(_on_toggle_visibility.bind(baidu_secret_key, baidu_toggle_button))
	if deepseek_toggle_button:
		deepseek_toggle_button.pressed.connect(_on_toggle_visibility.bind(deepseek_api_key, deepseek_toggle_button))

## 填充语言选项
func _populate_language_options():
	if not config_manager:
		print("错误: config_manager 未初始化")
		return
	
	var languages = config_manager.get_supported_languages()
	
	if not language_option_source:
		print("错误: language_option_source 节点未找到")
	else:
		language_option_source.clear()
		for lang in languages:
			language_option_source.add_item(lang.native_name + " (" + lang.name + ")", lang.code.hash())
		print("已加载 ", languages.size(), " 种源语言选项")
	
	if not language_option_target:
		print("错误: language_option_target 节点未找到")
	else:
		language_option_target.clear()
		for lang in languages:
			language_option_target.add_item(lang.native_name + " (" + lang.name + ")", lang.code.hash())
		print("已加载 ", languages.size(), " 种目标语言选项")

## 填充服务选项
func _populate_service_options():
	_populate_single_service_option(service_option, "基础翻译")
	_populate_single_service_option(service_option_csv, "CSV翻译")

## 填充单个服务选项下拉框
func _populate_single_service_option(option_button: OptionButton, mode_name: String):
	if not option_button:
		print("错误: ", mode_name, " service_option 节点未找到")
		return
	
	option_button.clear()
	
	if not translation_service:
		print("错误: translation_service 未初始化")
		option_button.add_item("服务未可用", 0)
		return
		
	var ai_manager = translation_service.ai_service_manager
	if not ai_manager:
		print("错误: ai_service_manager 未初始化")
		option_button.add_item("AI服务管理器未可用", 0)
		return
		
	var available_services = ai_manager.get_available_services()
	
	if available_services.is_empty():
		# 如果没有可用服务，提示用户配置
		option_button.add_item("⚠️ 请先配置AI服务", 0)
		print("警告: ", mode_name, " 没有可用的AI服务，请配置API密钥")
	else:
		for service_info in available_services:
			option_button.add_item(service_info.display_name, service_info.name.hash())
		print("已为 ", mode_name, " 加载 ", available_services.size(), " 个AI服务")

## 加载UI设置
func _load_ui_settings():
	var app_config = config_manager.get_app_config()
	var ui_config = app_config.get("ui", {})
	
	# 设置窗口大小
	var window_size = ui_config.get("window_size", {"width": 1200, "height": 800})
	get_window().size = Vector2i(window_size.width, window_size.height)

## 翻译按钮点击事件
func _on_translate_button_pressed():
	match current_mode:
		TranslationMode.BASIC:
			await _handle_basic_translation()
		TranslationMode.GODOT_CSV:
			await _handle_godot_csv_translation()

## 处理基础文本翻译
func _handle_basic_translation():
	var source_text = source_text_edit.text if source_text_edit else ""
	if source_text.is_empty():
		_show_status("请输入要翻译的文本", true)
		return
	
	var source_lang = _get_selected_language(language_option_source)
	var target_lang = _get_selected_language(language_option_target)
	var service_name = _get_selected_service()
	
	if source_lang.is_empty() or target_lang.is_empty():
		_show_status("请选择源语言和目标语言", true)
		return
	
	if service_name.is_empty():
		return  # 错误信息已在_get_selected_service()中显示
	
	# 开始翻译
	_show_status("正在翻译...", false)
	_update_translation_buttons(false, true, false, true)  # 禁用翻译和恢复，启用暂停和取消
	
	var result = await translation_service.translate_text(source_text, source_lang, target_lang, service_name)
	
	if result.success:
		if target_text_edit:
			target_text_edit.text = result.translated_text
		_show_status("翻译完成", false)
	else:
		_show_status("翻译失败: " + result.error, true)
	
	_update_translation_buttons(true, false, false, false)  # 恢复为初始状态

## 处理Godot CSV翻译
func _handle_godot_csv_translation():
	# 验证输入
	if selected_csv_file.is_empty():
		_show_status("请先选择CSV文件", true)
		return
	
	if output_csv_file.is_empty():
		_show_status("请设置输出文件路径", true)
		return
	
	var source_lang = source_lang_input.text.strip_edges() if source_lang_input else ""
	var target_langs_text = target_langs_input.text.strip_edges() if target_langs_input else ""
	
	# 如果输入框为空，使用默认值
	var using_default = false
	if source_lang.is_empty():
		source_lang = "zh"  # 默认源语言为中文
		using_default = true
	
	if target_langs_text.is_empty():
		target_langs_text = "en,ja,ru,lzh"  # 默认目标语言：英语,日语,俄语,繁体中文
		using_default = true
	
	# 显示使用的语言设置
	if using_default:
		_show_status("语言设置 - 源语言: " + source_lang + " → 目标语言: " + target_langs_text, false)
	
	# 提示用户智能增量翻译逻辑
	print("💡 智能增量翻译提示：")
	print("   - 自动跳过已有翻译的行，只翻译空的目标语言行")
	print("   - 支持多语言混合翻译（例如：en已翻译，lzh为空）")
	print("   - 保持现有翻译不变，只填补缺失的翻译")
	print("   - 适合增量翻译和多轮翻译工作流")
	
	# 解析目标语言列表
	var target_languages = []
	for lang in target_langs_text.split(","):
		var clean_lang = lang.strip_edges()
		if clean_lang.length() > 0:
			target_languages.append(clean_lang)
	
	if target_languages.is_empty():
		_show_status("请输入有效的目标语言代码", true)
		return
	
	var service_name = _get_selected_service()
	
	# 检查服务是否可用
	if service_name.is_empty():
		return  # 错误信息已在_get_selected_service()中显示
	
	# 开始翻译
	_show_status("正在翻译Godot CSV文件...", false)
	_update_translation_buttons(false, true, false, true)  # 禁用翻译和恢复，启用暂停和取消
	
	# 设置CSV模式下的UI：将文本框改为只读显示模式
	_setup_csv_display_mode(true)
	
	# 显示进度条和翻译状态容器
	if progress_bar:
		progress_bar.value = 0
		progress_bar.visible = true
		print("📊 [进度条初始化] 设置初始值: 0, 可见性: true, 范围: ", progress_bar.min_value, "-", progress_bar.max_value)
	else:
		print("❌ [进度条错误] progress_bar 为 null，无法初始化")
	
	if current_translation_container:
		current_translation_container.visible = true
	
	if progress_label:
		progress_label.text = "进度: 准备开始..."
	
	# 清空文本框和缓存，准备新的翻译
	if source_text_edit:
		source_text_edit.text = ""
		source_text_edit.placeholder_text = "CSV翻译原文累积显示"
	
	if target_text_edit:
		target_text_edit.text = ""
		target_text_edit.placeholder_text = "CSV翻译译文累积显示"
	
	# 清理缓存，准备新的翻译
	set_meta("source_lines_cache", [])
	set_meta("target_lines_cache", [])
	set_meta("last_ui_update_index", -1)
	print("📝 [性能优化] 已清理缓存，准备开始新的翻译")
	
	# 传递输出文件路径给翻译服务
	var result = await translation_service.translate_godot_csv_with_output(selected_csv_file, output_csv_file, source_lang, target_languages, service_name)
	
	if result.success:
		var added_langs = result.get("languages_added", [])
		_show_status("翻译完成！已添加语言: " + str(added_langs) + "\n输出文件: " + output_csv_file, false)
		
		# 确保最终UI更新 - 显示所有缓存的翻译结果
		var source_lines = get_meta("source_lines_cache") if has_meta("source_lines_cache") else []
		var target_lines = get_meta("target_lines_cache") if has_meta("target_lines_cache") else []
		
		if source_lines.size() > 0:
			if source_text_edit:
				source_text_edit.text = "\n".join(source_lines)
			if target_text_edit:
				target_text_edit.text = "\n".join(target_lines)
		
		print("📊 [完成] CSV翻译已完成，最终UI更新完成")
		
		# 在末尾添加完成信息
		if target_text_edit:
			var success_count = target_lines.size()
			
			# 添加完成信息
			if target_text_edit.text.strip_edges().length() > 0:
				target_text_edit.text += "\n--- ✅ 翻译完成！语言: " + ", ".join(added_langs) + "，成功: " + str(success_count) + " 项 ---"
			else:
				target_text_edit.text = "✅ 翻译完成！\n语言: " + ", ".join(added_langs) + "\n成功: " + str(success_count) + " 项"
			print("📊 [完成] 翻译结束，成功显示 %d 项" % success_count)
	else:
		_show_status("翻译失败: " + result.error, true)
		if target_text_edit:
			target_text_edit.text = "❌ CSV翻译失败: " + result.error
	
	_update_translation_buttons(true, false, false, false)  # 恢复为初始状态
	
	# 恢复CSV模式下的正常UI状态
	if current_mode == TranslationMode.GODOT_CSV:
		_setup_csv_display_mode(false)
	
	# 隐藏和重置翻译状态显示
	if current_translation_container:
		current_translation_container.visible = false
	
	if progress_bar:
		progress_bar.visible = false
	
	if progress_label:
		progress_label.text = "进度: 已完成"
	
	if current_original_label:
		current_original_label.text = "原文: "
	
	if current_translated_label:
		current_translated_label.text = "译文: "

## 获取选中的语言
func _get_selected_language(option_button: OptionButton) -> String:
	if not option_button or option_button.selected < 0:
		return ""
	
	var languages = config_manager.get_supported_languages()
	if option_button.selected < languages.size():
		return languages[option_button.selected].code
	return ""

## 获取选中的服务
func _get_selected_service() -> String:
	# 根据当前模式选择正确的服务选项按钮
	var current_service_option = service_option
	if current_mode == TranslationMode.GODOT_CSV:
		current_service_option = service_option_csv
	
	if not current_service_option or current_service_option.selected < 0:
		return "openai"  # 默认返回openai
	
	if not translation_service or not translation_service.ai_service_manager:
		_show_status("翻译服务未初始化，请先配置AI服务", true)
		return ""
	
	var ai_manager = translation_service.ai_service_manager
	var available_services = ai_manager.get_available_services()
	
	if available_services.is_empty():
		_show_status("没有可用的AI服务，请先配置API密钥", true)
		return ""
	elif current_service_option.selected < available_services.size():
		return available_services[current_service_option.selected].name
	
	# 默认返回第一个可用服务
	return available_services[0].name if not available_services.is_empty() else ""

## 显示状态信息
func _show_status(message: String, is_error: bool = false):
	if status_label:
		status_label.text = message
		status_label.modulate = Color.RED if is_error else Color.WHITE
	
	print("状态: ", message)
	
	# 如果是连接测试失败，添加额外的调试建议
	if is_error and ("连接" in message or "测试" in message):
		var debug_message = "\n=== 调试建议 ===\n"
		debug_message += "1. 检查网络连接是否正常\n"
		debug_message += "2. 确认API密钥是否正确\n"
		debug_message += "3. 检查防火墙是否阻止了HTTPS连接\n"
		debug_message += "4. 尝试在浏览器中访问 https://api.openai.com\n"
		debug_message += "5. 如果在中国大陆，可能需要科学上网\n"
		debug_message += "6. 查看上方的详细HTTP调试信息\n"
		debug_message += "================"
		print(debug_message)

## 翻译完成回调
func _on_translation_completed(result: Dictionary):
	print("翻译完成: ", result)

## 翻译失败回调
func _on_translation_failed(error: String):
	print("翻译失败: ", error)
	_show_status("翻译失败: " + error, true)

## 翻译进度回调
func _on_translation_progress(progress: float):
	var percentage = int(progress * 100)
	
	if progress_bar:
		progress_bar.value = progress * 100
		# 添加详细的进度条调试信息
		if percentage % 10 == 0 or percentage == 100:  # 每10%或100%时输出调试信息
			print("📊 [进度条调试] 设置进度: ", percentage, "% (", progress_bar.value, "/", progress_bar.max_value, ") 可见性: ", progress_bar.visible)
	else:
		print("❌ [进度条错误] progress_bar 为 null")
	
	# 减少频繁的进度输出，只在关键进度点输出
	if percentage % 10 == 0 or percentage == 100:  # 每10%或100%时输出
		print("📊 [总体进度] ", percentage, "%")
	
	# 如果progress_label当前没有显示详细信息，则显示百分比
	if progress_label and not progress_label.text.contains("正在翻译") and not progress_label.text.contains("已完成"):
		progress_label.text = "进度: " + str(percentage) + "%"



## 设置翻译模式选项
func _setup_mode_options():
	if not mode_option:
		return
	
	mode_option.clear()
	mode_option.add_item("基础文本翻译", TranslationMode.BASIC)
	mode_option.add_item("Godot多语言CSV", TranslationMode.GODOT_CSV)
	mode_option.selected = 0

## 更新UI以适应当前模式
func _update_ui_for_mode():
	if not basic_settings_container or not godot_settings_container:
		return
	
	match current_mode:
		TranslationMode.BASIC:
			basic_settings_container.visible = true
			godot_settings_container.visible = false
			if translate_button:
				translate_button.text = "翻译"
			# 在基础模式下恢复文本框的正常模式
			_setup_csv_display_mode(false)
		TranslationMode.GODOT_CSV:
			basic_settings_container.visible = false
			godot_settings_container.visible = true
			if translate_button:
				translate_button.text = "翻译CSV文件"
			# 在CSV模式下设置文本框为只读显示模式（未翻译时）
			_setup_csv_display_mode(false)

## 设置CSV显示模式
func _setup_csv_display_mode(is_translating: bool):
	# 在CSV模式下处理文本框的显示模式
	if current_mode == TranslationMode.GODOT_CSV:
		if source_text_edit:
			source_text_edit.editable = false  # CSV模式下始终不可编辑
			if is_translating:
				source_text_edit.placeholder_text = "CSV翻译原文累积显示（正在翻译中...）"
			else:
				source_text_edit.placeholder_text = "CSV翻译原文累积显示"
		
		if target_text_edit:
			target_text_edit.editable = false  # CSV模式下始终不可编辑
			if is_translating:
				target_text_edit.placeholder_text = "CSV翻译译文累积显示（正在翻译中...）"
			else:
				target_text_edit.placeholder_text = "CSV翻译译文累积显示"
				# 只在模式切换时才清空，保持累积的翻译内容
				if not is_translating and target_text_edit.text.strip_edges().is_empty():
					pass  # 保持现有累积内容
	else:
		# 基础模式下恢复正常的可编辑状态
		if source_text_edit:
			source_text_edit.editable = true
			source_text_edit.placeholder_text = "输入要翻译的文本"
		
		if target_text_edit:
			target_text_edit.editable = true
			target_text_edit.placeholder_text = "翻译结果"

## 模式切换回调
func _on_mode_changed(index: int):
	current_mode = index as TranslationMode
	_update_ui_for_mode()

## 文件选择按钮回调
func _on_file_button_pressed():
	if file_dialog:
		file_dialog.popup_centered()

## CSV文件选择回调
func _on_csv_file_selected(path: String):
	selected_csv_file = path
	if file_button:
		file_button.text = path.get_file()
	
	# 自动生成默认输出文件名
	var base_name = path.get_basename()
	output_csv_file = base_name + "_translated.csv"
	_update_output_path_display()
	
	_show_status("已选择文件: " + path.get_file(), false)

## 另存为按钮回调
func _on_save_as_button_pressed():
	if save_file_dialog:
		# 设置默认文件名
		if not output_csv_file.is_empty():
			save_file_dialog.current_file = output_csv_file.get_file()
		save_file_dialog.popup_centered()

## 输出文件选择回调
func _on_output_file_selected(path: String):
	output_csv_file = path
	_update_output_path_display()
	_show_status("输出文件设置为: " + path.get_file(), false)

## 更新输出路径显示
func _update_output_path_display():
	if output_path_label:
		if output_csv_file.is_empty():
			output_path_label.text = "请先选择输入文件"
		else:
			output_path_label.text = output_csv_file.get_file()

## 调试UI节点状态
func _debug_ui_nodes():
	print("=== UI节点调试信息 ===")
	print("mode_option: ", mode_option != null)
	print("basic_settings_container: ", basic_settings_container != null)
	print("godot_settings_container: ", godot_settings_container != null)
	print("language_option_source: ", language_option_source != null)
	print("language_option_target: ", language_option_target != null)
	print("service_option: ", service_option != null)
	print("service_option_csv: ", service_option_csv != null)
	print("file_button: ", file_button != null)
	print("source_lang_input: ", source_lang_input != null)
	print("target_langs_input: ", target_langs_input != null)
	print("translate_button: ", translate_button != null)
	print("progress_bar: ", progress_bar != null)
	if progress_bar:
		print("  - progress_bar.visible: ", progress_bar.visible)
		print("  - progress_bar.value: ", progress_bar.value)
		print("  - progress_bar.max_value: ", progress_bar.max_value)
		print("  - progress_bar.min_value: ", progress_bar.min_value)
	print("status_label: ", status_label != null)
	print("source_text_edit: ", source_text_edit != null)
	print("target_text_edit: ", target_text_edit != null)
	print("file_dialog: ", file_dialog != null)
	print("save_file_dialog: ", save_file_dialog != null)
	print("output_path_label: ", output_path_label != null)
	print("save_as_button: ", save_as_button != null)
	print("ai_config_dialog: ", ai_config_dialog != null)
	print("service_config_button: ", service_config_button != null)
	print("deepseek_enabled: ", deepseek_enabled != null)
	print("deepseek_api_key: ", deepseek_api_key != null)
	print("deepseek_base_url: ", deepseek_base_url != null)
	print("deepseek_model: ", deepseek_model != null)
	print("language_config_button: ", language_config_button != null)
	print("language_config_dialog: ", language_config_dialog != null)
	print("--- 翻译状态显示节点 ---")
	print("progress_label: ", progress_label != null)
	print("current_translation_container: ", current_translation_container != null)
	print("current_original_label: ", current_original_label != null)
	print("current_translated_label: ", current_translated_label != null)
	print("pause_button: ", pause_button != null)
	print("resume_button: ", resume_button != null)
	print("cancel_button: ", cancel_button != null)
	print("==================")

## AI服务配置按钮回调
func _on_service_config_button_pressed():
	if ai_config_dialog:
		_load_ai_config()
		_setup_local_provider_options()
		ai_config_dialog.popup_centered()

## 设置本地模型提供商选项
func _setup_local_provider_options():
	if local_provider:
		local_provider.clear()
		local_provider.add_item("Ollama", 0)
		local_provider.add_item("LocalAI", 1)
		local_provider.selected = 0

## 加载AI配置到对话框
func _load_ai_config():
	var api_config = config_manager.get_api_config()
	
	# OpenAI配置
	if openai_enabled and api_config.services.has("openai"):
		var openai_config = api_config.services.openai
		openai_enabled.button_pressed = openai_config.get("enabled", false)
		if openai_api_key:
			openai_api_key.text = openai_config.get("api_key", "")
		if openai_base_url:
			openai_base_url.text = openai_config.get("base_url", "https://api.openai.com/v1")
		if openai_model:
			openai_model.text = openai_config.get("model", "gpt-3.5-turbo")
	
	# Claude配置
	if claude_enabled and api_config.services.has("claude"):
		var claude_config = api_config.services.claude
		claude_enabled.button_pressed = claude_config.get("enabled", false)
		if claude_api_key:
			claude_api_key.text = claude_config.get("api_key", "")
		if claude_base_url:
			claude_base_url.text = claude_config.get("base_url", "https://api.anthropic.com")
		if claude_model:
			claude_model.text = claude_config.get("model", "claude-3-haiku-20240307")
	
	# 百度翻译配置
	if baidu_enabled and api_config.services.has("baidu"):
		var baidu_config = api_config.services.baidu
		baidu_enabled.button_pressed = baidu_config.get("enabled", false)
		if baidu_app_id:
			baidu_app_id.text = baidu_config.get("app_id", "")
		if baidu_secret_key:
			baidu_secret_key.text = baidu_config.get("secret_key", "")
	
	# 本地模型配置
	if local_enabled and api_config.services.has("local"):
		var local_config = api_config.services.local
		local_enabled.button_pressed = local_config.get("enabled", false)
		if local_base_url:
			local_base_url.text = local_config.get("base_url", "http://localhost:11434")
		if local_model:
			local_model.text = local_config.get("model", "llama2")
		if local_provider:
			var provider = local_config.get("provider", "ollama")
			local_provider.selected = 0 if provider == "ollama" else 1
	
	# DeepSeek配置
	if deepseek_enabled and api_config.services.has("deepseek"):
		var deepseek_config = api_config.services.deepseek
		deepseek_enabled.button_pressed = deepseek_config.get("enabled", false)
		if deepseek_api_key:
			deepseek_api_key.text = deepseek_config.get("api_key", "")
		if deepseek_base_url:
			deepseek_base_url.text = deepseek_config.get("base_url", "https://api.deepseek.com")
		if deepseek_model:
			deepseek_model.text = deepseek_config.get("model", "deepseek-chat")

## 保存配置按钮回调
func _on_save_config_pressed():
	var api_config = config_manager.get_api_config()
	
	# 更新OpenAI配置
	if api_config.services.has("openai"):
		var api_key = openai_api_key.text if openai_api_key else ""
		var is_enabled = openai_enabled.button_pressed if openai_enabled else false
		
		# 如果有API密钥但没有勾选启用，自动启用
		if not api_key.is_empty() and not is_enabled:
			is_enabled = true
			if openai_enabled:
				openai_enabled.button_pressed = true
		
		api_config.services.openai.enabled = is_enabled
		api_config.services.openai.api_key = api_key
		api_config.services.openai.base_url = openai_base_url.text if openai_base_url else "https://api.openai.com/v1"
		api_config.services.openai.model = openai_model.text if openai_model else "gpt-3.5-turbo"
	
	# 更新Claude配置
	if api_config.services.has("claude"):
		var api_key = claude_api_key.text if claude_api_key else ""
		var is_enabled = claude_enabled.button_pressed if claude_enabled else false
		
		# 如果有API密钥但没有勾选启用，自动启用
		if not api_key.is_empty() and not is_enabled:
			is_enabled = true
			if claude_enabled:
				claude_enabled.button_pressed = true
		
		api_config.services.claude.enabled = is_enabled
		api_config.services.claude.api_key = api_key
		api_config.services.claude.base_url = claude_base_url.text if claude_base_url else "https://api.anthropic.com"
		api_config.services.claude.model = claude_model.text if claude_model else "claude-3-haiku-20240307"
	
	# 更新百度翻译配置
	if api_config.services.has("baidu"):
		var app_id = baidu_app_id.text if baidu_app_id else ""
		var secret_key = baidu_secret_key.text if baidu_secret_key else ""
		var is_enabled = baidu_enabled.button_pressed if baidu_enabled else false
		
		# 如果有APP ID和密钥但没有勾选启用，自动启用
		if not app_id.is_empty() and not secret_key.is_empty() and not is_enabled:
			is_enabled = true
			if baidu_enabled:
				baidu_enabled.button_pressed = true
		
		api_config.services.baidu.enabled = is_enabled
		api_config.services.baidu.app_id = app_id
		api_config.services.baidu.secret_key = secret_key
	
	# 更新本地模型配置
	if api_config.services.has("local"):
		api_config.services.local.enabled = local_enabled.button_pressed if local_enabled else false
		api_config.services.local.base_url = local_base_url.text if local_base_url else "http://localhost:11434"
		api_config.services.local.model = local_model.text if local_model else "llama2"
		var provider_index = local_provider.selected if local_provider else 0
		api_config.services.local.provider = "ollama" if provider_index == 0 else "localai"
	
	# 更新DeepSeek配置
	if api_config.services.has("deepseek"):
		var api_key = deepseek_api_key.text if deepseek_api_key else ""
		var is_enabled = deepseek_enabled.button_pressed if deepseek_enabled else false
		
		# 如果有API密钥但没有勾选启用，自动启用
		if not api_key.is_empty() and not is_enabled:
			is_enabled = true
			if deepseek_enabled:
				deepseek_enabled.button_pressed = true
		
		api_config.services.deepseek.enabled = is_enabled
		api_config.services.deepseek.api_key = api_key
		api_config.services.deepseek.base_url = deepseek_base_url.text if deepseek_base_url else "https://api.deepseek.com"
		api_config.services.deepseek.model = deepseek_model.text if deepseek_model else "deepseek-chat"
	
	# 保存配置
	if config_manager.save_config("api", api_config):
		# 重新初始化翻译服务
		translation_service = TranslationService.new()
		# 重新连接翻译服务信号
		_connect_translation_service_signals()
		# 重新填充两个模式的服务选项
		_populate_service_options()
		
		# 检查现在有多少可用服务
		var ai_manager = translation_service.ai_service_manager
		var available_services = ai_manager.get_available_services()
		
		if available_services.size() > 0:
			var service_names = []
			for service in available_services:
				service_names.append(service.display_name)
			_show_status("✅ 配置保存成功！可用服务: " + ", ".join(service_names) + "\n现在可以进行真实翻译了！", false)
		else:
			_show_status("配置已保存，但没有可用服务。请填写API密钥并启用服务。", true)
		
		if ai_config_dialog:
			ai_config_dialog.hide()
	else:
		_show_status("保存配置失败", true)

## 测试连接按钮回调
func _on_test_connection_pressed():
	_show_status("正在测试当前服务...", false)
	
	# 获取当前选中的标签页对应的服务
	var current_service = _get_current_tab_service()
	if current_service.is_empty():
		_show_status("❌ 无法确定当前选中的服务", true)
		return
	
	print("开始测试当前选中的服务: ", current_service)
	
	# 跳过网络测试，直接测试当前服务
	_show_status("正在测试 " + current_service + " 服务...", false)
	
	# 创建临时的翻译服务来测试
	var temp_translation_service = TranslationService.new()
	var ai_manager = temp_translation_service.ai_service_manager
	
	var result = await ai_manager.test_service(current_service)
	
	if result.success:
		print("✅ ", current_service, " 测试成功")
		_show_status("✅ " + current_service + " 连接测试成功！", false)
	else:
		print("❌ ", current_service, " 测试失败: ", result.error)
		_show_status("❌ " + current_service + " 连接失败:\n" + result.error, true)

## 获取当前选中标签页对应的服务名称
func _get_current_tab_service() -> String:
	# 查找TabContainer
	var tab_container = ai_config_dialog.find_child("TabContainer")
	if not tab_container:
		print("❌ 找不到TabContainer")
		return ""
	
	var current_tab = tab_container.current_tab
	print("当前标签页索引: ", current_tab)
	
	# 根据标签页索引确定服务名称
	match current_tab:
		0:  # OpenAI
			return "openai"
		1:  # Claude
			return "claude" 
		2:  # 百度翻译
			return "baidu"
		3:  # 本地模型
			return "local"
		4:  # DeepSeek
			return "deepseek"
		_:
			print("❌ 未知的标签页索引: ", current_tab)
			return ""

## 重置配置按钮回调
func _on_reset_config_pressed():
	# 重置为默认值
	if openai_enabled:
		openai_enabled.button_pressed = false
	if openai_api_key:
		openai_api_key.text = ""
	if openai_base_url:
		openai_base_url.text = "https://api.openai.com/v1"
	if openai_model:
		openai_model.text = "gpt-3.5-turbo"
	
	if claude_enabled:
		claude_enabled.button_pressed = false
	if claude_api_key:
		claude_api_key.text = ""
	if claude_base_url:
		claude_base_url.text = "https://api.anthropic.com"
	if claude_model:
		claude_model.text = "claude-3-haiku-20240307"
	
	if baidu_enabled:
		baidu_enabled.button_pressed = false
	if baidu_app_id:
		baidu_app_id.text = ""
	if baidu_secret_key:
		baidu_secret_key.text = ""
	
	if local_enabled:
		local_enabled.button_pressed = false
	if local_base_url:
		local_base_url.text = "http://localhost:11434"
	if local_model:
		local_model.text = "llama2"
	if local_provider:
		local_provider.selected = 0
	
	if deepseek_enabled:
		deepseek_enabled.button_pressed = false
	if deepseek_api_key:
		deepseek_api_key.text = ""
	if deepseek_base_url:
		deepseek_base_url.text = "https://api.deepseek.com"
	if deepseek_model:
		deepseek_model.text = "deepseek-chat"
	
	_show_status("配置已重置为默认值", false)

## 语言配置按钮回调
func _on_language_config_button_pressed():
	if language_config_dialog:
		_load_language_config()
		language_config_dialog.popup_centered()

## 加载语言配置到对话框
func _load_language_config():
	if not language_list:
		return
	
	# 清空现有列表
	for child in language_list.get_children():
		child.queue_free()
	
	# 显示当前语言配置
	var languages = config_manager.get_supported_languages()
	var custom_mappings = config_manager.translation_config.get("languages", {}).get("custom_language_mappings", {})
	
	for lang in languages:
		var container = HBoxContainer.new()
		language_list.add_child(container)
		
		# 语言代码标签
		var code_label = Label.new()
		code_label.text = lang.code
		code_label.custom_minimum_size = Vector2(80, 0)
		container.add_child(code_label)
		
		# 当前名称显示
		var current_name_label = Label.new()
		current_name_label.text = lang.get("description", lang.get("name", lang.code))
		current_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(current_name_label)
		
		# 是否自定义标识
		var status_label = Label.new()
		if custom_mappings.has(lang.code):
			status_label.text = "已自定义"
			status_label.modulate = Color.GREEN
		else:
			status_label.text = "默认"
			status_label.modulate = Color.GRAY
		container.add_child(status_label)
		
		# 删除按钮（仅显示自定义的）
		if custom_mappings.has(lang.code):
			var delete_button = Button.new()
			delete_button.text = "删除"
			delete_button.pressed.connect(_on_delete_custom_language.bind(lang.code))
			container.add_child(delete_button)

## 添加/更新语言按钮回调
func _on_add_language_pressed():
	if not code_input or not name_input:
		return
	
	var code = code_input.text.strip_edges()
	var name = name_input.text.strip_edges()
	
	if code.is_empty() or name.is_empty():
		_show_status("请输入语言代码和显示名称", true)
		return
	
	# 添加到配置
	config_manager.set_custom_language_mapping(code, name, name, name)
	
	# 刷新显示
	_load_language_config()
	
	# 清空输入框
	code_input.text = ""
	name_input.text = ""
	
	_show_status("语言配置已添加: " + code + " -> " + name, false)

## 删除自定义语言映射
func _on_delete_custom_language(lang_code: String):
	var custom_mappings = config_manager.translation_config.get("languages", {}).get("custom_language_mappings", {})
	if custom_mappings.has(lang_code):
		custom_mappings.erase(lang_code)
		config_manager.save_config("translation", config_manager.translation_config)
		_load_language_config()
		_show_status("已删除自定义语言: " + lang_code, false)

## 保存语言配置按钮回调
func _on_save_language_config_pressed():
	# 重新加载翻译服务以应用新的语言配置
	translation_service = TranslationService.new()
	_populate_language_options()
	_populate_service_options()
	
	if language_config_dialog:
		language_config_dialog.hide()
	
	_show_status("语言配置已保存并生效", false)

## 重置语言配置按钮回调
func _on_reset_language_config_pressed():
	# 清空自定义映射
	if config_manager.translation_config.has("languages"):
		config_manager.translation_config.languages["custom_language_mappings"] = {}
		config_manager.save_config("translation", config_manager.translation_config)
	
	# 重新加载显示
	_load_language_config()
	_show_status("语言配置已重置为默认", false)

## 切换密钥显示/隐藏状态
func _on_toggle_visibility(line_edit: LineEdit, button: Button):
	if not line_edit or not button:
		return
	
	# 切换密钥的显示状态
	line_edit.secret = not line_edit.secret
	
	# 更新按钮图标
	if line_edit.secret:
		button.text = "👁"  # 隐藏状态，显示眼睛图标
	else:
		button.text = "🙈"  # 显示状态，显示遮眼图标

## 检查服务状态
func _check_service_status():
	if not translation_service:
		_show_status("翻译服务未初始化", true)
		return
	
	var ai_manager = translation_service.ai_service_manager
	if not ai_manager:
		_show_status("AI服务管理器未初始化", true)
		return
	
	var available_services = ai_manager.get_available_services()
	
	if available_services.size() > 0:
		var service_names = []
		for service in available_services:
			service_names.append(service.display_name)
		_show_status("✅ 已就绪！可用服务: " + ", ".join(service_names), false)
	else:
		_show_status("⚠️ 没有可用的AI服务，请点击'配置AI服务'设置API密钥", true)

## 测试网络连通性（简化版，跳过实际测试）
func _test_network_connectivity() -> Dictionary:
	print("=== 跳过网络连通性测试 ===")
	# 直接返回成功，跳过复杂的网络测试
	return {"success": true}

## 暂停按钮回调
func _on_pause_button_pressed():
	if translation_service:
		translation_service.pause_translation()

## 恢复按钮回调
func _on_resume_button_pressed():
	if translation_service:
		translation_service.resume_translation()

## 取消按钮回调
func _on_cancel_button_pressed():
	if translation_service:
		translation_service.cancel_translation()

## 翻译项目开始回调
func _on_translation_item_started(item_info: Dictionary):
	var index = item_info.get("index", 0)
	var total = item_info.get("total", 0)
	var text = item_info.get("text", "")
	var source_lang = item_info.get("source_lang", "")
	var target_lang = item_info.get("target_lang", "")
	var language_index = item_info.get("language_index", 1)
	var total_languages = item_info.get("total_languages", 1)
	
	# 显示当前翻译的内容
	if current_translation_container:
		current_translation_container.visible = true
	
	if current_original_label:
		current_original_label.text = "原文: " + text
	
	if current_translated_label:
		current_translated_label.text = "译文: 处理中..."
	
	# 在CSV模式下，初始化缓存并减少调试输出
	if current_mode == TranslationMode.GODOT_CSV:
		# 初始化缓存（如果需要）
		if not has_meta("source_lines_cache"):
			set_meta("source_lines_cache", [])
		if not has_meta("target_lines_cache"):
			set_meta("target_lines_cache", [])
		
		# 只在每20项输出一次开始信息，减少频繁输出
		if index % 20 == 0 or index == 0:
			print("🔄 [翻译开始] 第%d项: '%s'" % [index + 1, text.substr(0, 30)])
	
	if progress_label:
		if total_languages > 1:
			progress_label.text = "进度: 语言%d/%d - 第%d/%d项 - 处理中... (%s → %s)" % [language_index, total_languages, index + 1, total, source_lang, target_lang]
		else:
			progress_label.text = "进度: 第%d/%d项 - 处理中... (%s → %s)" % [index + 1, total, source_lang, target_lang]

## 翻译项目完成回调
func _on_translation_item_completed(item_info: Dictionary):
	var index = item_info.get("index", 0)
	var total = item_info.get("total", 0)
	var original_text = item_info.get("original_text", "")
	var translated_text = item_info.get("translated_text", "")
	var success = item_info.get("success", false)
	var error = item_info.get("error", "")
	var action = item_info.get("action", "")
	var language_index = item_info.get("language_index", 1)
	var total_languages = item_info.get("total_languages", 1)
	
	# 简化调试信息，只在关键时刻输出
	var total_items = item_info.get("total", 0)
	if index % 20 == 0 or index == total_items - 1:  # 每20项或最后一项输出进度
		var completed_count = 0
		if has_meta("source_lines_cache"):
			completed_count = get_meta("source_lines_cache").size()
		print("📊 [进度] 已处理 %d/%d 项，成功显示 %d 项" % [index + 1, total_items, completed_count])
	
	# 根据动作类型更新译文显示
	if current_translated_label:
		if success:
			match action:
				"新翻译":
					current_translated_label.text = "译文: " + translated_text + " [新翻译]"
				"保持现有翻译":
					current_translated_label.text = "译文: " + translated_text + " [已存在]"
				"空源文本":
					current_translated_label.text = "译文: [空文本]"
				_:
					current_translated_label.text = "译文: " + translated_text
		else:
			current_translated_label.text = "译文: [翻译失败] " + error
	
	# 在CSV模式下使用批量更新策略，避免频繁UI更新
	if current_mode == TranslationMode.GODOT_CSV:
		if not has_meta("source_lines_cache"):
			set_meta("source_lines_cache", [])
		if not has_meta("target_lines_cache"):
			set_meta("target_lines_cache", [])
		if not has_meta("last_ui_update_index"):
			set_meta("last_ui_update_index", -1)
		
		var source_lines = get_meta("source_lines_cache")
		var target_lines = get_meta("target_lines_cache")
		var last_update_index = get_meta("last_ui_update_index")
		
		# 只有翻译成功才添加到缓存
		if success:
			var display_text = translated_text
			match action:
				"新翻译":
					display_text += " ✨"
				"保持现有翻译":
					display_text += " 📌"
				"空源文本":
					display_text = "[空文本]"
			
			# 添加到缓存
			source_lines.append("[%d] %s" % [index + 1, original_text])
			target_lines.append("[%d] %s" % [index + 1, display_text])
		
		# 批量UI更新策略：每10项更新一次UI，或最后一项时更新
		var should_update_ui = false
		var items_since_last_update = source_lines.size() - (last_update_index + 1)
		
		if items_since_last_update >= 10 or index == total - 1:
			should_update_ui = true
		
		if should_update_ui and source_lines.size() > 0:
			# 批量更新UI
			if source_text_edit:
				source_text_edit.text = "\n".join(source_lines)
			if target_text_edit:
				target_text_edit.text = "\n".join(target_lines)
			
			set_meta("last_ui_update_index", source_lines.size() - 1)
			
			# 只在批量更新时输出一次调试信息
			print("📊 [批量UI更新] 已显示 %d 项 (第%d/%d项处理完成)" % [source_lines.size(), index + 1, total])
	
	if progress_label:
		var status_text = ""
		match action:
			"新翻译":
				status_text = "新翻译"
			"保持现有翻译":
				status_text = "跳过"
			"空源文本":
				status_text = "空文本"
			_:
				status_text = "已完成"
		
		if total_languages > 1:
			progress_label.text = "进度: 语言%d/%d - 第%d/%d项 - %s" % [language_index, total_languages, index + 1, total, status_text]
		else:
			progress_label.text = "进度: 第%d/%d项 - %s" % [index + 1, total, status_text]
	
	# 减少调试输出，只在关键时刻输出
	if index % 20 == 0 or index == total - 1:  # 每20项或最后一项输出状态
		var action_emoji = ""
		match action:
			"新翻译":
				action_emoji = "🔄"
			"保持现有翻译":
				action_emoji = "⏭️"
			"空源文本":
				action_emoji = "⚪"
			_:
				action_emoji = "✅"
		
		print("%s [状态更新] 第%d项: %s" % [action_emoji, index + 1, action])

## 翻译暂停回调
func _on_translation_paused():
	_update_translation_buttons(false, false, true, true)  # 禁用翻译和暂停，启用恢复和取消
	_show_status("翻译已暂停，点击恢复继续", false)

## 翻译恢复回调
func _on_translation_resumed():
	_update_translation_buttons(false, true, false, true)  # 禁用翻译和恢复，启用暂停和取消
	_show_status("翻译已恢复", false)

## 翻译取消回调
func _on_translation_cancelled():
	_update_translation_buttons(true, false, false, false)  # 启用翻译，禁用其他按钮
	_show_status("翻译已取消", false)
	
	# 隐藏当前翻译信息
	if current_translation_container:
		current_translation_container.visible = false
	
	if progress_label:
		progress_label.text = "进度: 已取消"
	
	# 在CSV模式下重置显示模式，保持累积内容
	if current_mode == TranslationMode.GODOT_CSV:
		_setup_csv_display_mode(false)
		
		# 确保最终UI更新 - 显示已缓存的翻译结果
		var source_lines = get_meta("source_lines_cache") if has_meta("source_lines_cache") else []
		var target_lines = get_meta("target_lines_cache") if has_meta("target_lines_cache") else []
		
		if source_lines.size() > 0:
			if source_text_edit:
				source_text_edit.text = "\n".join(source_lines)
			if target_text_edit:
				target_text_edit.text = "\n".join(target_lines)
		
		var success_count = target_lines.size()
		
		if target_text_edit:
			# 添加取消提示
			if target_text_edit.text.strip_edges().length() > 0:
				target_text_edit.text += "\n--- ⚠️ 翻译已取消（已完成: " + str(success_count) + " 项）---"
			else:
				target_text_edit.text = "⚠️ 翻译已取消\n已完成: " + str(success_count) + " 项"
		
		print("📝 [取消] 翻译被取消，已完成 %d 项" % success_count)

## 更新翻译按钮状态
func _update_translation_buttons(translate_enabled: bool, pause_enabled: bool, resume_enabled: bool, cancel_enabled: bool):
	if translate_button:
		translate_button.disabled = not translate_enabled
	if pause_button:
		pause_button.disabled = not pause_enabled
	if resume_button:
		resume_button.disabled = not resume_enabled
	if cancel_button:
		cancel_button.disabled = not cancel_enabled
