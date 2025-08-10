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
@onready var template_option_basic: OptionButton = $VBoxContainer/SettingsContainer/BasicSettingsContainer/TemplateContainer/TemplateOption

# 新增的UI节点引用
@onready var mode_option: OptionButton = $VBoxContainer/SettingsContainer/ModeContainer/ModeOption
@onready var basic_settings_container: HBoxContainer = $VBoxContainer/SettingsContainer/BasicSettingsContainer
@onready var godot_settings_container: VBoxContainer = $VBoxContainer/SettingsContainer/GodotSettingsContainer
@onready var unity_settings_container: VBoxContainer = $VBoxContainer/SettingsContainer/UnitySettingsContainer
@onready var file_button: Button = $VBoxContainer/SettingsContainer/GodotSettingsContainer/FileContainer/FileButton
@onready var source_lang_input: LineEdit = $VBoxContainer/SettingsContainer/GodotSettingsContainer/LanguageInputContainer/SourceLangInput
@onready var target_langs_input: LineEdit = $VBoxContainer/SettingsContainer/GodotSettingsContainer/LanguageInputContainer/TargetLangsInput
@onready var service_config_button: Button = $VBoxContainer/SettingsContainer/ModeContainer/ServiceConfigButton
@onready var language_config_button: Button = $VBoxContainer/SettingsContainer/ModeContainer/LanguageConfigButton
@onready var service_option_csv: OptionButton = $VBoxContainer/SettingsContainer/GodotSettingsContainer/ServiceContainer/ServiceOptionCSV
@onready var template_option_csv: OptionButton = $VBoxContainer/SettingsContainer/GodotSettingsContainer/TemplateContainer/TemplateOptionCSV
@onready var output_path_label: Label = $VBoxContainer/SettingsContainer/GodotSettingsContainer/OutputContainer/OutputPathLabel
@onready var save_as_button: Button = $VBoxContainer/SettingsContainer/GodotSettingsContainer/OutputContainer/SaveAsButton

# Unity相关UI节点引用
@onready var unity_file_button: Button = $VBoxContainer/SettingsContainer/UnitySettingsContainer/UnityFileContainer/UnityFileButton
@onready var unity_source_lang_input: LineEdit = $VBoxContainer/SettingsContainer/UnitySettingsContainer/UnityLanguageInputContainer/UnitySourceLangInput
@onready var unity_target_langs_input: LineEdit = $VBoxContainer/SettingsContainer/UnitySettingsContainer/UnityLanguageInputContainer/UnityTargetLangsInput
@onready var unity_service_option: OptionButton = $VBoxContainer/SettingsContainer/UnitySettingsContainer/UnityServiceContainer/UnityServiceOption
@onready var template_option_unity: OptionButton = $VBoxContainer/SettingsContainer/UnitySettingsContainer/UnityTemplateContainer/TemplateOptionUnity
@onready var unity_output_path_label: Label = $VBoxContainer/SettingsContainer/UnitySettingsContainer/UnityOutputContainer/UnityOutputPathLabel
@onready var unity_save_as_button: Button = $VBoxContainer/SettingsContainer/UnitySettingsContainer/UnityOutputContainer/UnitySaveAsButton

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

# 通用设置节点引用
@onready var incremental_translation_check: CheckBox = $AIConfigDialog/VBoxContainer/GeneralSettingsContainer/IncrementalTranslationContainer/IncrementalTranslationCheck

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

# 翻译模板配置对话框节点引用
@onready var template_config_dialog: AcceptDialog = $TemplateConfigDialog
@onready var template_config_button: Button = $VBoxContainer/SettingsContainer/ModeContainer/TemplateConfigButton
@onready var template_list: ItemList = $TemplateConfigDialog/VBoxContainer/MainContainer/TemplateListContainer/TemplateList
@onready var template_name_input: LineEdit = $TemplateConfigDialog/VBoxContainer/MainContainer/EditContainer/TemplateInfoContainer/NameContainer/NameInput
@onready var template_desc_input: LineEdit = $TemplateConfigDialog/VBoxContainer/MainContainer/EditContainer/TemplateInfoContainer/DescContainer/DescInput
@onready var template_system_edit: TextEdit = $TemplateConfigDialog/VBoxContainer/MainContainer/EditContainer/SystemPromptContainer/SystemTextEdit
@onready var template_user_edit: TextEdit = $TemplateConfigDialog/VBoxContainer/MainContainer/EditContainer/UserPromptContainer/UserTextEdit
@onready var add_template_button: Button = $TemplateConfigDialog/VBoxContainer/MainContainer/TemplateListContainer/ListButtonsContainer/AddTemplateButton
@onready var delete_template_button: Button = $TemplateConfigDialog/VBoxContainer/MainContainer/TemplateListContainer/ListButtonsContainer/DeleteTemplateButton
@onready var save_template_button: Button = $TemplateConfigDialog/VBoxContainer/ButtonContainer/SaveTemplateButton
@onready var reset_template_button: Button = $TemplateConfigDialog/VBoxContainer/ButtonContainer/ResetTemplateButton
@onready var import_template_button: Button = $TemplateConfigDialog/VBoxContainer/ButtonContainer/ImportButton
@onready var export_template_button: Button = $TemplateConfigDialog/VBoxContainer/ButtonContainer/ExportButton

# 知识库配置对话框节点引用
@onready var kb_config_dialog: AcceptDialog = $KnowledgeBaseConfigDialog
@onready var kb_config_button: Button = $VBoxContainer/SettingsContainer/ModeContainer/KnowledgeBaseConfigButton
@onready var kb_enabled_check: CheckBox = $KnowledgeBaseConfigDialog/VBoxContainer/EnableContainer/KnowledgeBaseEnabledCheck
@onready var current_path_display: LineEdit = $KnowledgeBaseConfigDialog/VBoxContainer/CurrentPathContainer/CurrentPathDisplay
@onready var new_path_input: LineEdit = $KnowledgeBaseConfigDialog/VBoxContainer/NewPathContainer/PathSelectContainer/NewPathInput
@onready var browse_button: Button = $KnowledgeBaseConfigDialog/VBoxContainer/NewPathContainer/PathSelectContainer/BrowseButton
@onready var validate_button: Button = $KnowledgeBaseConfigDialog/VBoxContainer/NewPathContainer/PathSelectContainer/ValidateButton
@onready var kb_status_label: Label = $KnowledgeBaseConfigDialog/VBoxContainer/StatusContainer/StatusLabel
@onready var migrate_data_check: CheckBox = $KnowledgeBaseConfigDialog/VBoxContainer/OptionsContainer/MigrateDataCheck
@onready var auto_backup_check: CheckBox = $KnowledgeBaseConfigDialog/VBoxContainer/OptionsContainer/AutoBackupCheck
@onready var cache_size_spinbox: SpinBox = $KnowledgeBaseConfigDialog/VBoxContainer/AdvancedContainer/SettingsGrid/CacheSizeSpinBox
@onready var similarity_spinbox: SpinBox = $KnowledgeBaseConfigDialog/VBoxContainer/AdvancedContainer/SettingsGrid/SimilaritySpinBox
@onready var apply_button: Button = $KnowledgeBaseConfigDialog/VBoxContainer/ButtonContainer/ApplyButton
@onready var reset_kb_button: Button = $KnowledgeBaseConfigDialog/VBoxContainer/ButtonContainer/ResetButton
@onready var open_folder_button: Button = $KnowledgeBaseConfigDialog/VBoxContainer/ButtonContainer/OpenFolderButton
@onready var kb_directory_dialog: FileDialog = $KBDirectoryDialog

# 翻译模式
enum TranslationMode {
	BASIC,    # 基础文本翻译
	GODOT_CSV, # Godot CSV翻译
	UNITY_LOCALIZATION # Unity多语言翻译
}

var current_mode: TranslationMode = TranslationMode.BASIC
var selected_csv_file: String = ""
var output_csv_file: String = ""
var selected_unity_file: String = ""
var output_unity_file: String = ""

func _ready():
	_initialize_services()
	_setup_ui()
	_connect_signals()
	intLan()
	
	# 添加测试翻译功能
	_test_translation_after_init()

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
	_populate_template_options()
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
	
	# Unity相关信号连接
	if unity_file_button:
		unity_file_button.pressed.connect(_on_unity_file_button_pressed)
	if unity_save_as_button:
		unity_save_as_button.pressed.connect(_on_unity_save_as_button_pressed)
	
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
	
	# 连接API密钥输入变化信号，用于实时状态提示
	if openai_api_key:
		openai_api_key.text_changed.connect(_on_api_key_changed.bind("openai"))
	if claude_api_key:
		claude_api_key.text_changed.connect(_on_api_key_changed.bind("claude"))
	if baidu_app_id:
		baidu_app_id.text_changed.connect(_on_api_key_changed.bind("baidu"))
	if baidu_secret_key:
		baidu_secret_key.text_changed.connect(_on_api_key_changed.bind("baidu"))
	if deepseek_api_key:
		deepseek_api_key.text_changed.connect(_on_api_key_changed.bind("deepseek"))
	if local_base_url:
		local_base_url.text_changed.connect(_on_api_key_changed.bind("local"))
	
	# 翻译模板配置
	if template_config_button:
		template_config_button.pressed.connect(_on_template_config_button_pressed)
	if template_list:
		template_list.item_selected.connect(_on_template_selected)
	if add_template_button:
		add_template_button.pressed.connect(_on_add_template_pressed)
	if delete_template_button:
		delete_template_button.pressed.connect(_on_delete_template_pressed)
	if save_template_button:
		save_template_button.pressed.connect(_on_save_template_pressed)
	if reset_template_button:
		reset_template_button.pressed.connect(_on_reset_template_pressed)
	if import_template_button:
		import_template_button.pressed.connect(_on_import_template_pressed)
	if export_template_button:
		export_template_button.pressed.connect(_on_export_template_pressed)
	
	# 增量翻译开关
	if incremental_translation_check:
		incremental_translation_check.toggled.connect(_on_incremental_translation_toggled)
		print("✅ 增量翻译开关信号连接完成")
	
	# 知识库配置
	if kb_config_button:
		kb_config_button.pressed.connect(_on_kb_config_button_pressed)
	if kb_enabled_check:
		kb_enabled_check.toggled.connect(_on_kb_enabled_toggled)
	if browse_button:
		browse_button.pressed.connect(_on_browse_button_pressed)
	if validate_button:
		validate_button.pressed.connect(_on_validate_button_pressed)
	if apply_button:
		apply_button.pressed.connect(_on_apply_kb_config_pressed)
	if reset_kb_button:
		reset_kb_button.pressed.connect(_on_reset_kb_config_pressed)
	if open_folder_button:
		open_folder_button.pressed.connect(_on_open_folder_pressed)
	if kb_directory_dialog:
		kb_directory_dialog.dir_selected.connect(_on_kb_directory_selected)
	if new_path_input:
		new_path_input.text_changed.connect(_on_new_path_changed)

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
	_populate_single_service_option(unity_service_option, "Unity翻译")

## 填充模板选项
func _populate_template_options():
	_populate_single_template_option(template_option_basic, "基础翻译")
	_populate_single_template_option(template_option_csv, "CSV翻译") 
	_populate_single_template_option(template_option_unity, "Unity翻译")

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
		
	var all_services = ai_manager.get_available_services()
	var configured_services = ai_manager.get_configured_services()
	
	if all_services.is_empty():
		option_button.add_item("⚠️ 没有可用服务", 0)
		print("警告: ", mode_name, " 没有任何AI服务")
		return
	
	print("为 ", mode_name, " 填充服务选项:")
	print("  总服务数: ", all_services.size())
	print("  已配置数: ", configured_services.size())
	
	# 添加所有服务到选项中，包括未配置的
	for service_info in all_services:
		option_button.add_item(service_info.display_name, service_info.name.hash())
		print("  + ", service_info.display_name)
	
	# 如果有已配置的服务，默认选择第一个已配置的
	if not configured_services.is_empty():
		var first_configured = configured_services[0]
		for i in range(option_button.get_item_count()):
			# 通过服务名称匹配来选择默认项
			var item_hash = option_button.get_item_id(i)
			if item_hash == first_configured.name.hash():
				option_button.selected = i
				print("  默认选择: ", first_configured.display_name)
				break
	else:
		# 如果没有已配置的服务，选择第一个
		if option_button.get_item_count() > 0:
			option_button.selected = 0
			print("  默认选择第一个未配置服务")
	
	print("已为 ", mode_name, " 加载 ", all_services.size(), " 个AI服务选项")

## 填充单个模板选项下拉框
func _populate_single_template_option(option_button: OptionButton, mode_name: String):
	if not option_button:
		print("错误: ", mode_name, " template_option 节点未找到")
		return
	
	option_button.clear()
	
	if not config_manager:
		print("错误: config_manager 未初始化")
		option_button.add_item("配置管理器未可用", 0)
		return
	
	# 获取所有可用的翻译模板
	var translation_config = config_manager.get_translation_config()
	var templates = translation_config.get("prompt_templates", {})
	
	if templates.is_empty():
		option_button.add_item("⚠️ 没有可用模板", 0)
		print("警告: ", mode_name, " 没有可用的翻译模板")
		return
	
	# 添加模板到选项中
	var template_index = 0
	for template_key in templates.keys():
		var template = templates[template_key]
		var display_name = template.get("name", template_key)
		option_button.add_item(display_name, template_key.hash())
		option_button.set_item_metadata(template_index, template_key)
		template_index += 1
	
	# 设置默认选择
	_set_default_template_selection(option_button, mode_name, templates)
	
	print("已为 ", mode_name, " 加载 ", templates.size(), " 个翻译模板")

## 设置默认模板选择
func _set_default_template_selection(option_button: OptionButton, mode_name: String, templates: Dictionary):
	var default_template = ""
	var translation_settings = config_manager.get_translation_config().get("translation_settings", {})
	
	# 根据模式选择默认模板
	match mode_name:
		"基础翻译":
			default_template = translation_settings.get("default_prompt_template", "game_translation")
		"CSV翻译":
			default_template = translation_settings.get("csv_prompt_template", "csv_batch")
		"Unity翻译":
			default_template = translation_settings.get("unity_prompt_template", "unity_localization")
	
	# 查找并选择默认模板
	for i in range(option_button.get_item_count()):
		var template_key = option_button.get_item_metadata(i)
		if template_key == default_template:
			option_button.selected = i
			break
	
	# 如果没找到默认模板，选择第一个
	if option_button.selected == -1 and option_button.get_item_count() > 0:
		option_button.selected = 0

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
		TranslationMode.UNITY_LOCALIZATION:
			await _handle_unity_translation()

## 处理基础文本翻译
func _handle_basic_translation():
	var source_text = source_text_edit.text if source_text_edit else ""
	if source_text.is_empty():
		_show_status("请输入要翻译的文本", true)
		return
	
	var source_lang = _get_selected_language(language_option_source)
	var target_lang = _get_selected_language(language_option_target)
	var service_name = _get_selected_service()
	var template_name = _get_selected_template()
	
	if source_lang.is_empty() or target_lang.is_empty():
		_show_status("请选择源语言和目标语言", true)
		return
	
	if service_name.is_empty():
		return  # 错误信息已在_get_selected_service()中显示
	
	# 开始翻译
	_show_status("正在翻译... (使用模板: " + template_name + ")", false)
	_update_translation_buttons(false, true, false, true)  # 禁用翻译和恢复，启用暂停和取消
	
	var result = await translation_service.translate_text_with_template(source_text, source_lang, target_lang, service_name, template_name)
	
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
	var template_name = _get_selected_template()
	
	# 检查服务是否可用
	if service_name.is_empty():
		return  # 错误信息已在_get_selected_service()中显示
	
	# 开始翻译
	_show_status("正在翻译CSV文件... (使用模板: " + template_name + ")", false)
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
	
	# 传递输出文件路径和模板给翻译服务
	var result = await translation_service.translate_godot_csv_with_output_and_template(selected_csv_file, output_csv_file, source_lang, target_languages, service_name, template_name)
	
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
	elif current_mode == TranslationMode.UNITY_LOCALIZATION:
		current_service_option = unity_service_option
	
	if not current_service_option or current_service_option.selected < 0:
		return "openai"  # 默认返回openai
	
	if not translation_service or not translation_service.ai_service_manager:
		_show_status("翻译服务未初始化，请先配置AI服务", true)
		return ""
	
	var ai_manager = translation_service.ai_service_manager
	var all_services = ai_manager.get_available_services()
	
	if all_services.is_empty():
		_show_status("没有任何AI服务，请检查配置文件", true)
		return ""
	elif current_service_option.selected < all_services.size():
		var selected_service_info = all_services[current_service_option.selected]
		var service_name = selected_service_info.name
		var is_configured = selected_service_info.is_configured
		
		if not is_configured:
			var display_name = selected_service_info.service.get_display_name()
			_show_status("⚠️ " + display_name + " 尚未配置，请点击「配置AI服务」设置API密钥", true)
			return ""
		
		return service_name
	
	# 默认返回第一个已配置的服务
	var configured_services = ai_manager.get_configured_services()
	if not configured_services.is_empty():
		return configured_services[0].name
	else:
		_show_status("没有已配置的AI服务，请点击「配置AI服务」设置API密钥", true)
		return ""

## 获取选中的模板
func _get_selected_template() -> String:
	# 根据当前模式选择正确的模板选项按钮
	var current_template_option: OptionButton
	match current_mode:
		TranslationMode.BASIC:
			current_template_option = template_option_basic
		TranslationMode.GODOT_CSV:
			current_template_option = template_option_csv
		TranslationMode.UNITY_LOCALIZATION:
			current_template_option = template_option_unity
	
	if not current_template_option or current_template_option.selected < 0:
		# 返回默认模板
		var translation_settings = config_manager.get_translation_config().get("translation_settings", {})
		match current_mode:
			TranslationMode.BASIC:
				return translation_settings.get("default_prompt_template", "game_translation")
			TranslationMode.GODOT_CSV:
				return translation_settings.get("csv_prompt_template", "csv_batch")
			TranslationMode.UNITY_LOCALIZATION:
				return translation_settings.get("unity_prompt_template", "unity_localization")
	
	# 获取选中模板的key
	var selected_index = current_template_option.selected
	if selected_index < current_template_option.get_item_count():
		return current_template_option.get_item_metadata(selected_index)
	
	return "game_translation"  # 最终默认值

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
	mode_option.add_item(tr("基础文本翻译"), TranslationMode.BASIC)
	mode_option.add_item(tr("CSV翻译"), TranslationMode.GODOT_CSV)
	mode_option.add_item(tr("Unity多语言文件"), TranslationMode.UNITY_LOCALIZATION)
	mode_option.selected = 0



## 更新UI以适应当前模式
func _update_ui_for_mode():
	if not basic_settings_container or not godot_settings_container or not unity_settings_container:
		return
	
	match current_mode:
		TranslationMode.BASIC:
			basic_settings_container.visible = true
			godot_settings_container.visible = false
			unity_settings_container.visible = false
			if translate_button:
				translate_button.text = "翻译"
			# 在基础模式下恢复文本框的正常模式
			_setup_csv_display_mode(false)
		TranslationMode.GODOT_CSV:
			basic_settings_container.visible = false
			godot_settings_container.visible = true
			unity_settings_container.visible = false
			if translate_button:
				translate_button.text = "翻译CSV文件"
			# 在CSV模式下设置文本框为只读显示模式（未翻译时）
			_setup_csv_display_mode(false)
		TranslationMode.UNITY_LOCALIZATION:
			basic_settings_container.visible = false
			godot_settings_container.visible = false
			unity_settings_container.visible = true
			if translate_button:
				translate_button.text = "翻译Unity文件"
			# 在Unity模式下设置文本框为只读显示模式
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

## CSV/Unity文件选择回调
func _on_csv_file_selected(path: String):
	match current_mode:
		TranslationMode.GODOT_CSV:
			selected_csv_file = path
			if file_button:
				file_button.text = path.get_file()
			
			# 自动生成默认输出文件名
			var base_name = path.get_basename()
			output_csv_file = base_name + "_translated.csv"
			_update_output_path_display()
			
			_show_status("已选择CSV文件: " + path.get_file(), false)
		
		TranslationMode.UNITY_LOCALIZATION:
			selected_unity_file = path
			if unity_file_button:
				unity_file_button.text = path.get_file()
			
			# 自动生成默认输出文件名
			var base_name = path.get_basename()
			output_unity_file = base_name + "_translated.json"
			_update_unity_output_path_display()
			
			_show_status("已选择Unity文件: " + path.get_file(), false)

## 另存为按钮回调
func _on_save_as_button_pressed():
	if save_file_dialog:
		# 设置默认文件名
		if not output_csv_file.is_empty():
			save_file_dialog.current_file = output_csv_file.get_file()
		save_file_dialog.popup_centered()

## 输出文件选择回调
func _on_output_file_selected(path: String):
	match current_mode:
		TranslationMode.GODOT_CSV:
			output_csv_file = path
			_update_output_path_display()
			_show_status("CSV输出文件设置为: " + path.get_file(), false)
		
		TranslationMode.UNITY_LOCALIZATION:
			output_unity_file = path
			_update_unity_output_path_display()
			_show_status("Unity输出文件设置为: " + path.get_file(), false)

## 更新输出路径显示
func _update_output_path_display():
	if output_path_label:
		if output_csv_file.is_empty():
			output_path_label.text = "请先选择输入文件"
		else:
			output_path_label.text = output_csv_file.get_file()

## 更新Unity输出路径显示
func _update_unity_output_path_display():
	if unity_output_path_label:
		if output_unity_file.is_empty():
			unity_output_path_label.text = "请先选择输入文件"
		else:
			unity_output_path_label.text = output_unity_file.get_file()

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
	print("--- 模板选择器节点 ---")
	print("template_option_basic: ", template_option_basic != null)
	print("template_option_csv: ", template_option_csv != null)
	print("template_option_unity: ", template_option_unity != null)
	print("--- 知识库配置节点 ---")
	print("kb_config_dialog: ", kb_config_dialog != null)
	print("kb_enabled_check: ", kb_enabled_check != null)
	print("kb_config_button: ", kb_config_button != null)
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
		
		# 显示配置指导提示
		_show_status("🔧 配置AI服务：输入API密钥后，记得点击「保存」按钮使配置生效", false)
		
		# 在打包环境中显示配置文件路径信息
		if OS.has_feature("standalone"):
			var config_info = config_manager.get_config_paths_info()
			print("\n=== 配置路径信息 ===\n" + config_info + "\n====================")
		
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
	
	# 加载通用设置
	if incremental_translation_check:
		incremental_translation_check.button_pressed = api_config.get("incremental_translation", false)
	
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
	# 显示保存进度
	_show_status("💾 正在保存配置...", false)
	
	var api_config = config_manager.get_api_config()
	var services_configured = []  # 记录配置的服务
	
	# 保存通用设置
	if incremental_translation_check:
		api_config["incremental_translation"] = incremental_translation_check.button_pressed
	
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
		
		if is_enabled and not api_key.is_empty():
			services_configured.append("OpenAI")
	
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
		
		if is_enabled and not api_key.is_empty():
			services_configured.append("Claude")
	
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
		
		if is_enabled and not app_id.is_empty() and not secret_key.is_empty():
			services_configured.append("百度翻译")
	
	# 更新本地模型配置
	if api_config.services.has("local"):
		var base_url = local_base_url.text if local_base_url else ""
		var model = local_model.text if local_model else ""
		var is_enabled = local_enabled.button_pressed if local_enabled else false
		
		api_config.services.local.enabled = is_enabled
		api_config.services.local.base_url = base_url if not base_url.is_empty() else "http://localhost:11434"
		api_config.services.local.model = model if not model.is_empty() else "llama2"
		var provider_index = local_provider.selected if local_provider else 0
		api_config.services.local.provider = "ollama" if provider_index == 0 else "localai"
		
		if is_enabled and not base_url.is_empty():
			services_configured.append("本地模型")
	
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
		
		if is_enabled and not api_key.is_empty():
			services_configured.append("DeepSeek")
	
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
			
			var success_message = "✅ 配置保存成功！"
			if services_configured.size() > 0:
				success_message += "\n🎯 已配置服务: " + ", ".join(services_configured)
			success_message += "\n🚀 可用服务: " + ", ".join(service_names) 
			success_message += "\n现在可以开始翻译了！"
			_show_status(success_message, false)
		else:
			var warning_message = "⚠️ 配置已保存，但没有检测到可用服务"
			if services_configured.size() > 0:
				warning_message += "\n📝 已配置: " + ", ".join(services_configured)
				warning_message += "\n💡 提示：配置已保存但服务可能需要验证，请使用「测试连接」功能检查"
			else:
				warning_message += "\n💡 请填写API密钥并启用服务"
			_show_status(warning_message, true)
		
		if ai_config_dialog:
			ai_config_dialog.hide()
	else:
		_show_status("❌ 保存配置失败，请检查文件权限", true)

## 测试连接按钮回调
func _on_test_connection_pressed():
	_show_status("🔍 正在测试连接...", false)
	
	# 先执行配置写入测试（确保打包环境下配置可以正常保存）
	if OS.has_feature("standalone"):
		print("\n=== 执行配置写入测试 ===")
		var test_config = {"test_timestamp": Time.get_unix_time_from_system()}
		var save_result = config_manager.save_config("app", config_manager.get_app_config())
		
		if save_result:
			print("✅ 配置写入测试成功，可以正常保存配置")
			var config_info = config_manager.get_config_paths_info()
			print("配置路径信息:\n" + config_info)
		else:
			print("❌ 配置写入测试失败，可能缺少写入权限")
		print("====================\n")
	
	# 获取当前选中的标签页对应的服务
	var current_service = _get_current_tab_service()
	if current_service.is_empty():
		_show_status("❌ 无法确定当前选中的服务", true)
		return
	
	print("开始测试当前选中的服务: ", current_service)
	
	# 检查输入有效性
	var has_valid_input = _check_service_input_validity(current_service)
	if not has_valid_input:
		var error_msg = "❌ 配置不完整：请先填写 " + current_service.to_upper() + " 的"
		match current_service:
			"openai", "claude", "deepseek":
				error_msg += "API密钥"
			"baidu":
				error_msg += "APP ID和Secret Key"
			"local":
				error_msg += "服务器地址和模型名称"
			_:
				error_msg += "必要信息"
		_show_status(error_msg, true)
		return
	
	# 跳过网络测试，直接测试当前服务
	_show_status("🔍 正在测试 " + current_service.to_upper() + " 服务连接...", false)
	
	# 创建临时的翻译服务来测试
	var temp_translation_service = TranslationService.new()
	var ai_manager = temp_translation_service.ai_service_manager
	
	var result = await ai_manager.test_service(current_service)
	
	if result.success:
		print("✅ ", current_service, " 测试成功")
		var success_msg = "✅ " + current_service.to_upper() + " 连接测试成功！"
		
		# 检查是否已保存配置
		var api_config = config_manager.get_api_config()
		var service_config = api_config.services.get(current_service, {})
		var is_saved_and_enabled = service_config.get("enabled", false)
		
		if not is_saved_and_enabled:
			success_msg += "\n💡 连接正常，请点击「保存」按钮使配置生效，然后即可在主界面使用该服务"
		else:
			success_msg += "\n🚀 服务已就绪，可以在主界面使用"
			
		_show_status(success_msg, false)
	else:
		print("❌ ", current_service, " 测试失败: ", result.error)
		var error_msg = "❌ " + current_service.to_upper() + " 连接失败：\n" + result.error
		error_msg += "\n💡 请检查API密钥是否正确，或尝试重新输入后再次测试"
		_show_status(error_msg, true)

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
	
	# 获取语言数据
	var languages = config_manager.get_supported_languages()
	var custom_mappings = config_manager.translation_config.get("languages", {}).get("custom_language_mappings", {})
	
	# 创建表头
	var header_container = HBoxContainer.new()
	language_list.add_child(header_container)
	var code_header = Label.new()
	code_header.text = "语言代码"
	code_header.custom_minimum_size = Vector2(150, 0)
	code_header.set("theme_override_font_sizes/font_size", 18)
	header_container.add_child(code_header)
	
	var name_header = Label.new()
	name_header.text = "显示名称"
	name_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_header.set("theme_override_font_sizes/font_size", 18)
	header_container.add_child(name_header)
	
	var status_header = Label.new()
	status_header.text = "状态"
	status_header.custom_minimum_size = Vector2(80, 0)
	status_header.set("theme_override_font_sizes/font_size", 18)
	header_container.add_child(status_header)

	var action_header = Label.new()
	action_header.text = "操作"
	action_header.custom_minimum_size = Vector2(150, 0)
	action_header.set("theme_override_font_sizes/font_size", 18)
	header_container.add_child(action_header)

	language_list.add_child(HSeparator.new())
	
	# 动态填充语言列表
	for lang in languages:
		var container = HBoxContainer.new()
		language_list.add_child(container)
		
		var code = lang.code
		var name = lang.get("description", lang.get("name", lang.code))
		
		# 点击事件的输入控件
		var code_line_edit = LineEdit.new()
		code_line_edit.text = code
		code_line_edit.editable = false
		code_line_edit.custom_minimum_size = Vector2(150, 0)
		code_line_edit.focus_mode = Control.FOCUS_NONE # 避免获得焦点
		code_line_edit.mouse_filter = Control.MOUSE_FILTER_STOP # 确保能接收点击
		code_line_edit.gui_input.connect(func(event): 
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_on_language_item_selected(code, name)
		)
		container.add_child(code_line_edit)
		
		var name_line_edit = LineEdit.new()
		name_line_edit.text = name
		name_line_edit.editable = false
		name_line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_line_edit.focus_mode = Control.FOCUS_NONE
		name_line_edit.mouse_filter = Control.MOUSE_FILTER_STOP
		name_line_edit.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_on_language_item_selected(code, name)
		)
		container.add_child(name_line_edit)
		
		# 状态标签
		var status_label = Label.new()
		status_label.custom_minimum_size = Vector2(80, 0)
		if custom_mappings.has(code):
			status_label.text = "已自定义"
			status_label.modulate = Color.GREEN
		else:
			status_label.text = "默认"
			status_label.modulate = Color.GRAY
		container.add_child(status_label)

		# 操作按钮容器
		var action_container = HBoxContainer.new()
		action_container.custom_minimum_size = Vector2(150, 0)
		container.add_child(action_container)
		
		# 编辑按钮
		var edit_button = Button.new()
		edit_button.text = "编辑"
		edit_button.pressed.connect(_on_language_item_selected.bind(code, name))
		action_container.add_child(edit_button)
		
		# 删除按钮（仅显示自定义的）
		if custom_mappings.has(code):
			var delete_button = Button.new()
			delete_button.text = "删除"
			delete_button.pressed.connect(_on_delete_custom_language.bind(code))
			action_container.add_child(delete_button)

## 当一个语言项被选中进行编辑时
func _on_language_item_selected(code: String, name: String):
	if code_input and name_input:
		code_input.text = code
		name_input.text = name
		_show_status("已加载 '" + code + "' 进行编辑", false)

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

## API密钥输入变化回调 - 提供实时状态提示
func _on_api_key_changed(service_name: String):
	# 当用户输入API密钥时，提供实时的状态提示
	var has_valid_input = _check_service_input_validity(service_name)
	
	if has_valid_input:
		_show_status("💡 " + service_name.to_upper() + " 密钥已输入，点击下方「保存」按钮使配置生效", false)
	else:
		# 如果输入不完整，不显示提示，避免干扰用户
		pass

## 检查指定服务的输入有效性
func _check_service_input_validity(service_name: String) -> bool:
	match service_name:
		"openai":
			return openai_api_key and not openai_api_key.text.strip_edges().is_empty()
		"claude":
			return claude_api_key and not claude_api_key.text.strip_edges().is_empty()
		"deepseek":
			return deepseek_api_key and not deepseek_api_key.text.strip_edges().is_empty()
		"baidu":
			return (baidu_app_id and not baidu_app_id.text.strip_edges().is_empty() and 
					baidu_secret_key and not baidu_secret_key.text.strip_edges().is_empty())
		"local":
			return (local_base_url and not local_base_url.text.strip_edges().is_empty() and
					local_model and not local_model.text.strip_edges().is_empty())
		_:
			return false

## 检查服务状态
func _check_service_status():
	if not translation_service:
		_show_status("翻译服务未初始化", true)
		return
	
	var ai_manager = translation_service.ai_service_manager
	if not ai_manager:
		_show_status("AI服务管理器未初始化", true)
		return
	
	var all_services = ai_manager.get_available_services()
	var configured_services = ai_manager.get_configured_services()
	var kb_status = "禁用"
	if config_manager and config_manager.is_knowledge_base_enabled():
		kb_status = "启用"
	
	print("=== 服务状态检查 ===")
	print("总服务数: ", all_services.size())
	print("已配置数: ", configured_services.size())
	
	if configured_services.size() > 0:
		var service_names = []
		for service in configured_services:
			service_names.append(service.display_name)
		
		var unconfigured_count = all_services.size() - configured_services.size()
		var status_message = "✅ 已就绪！可用服务: " + ", ".join(service_names)
		
		if unconfigured_count > 0:
			status_message += " | 未配置: " + str(unconfigured_count) + "个"
		
		status_message += " | 知识库: " + kb_status
		_show_status(status_message, false)
	else:
		var total_services = all_services.size()
		_show_status("⚠️ 没有已配置的AI服务，共" + str(total_services) + "个服务可配置，请点击「配置AI服务」设置API密钥 | 知识库: " + kb_status, true)
	
	print("===================")

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

# ============================================================================
# 翻译模板配置功能
# ============================================================================

## 翻译模板配置按钮回调
func _on_template_config_button_pressed():
	if template_config_dialog:
		_load_template_config()
		template_config_dialog.popup_centered()

## 加载翻译模板配置到对话框
func _load_template_config():
	if not template_list:
		return
	
	# 清空模板列表
	template_list.clear()
	
	# 获取现有模板
	var translation_config = config_manager.get_translation_config()
	var templates = translation_config.get("prompt_templates", {})
	
	# 添加模板到列表
	for template_key in templates.keys():
		var template = templates[template_key]
		var display_name = template.get("name", template_key)
		template_list.add_item(display_name)
		template_list.set_item_metadata(template_list.get_item_count() - 1, template_key)
	
	# 清空编辑区域
	_clear_template_editor()
	
	print("✅ 已加载 ", templates.size(), " 个翻译模板")

## 清空模板编辑器
func _clear_template_editor():
	if template_name_input:
		template_name_input.text = ""
	if template_desc_input:
		template_desc_input.text = ""
	if template_system_edit:
		template_system_edit.text = ""
	if template_user_edit:
		template_user_edit.text = ""

## 模板选择回调
func _on_template_selected(index: int):
	if not template_list or index < 0:
		return
	
	var template_key = template_list.get_item_metadata(index)
	if not template_key:
		return
	
	# 加载选中的模板内容
	var translation_config = config_manager.get_translation_config()
	var templates = translation_config.get("prompt_templates", {})
	
	if templates.has(template_key):
		var template = templates[template_key]
		
		if template_name_input:
			template_name_input.text = template.get("name", "")
		if template_desc_input:
			template_desc_input.text = template.get("description", "")
		if template_system_edit:
			template_system_edit.text = template.get("system", "")
		if template_user_edit:
			template_user_edit.text = template.get("user_template", "")
		
		print("✅ 已加载模板: ", template.get("name", template_key))

## 添加新模板回调
func _on_add_template_pressed():
	# 创建新模板
	var new_template_key = "custom_template_" + str(Time.get_unix_time_from_system())
	var new_template = {
		"name": "新模板",
		"description": "自定义翻译模板",
		"system": "你是一个专业的翻译专家。请根据要求进行翻译。",
		"user_template": "请将以下{source_language}文本翻译成{target_language}：\n\n{text}"
	}
	
	# 添加到配置
	var translation_config = config_manager.get_translation_config()
	if not translation_config.has("prompt_templates"):
		translation_config["prompt_templates"] = {}
	
	translation_config.prompt_templates[new_template_key] = new_template
	
	# 刷新模板列表
	_load_template_config()
	
	# 刷新所有模式的模板选择器
	_populate_template_options()
	
	# 选中新创建的模板
	for i in range(template_list.get_item_count()):
		if template_list.get_item_metadata(i) == new_template_key:
			template_list.select(i)
			_on_template_selected(i)
			break
	
	_show_status("已添加新模板，请编辑模板内容", false)

## 删除模板回调
func _on_delete_template_pressed():
	if not template_list:
		return
	
	var selected_index = template_list.get_selected_items()
	if selected_index.is_empty():
		_show_status("请先选择要删除的模板", true)
		return
	
	var index = selected_index[0]
	var template_key = template_list.get_item_metadata(index)
	var template_name = template_list.get_item_text(index)
	
	# 确认删除（简单的确认逻辑）
	print("🗑️ 删除模板: ", template_name, " (", template_key, ")")
	
	# 从配置中删除
	var translation_config = config_manager.get_translation_config()
	if translation_config.has("prompt_templates") and translation_config.prompt_templates.has(template_key):
		translation_config.prompt_templates.erase(template_key)
		
		# 刷新模板列表
		_load_template_config()
		
		# 刷新所有模式的模板选择器
		_populate_template_options()
		
		_show_status("已删除模板: " + template_name, false)
	else:
		_show_status("删除失败: 模板不存在", true)

## 保存模板回调
func _on_save_template_pressed():
	if not template_list:
		return
	
	var selected_index = template_list.get_selected_items()
	if selected_index.is_empty():
		_show_status("请先选择要保存的模板", true)
		return
	
	# 验证模板内容
	var template_name = template_name_input.text.strip_edges() if template_name_input else ""
	var template_desc = template_desc_input.text.strip_edges() if template_desc_input else ""
	var system_prompt = template_system_edit.text.strip_edges() if template_system_edit else ""
	var user_template = template_user_edit.text.strip_edges() if template_user_edit else ""
	
	if template_name.is_empty():
		_show_status("请输入模板名称", true)
		return
	
	if system_prompt.is_empty() or user_template.is_empty():
		_show_status("请输入系统提示词和用户模板", true)
		return
	
	# 获取选中的模板key
	var index = selected_index[0]
	var template_key = template_list.get_item_metadata(index)
	
	# 更新模板
	var translation_config = config_manager.get_translation_config()
	if not translation_config.has("prompt_templates"):
		translation_config["prompt_templates"] = {}
	
	translation_config.prompt_templates[template_key] = {
		"name": template_name,
		"description": template_desc,
		"system": system_prompt,
		"user_template": user_template
	}
	
	# 保存配置
	if config_manager.save_config("translation", translation_config):
		# 刷新模板列表
		_load_template_config()
		
		# 刷新所有模式的模板选择器
		_populate_template_options()
		
		# 重新选中该模板
		for i in range(template_list.get_item_count()):
			if template_list.get_item_metadata(i) == template_key:
				template_list.select(i)
				break
		
		_show_status("✅ 模板保存成功: " + template_name, false)
	else:
		_show_status("❌ 模板保存失败", true)

## 重置模板回调
func _on_reset_template_pressed():
	if not template_list:
		return
	
	var selected_index = template_list.get_selected_items()
	if selected_index.is_empty():
		_show_status("请先选择要重置的模板", true)
		return
	
	# 清空编辑区域
	_clear_template_editor()
	_show_status("已重置模板编辑区域", false)

## 导入模板回调
func _on_import_template_pressed():
	# 创建文件对话框用于导入
	var import_dialog = FileDialog.new()
	import_dialog.title = "导入翻译模板"
	import_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	import_dialog.access = FileDialog.ACCESS_FILESYSTEM
	import_dialog.add_filter("*.json", "JSON模板文件")
	
	# 添加到场景树
	add_child(import_dialog)
	
	# 连接信号
	import_dialog.file_selected.connect(_on_template_file_imported)
	import_dialog.popup_centered(Vector2i(800, 600))

## 导出模板回调
func _on_export_template_pressed():
	if not template_list:
		return
	
	var selected_index = template_list.get_selected_items()
	if selected_index.is_empty():
		_show_status("请先选择要导出的模板", true)
		return
	
	# 获取选中的模板
	var index = selected_index[0]
	var template_key = template_list.get_item_metadata(index)
	var template_name = template_list.get_item_text(index)
	
	var translation_config = config_manager.get_translation_config()
	var templates = translation_config.get("prompt_templates", {})
	
	if not templates.has(template_key):
		_show_status("导出失败: 模板不存在", true)
		return
	
	# 创建文件对话框用于导出
	var export_dialog = FileDialog.new()
	export_dialog.title = "导出翻译模板"
	export_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	export_dialog.access = FileDialog.ACCESS_FILESYSTEM
	export_dialog.add_filter("*.json", "JSON模板文件")
	export_dialog.current_file = template_name.replace(" ", "_") + ".json"
	
	# 添加到场景树
	add_child(export_dialog)
	
	# 连接信号并传递模板数据
	export_dialog.file_selected.connect(_on_template_file_exported.bind(templates[template_key]))
	export_dialog.popup_centered(Vector2i(800, 600))

## 模板文件导入回调
func _on_template_file_imported(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		_show_status("❌ 无法打开文件: " + file_path, true)
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		_show_status("❌ JSON格式错误: " + json.get_error_message(), true)
		return
	
	var template_data = json.data
	
	# 验证模板数据格式
	if not template_data is Dictionary:
		_show_status("❌ 模板格式错误: 根对象必须是字典", true)
		return
	
	if not template_data.has("name") or not template_data.has("system") or not template_data.has("user_template"):
		_show_status("❌ 模板格式错误: 缺少必要字段(name, system, user_template)", true)
		return
	
	# 创建新的模板key
	var new_template_key = "imported_" + str(Time.get_unix_time_from_system())
	
	# 添加到配置
	var translation_config = config_manager.get_translation_config()
	if not translation_config.has("prompt_templates"):
		translation_config["prompt_templates"] = {}
	
	translation_config.prompt_templates[new_template_key] = template_data
	
	# 保存配置
	if config_manager.save_config("translation", translation_config):
		# 刷新模板列表
		_load_template_config()
		
		# 选中新导入的模板
		for i in range(template_list.get_item_count()):
			if template_list.get_item_metadata(i) == new_template_key:
				template_list.select(i)
				_on_template_selected(i)
				break
		
		_show_status("✅ 模板导入成功: " + template_data.get("name", "未命名"), false)
	else:
		_show_status("❌ 模板导入失败", true)

## 模板文件导出回调
func _on_template_file_exported(template_data: Dictionary, file_path: String):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		_show_status("❌ 无法创建文件: " + file_path, true)
		return
	
	var json_string = JSON.stringify(template_data, "\t")
	file.store_string(json_string)
	file.close()
	
	_show_status("✅ 模板导出成功: " + file_path.get_file(), false)

# ============================================================================
# 知识库配置功能
# ============================================================================

## 知识库配置按钮回调
func _on_kb_config_button_pressed():
	if kb_config_dialog:
		_load_kb_config()
		kb_config_dialog.popup_centered()

## 增量翻译开关回调
func _on_incremental_translation_toggled(enabled: bool):
	# 立即保存配置
	config_manager.set_incremental_translation_enabled(enabled)
	
	# 显示状态提示
	if enabled:
		_show_status("✅ 增量翻译已启用 - 将跳过已翻译的内容", false)
	else:
		_show_status("🔄 增量翻译已禁用 - 将重新翻译所有内容（不使用缓存）", false)
		
		# 询问是否清除现有缓存
		var dialog = AcceptDialog.new()
		dialog.title = "清除缓存"
		dialog.dialog_text = "是否要清除现有的翻译缓存？\n这将确保下次翻译时完全重新翻译所有内容。"
		dialog.add_cancel_button("保留缓存")
		add_child(dialog)
		dialog.popup_centered()
		
		# 连接确认信号
		dialog.confirmed.connect(_on_clear_cache_confirmed)
		dialog.tree_exited.connect(func(): dialog.queue_free())
	
	print("📝 增量翻译状态已更新: ", enabled)

## 确认清除缓存
func _on_clear_cache_confirmed():
	var cache_manager = CacheManager.new()
	cache_manager.clear_cache()
	_show_status("🗑️ 翻译缓存已清除", false)

## 知识库启用开关回调
func _on_kb_enabled_toggled(enabled: bool):
	_update_kb_ui_state(enabled)
	
	# 立即保存启用状态
	if config_manager:
		config_manager.set_knowledge_base_enabled(enabled)
	
	if enabled:
		_show_status("✅ 知识库功能已启用并保存", false)
	else:
		_show_status("✅ 知识库功能已禁用并保存", false)

## 加载知识库配置到对话框
func _load_kb_config():
	var kb_config = config_manager.get_knowledge_base_config()
	
	# 加载启用状态
	if kb_enabled_check:
		kb_enabled_check.button_pressed = kb_config.get("enabled", false)
		_update_kb_ui_state(kb_enabled_check.button_pressed)
	
	# 显示当前路径
	if current_path_display:
		current_path_display.text = kb_config.get("root_path", "data/knowledge_base/")
	
	# 加载高级设置
	if cache_size_spinbox:
		cache_size_spinbox.value = kb_config.get("max_cache_size", 1000)
	if similarity_spinbox:
		similarity_spinbox.value = kb_config.get("similarity_threshold", 0.6)
	if auto_backup_check:
		auto_backup_check.button_pressed = kb_config.get("auto_backup", true)
	
	# 重置状态
	if apply_button:
		apply_button.disabled = true
	if kb_status_label:
		kb_status_label.text = "路径状态: 未验证"
		kb_status_label.modulate = Color(0.7, 0.7, 0.7, 1)

## 浏览按钮回调
func _on_browse_button_pressed():
	if kb_directory_dialog:
		kb_directory_dialog.popup_centered()

## 知识库目录选择回调
func _on_kb_directory_selected(dir_path: String):
	if new_path_input:
		new_path_input.text = dir_path
		_on_new_path_changed(dir_path)

## 新路径输入变化回调
func _on_new_path_changed(new_text: String):
	# 当路径改变时，重置验证状态并启用验证按钮
	if validate_button:
		validate_button.disabled = false
	if apply_button:
		apply_button.disabled = true
	if kb_status_label:
		kb_status_label.text = "路径状态: 未验证"
		kb_status_label.modulate = Color(0.7, 0.7, 0.7, 1)

## 验证路径按钮回调
func _on_validate_button_pressed():
	var path = new_path_input.text.strip_edges() if new_path_input else ""
	
	if path.is_empty():
		_update_kb_status("路径不能为空", true)
		return
	
	# 创建临时的知识库管理器进行验证
	var temp_kb = KnowledgeBaseManager.new()
	var validation_result = temp_kb.validate_path(path)
	
	if validation_result.valid:
		var status_text = "✅ 路径有效"
		if validation_result.has_data:
			status_text += " (包含现有数据)"
		else:
			status_text += " (空目录)"
		
		_update_kb_status(status_text, false)
		
		if apply_button:
			apply_button.disabled = false
	else:
		_update_kb_status("❌ " + validation_result.error, true)

## 更新知识库状态显示
func _update_kb_status(message: String, is_error: bool):
	if kb_status_label:
		kb_status_label.text = "路径状态: " + message
		kb_status_label.modulate = Color.RED if is_error else Color.GREEN

## 更新知识库UI状态（根据启用状态启用/禁用相关控件）
func _update_kb_ui_state(enabled: bool):
	# 控制路径相关控件的启用状态
	if current_path_display:
		current_path_display.modulate.a = 1.0 if enabled else 0.5
	if new_path_input:
		new_path_input.editable = enabled
		new_path_input.modulate.a = 1.0 if enabled else 0.5
	if browse_button:
		browse_button.disabled = not enabled
		browse_button.modulate.a = 1.0 if enabled else 0.5
	if validate_button:
		validate_button.disabled = not enabled
		validate_button.modulate.a = 1.0 if enabled else 0.5
	
	# 控制选项和高级设置
	if migrate_data_check:
		migrate_data_check.disabled = not enabled
		migrate_data_check.modulate.a = 1.0 if enabled else 0.5
	if auto_backup_check:
		auto_backup_check.disabled = not enabled
		auto_backup_check.modulate.a = 1.0 if enabled else 0.5
	if cache_size_spinbox:
		cache_size_spinbox.editable = enabled
		cache_size_spinbox.modulate.a = 1.0 if enabled else 0.5
	if similarity_spinbox:
		similarity_spinbox.editable = enabled
		similarity_spinbox.modulate.a = 1.0 if enabled else 0.5
	
	# 控制按钮
	if apply_button:
		apply_button.disabled = not enabled
		apply_button.modulate.a = 1.0 if enabled else 0.5
	if reset_kb_button:
		reset_kb_button.disabled = not enabled
		reset_kb_button.modulate.a = 1.0 if enabled else 0.5
	if open_folder_button:
		open_folder_button.disabled = not enabled
		open_folder_button.modulate.a = 1.0 if enabled else 0.5

## 应用知识库配置回调
func _on_apply_kb_config_pressed():
	# 保存启用状态
	var enabled = kb_enabled_check.button_pressed if kb_enabled_check else false
	config_manager.set_knowledge_base_enabled(enabled)
	
	# 如果未启用知识库，只保存启用状态即可
	if not enabled:
		_show_status("✅ 知识库功能已禁用", false)
		if kb_config_dialog:
			kb_config_dialog.hide()
		return
	
	var new_path = new_path_input.text.strip_edges() if new_path_input else ""
	var migrate_data = migrate_data_check.button_pressed if migrate_data_check else true
	
	if new_path.is_empty():
		_show_status("请输入有效的知识库路径", true)
		return
	
	# 保存高级设置
	var cache_size = cache_size_spinbox.value if cache_size_spinbox else 1000
	var similarity_threshold = similarity_spinbox.value if similarity_spinbox else 0.6
	
	config_manager.set_knowledge_base_cache_size(int(cache_size))
	config_manager.set_knowledge_base_similarity_threshold(similarity_threshold)
	
	# 创建知识库管理器并更改路径
	var kb_manager = KnowledgeBaseManager.new()
	kb_manager.initialize(config_manager)
	
	var result = kb_manager.change_knowledge_base_path(new_path, migrate_data)
	
	if result.success:
		var message = "✅ 知识库配置更新成功"
		if result.migrated_files > 0:
			message += "\n已迁移 " + str(result.migrated_files) + " 个文件"
		
		_show_status(message, false)
		
		# 更新显示
		_load_kb_config()
		
		if kb_config_dialog:
			kb_config_dialog.hide()
	else:
		_show_status("❌ 配置更新失败: " + result.error, true)

## 重置知识库配置回调
func _on_reset_kb_config_pressed():
	var default_path = "data/knowledge_base/"
	
	# 重置为默认值（包括启用状态）
	if kb_enabled_check:
		kb_enabled_check.button_pressed = false  # 默认禁用
		_update_kb_ui_state(false)
	if new_path_input:
		new_path_input.text = default_path
	if cache_size_spinbox:
		cache_size_spinbox.value = 1000
	if similarity_spinbox:
		similarity_spinbox.value = 0.6
	if auto_backup_check:
		auto_backup_check.button_pressed = true
	if migrate_data_check:
		migrate_data_check.button_pressed = true
	
	# 重置状态
	if apply_button:
		apply_button.disabled = true
	if kb_status_label:
		kb_status_label.text = "路径状态: 未验证"
		kb_status_label.modulate = Color(0.7, 0.7, 0.7, 1)
	
	_show_status("已重置为默认配置（知识库功能默认禁用）", false)

## 打开文件夹按钮回调
func _on_open_folder_pressed():
	var current_path = current_path_display.text if current_path_display else "data/knowledge_base/"
	
	# 确保目录存在
	if not DirAccess.dir_exists_absolute(current_path):
		DirAccess.make_dir_recursive_absolute(current_path)
	
	# 在不同操作系统上打开文件夹
	match OS.get_name():
		"Windows":
			OS.execute("explorer", [current_path.replace("/", "\\")])
		"macOS":
			OS.execute("open", [current_path])
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			OS.execute("xdg-open", [current_path])
		_:
			_show_status("当前操作系统不支持直接打开文件夹", true)
			return
	
	_show_status("已打开知识库文件夹", false)

# ============================================================================
# Unity多语言翻译功能
# ============================================================================

## Unity文件选择按钮回调
func _on_unity_file_button_pressed():
	if file_dialog:
		# 重新配置文件对话框用于Unity JSON文件
		file_dialog.clear_filters()
		file_dialog.add_filter("*.json", "Unity Localization JSON文件")
		file_dialog.title = "选择Unity Localization Package文件"
		file_dialog.popup_centered()

## Unity文件另存为按钮回调
func _on_unity_save_as_button_pressed():
	if save_file_dialog:
		# 配置保存对话框
		save_file_dialog.clear_filters()
		save_file_dialog.add_filter("*.json", "Unity Localization JSON文件")
		save_file_dialog.title = "保存翻译后的Unity文件"
		if not output_unity_file.is_empty():
			save_file_dialog.current_file = output_unity_file.get_file()
		save_file_dialog.popup_centered()

## 处理Unity翻译
func _handle_unity_translation():
	# 验证输入
	if selected_unity_file.is_empty():
		_show_status("请先选择Unity Localization文件", true)
		return
	
	if output_unity_file.is_empty():
		_show_status("请设置输出文件路径", true)
		return
	
	var source_lang = unity_source_lang_input.text.strip_edges() if unity_source_lang_input else ""
	var target_langs_text = unity_target_langs_input.text.strip_edges() if unity_target_langs_input else ""
	
	# 使用默认值
	if source_lang.is_empty():
		source_lang = "en"
	
	if target_langs_text.is_empty():
		target_langs_text = "zh-CN,ja,ko,ru"
	
	_show_status("Unity设置 - 源语言: " + source_lang + " → 目标语言: " + target_langs_text, false)
	
	# 解析目标语言列表
	var target_languages = []
	for lang in target_langs_text.split(","):
		var clean_lang = lang.strip_edges()
		if clean_lang.length() > 0:
			target_languages.append(clean_lang)
	
	if target_languages.is_empty():
		_show_status("请输入有效的目标语言代码", true)
		return
	
	var service_name = _get_selected_unity_service()
	var template_name = _get_selected_template()
	if service_name.is_empty():
		return
	
	# 开始翻译
	_show_status("正在翻译Unity Localization文件... (使用模板: " + template_name + ")", false)
	_update_translation_buttons(false, true, false, true)
	
	# 设置Unity模式下的UI显示
	_setup_csv_display_mode(true)
	
	# 显示进度
	if progress_bar:
		progress_bar.value = 0
		progress_bar.visible = true
	
	if current_translation_container:
		current_translation_container.visible = true
	
	# 清空文本框准备显示Unity翻译内容
	if source_text_edit:
		source_text_edit.text = ""
		source_text_edit.placeholder_text = "Unity翻译原文累积显示"
	
	if target_text_edit:
		target_text_edit.text = ""
		target_text_edit.placeholder_text = "Unity翻译译文累积显示"
	
	# 处理Unity JSON文件（带模板）
	var result = await _process_unity_localization_file_with_template(selected_unity_file, output_unity_file, source_lang, target_languages, service_name, template_name)
	
	if result.success:
		_show_status("✅ Unity翻译完成！已翻译 " + str(result.translated_count) + " 项", false)
	else:
		_show_status("❌ Unity翻译失败: " + result.error, true)
	
	_update_translation_buttons(true, false, false, false)
	
	# 恢复UI状态
	if current_mode == TranslationMode.UNITY_LOCALIZATION:
		_setup_csv_display_mode(false)
	
	if current_translation_container:
		current_translation_container.visible = false
	
	if progress_bar:
		progress_bar.visible = false

## 获取选中的Unity翻译服务
func _get_selected_unity_service() -> String:
	if not unity_service_option or unity_service_option.selected < 0:
		return "openai"
	
	if not translation_service or not translation_service.ai_service_manager:
		_show_status("翻译服务未初始化，请先配置AI服务", true)
		return ""
	
	var ai_manager = translation_service.ai_service_manager
	var available_services = ai_manager.get_available_services()
	
	if available_services.is_empty():
		_show_status("没有可用的AI服务，请先配置API密钥", true)
		return ""
	elif unity_service_option.selected < available_services.size():
		return available_services[unity_service_option.selected].name
	
	return available_services[0].name if not available_services.is_empty() else ""

## 处理Unity Localization Package文件（带模板）
func _process_unity_localization_file_with_template(input_file: String, output_file: String, source_lang: String, target_languages: Array, service_name: String, template_name: String) -> Dictionary:
	var result = {"success": false, "error": "", "translated_count": 0}
	
	# 读取Unity JSON文件
	var file = FileAccess.open(input_file, FileAccess.READ)
	if not file:
		result.error = "无法打开输入文件"
		return result
	
	var content = file.get_as_text()
	file.close()
	
	# 解析JSON
	var json = JSON.new()
	var parse_result = json.parse(content)
	if parse_result != OK:
		result.error = "JSON格式错误: " + json.get_error_message()
		return result
	
	var unity_data = json.data
	
	# 验证Unity Localization格式
	if not _validate_unity_localization_format(unity_data):
		result.error = "不是有效的Unity Localization Package格式"
		return result
	
	# 提取和翻译文本（使用模板）
	var translation_result = await _translate_unity_entries_with_template(unity_data, source_lang, target_languages, service_name, template_name)
	if not translation_result.success:
		result.error = translation_result.error
		return result
	
	result.translated_count = translation_result.translated_count
	
	# 保存翻译后的文件
	var output_json = JSON.stringify(unity_data, "\t")
	var output_file_handle = FileAccess.open(output_file, FileAccess.WRITE)
	if not output_file_handle:
		result.error = "无法创建输出文件"
		return result
	
	output_file_handle.store_string(output_json)
	output_file_handle.close()
	
	result.success = true
	return result

## 处理Unity Localization Package文件
func _process_unity_localization_file(input_file: String, output_file: String, source_lang: String, target_languages: Array, service_name: String) -> Dictionary:
	var result = {"success": false, "error": "", "translated_count": 0}
	
	# 读取Unity JSON文件
	var file = FileAccess.open(input_file, FileAccess.READ)
	if not file:
		result.error = "无法打开输入文件"
		return result
	
	var content = file.get_as_text()
	file.close()
	
	# 解析JSON
	var json = JSON.new()
	var parse_result = json.parse(content)
	if parse_result != OK:
		result.error = "JSON格式错误: " + json.get_error_message()
		return result
	
	var unity_data = json.data
	
	# 验证Unity Localization格式
	if not _validate_unity_localization_format(unity_data):
		result.error = "不是有效的Unity Localization Package格式"
		return result
	
	# 提取和翻译文本
	var translation_result = await _translate_unity_entries(unity_data, source_lang, target_languages, service_name)
	if not translation_result.success:
		result.error = translation_result.error
		return result
	
	result.translated_count = translation_result.translated_count
	
	# 保存翻译后的文件
	var output_json = JSON.stringify(unity_data, "\t")
	var output_file_handle = FileAccess.open(output_file, FileAccess.WRITE)
	if not output_file_handle:
		result.error = "无法创建输出文件"
		return result
	
	output_file_handle.store_string(output_json)
	output_file_handle.close()
	
	result.success = true
	return result

## 验证Unity Localization格式
func _validate_unity_localization_format(data: Dictionary) -> bool:
	# 检查是否包含Unity Localization的基本结构
	if data.has("StringDatabase"):
		# Unity Localization Package格式
		var string_db = data.StringDatabase
		return string_db.has("Tables") and string_db.Tables is Array
	elif data.has("Tables"):
		# 简化的Unity格式
		return data.Tables is Array
	elif data.has("entries") or data.has("translations"):
		# 自定义Unity格式
		return true
	
	return false

## 翻译Unity条目（带模板）
func _translate_unity_entries_with_template(unity_data: Dictionary, source_lang: String, target_languages: Array, service_name: String, template_name: String) -> Dictionary:
	var result = {"success": false, "error": "", "translated_count": 0}
	var entries_to_translate = []
	
	# 提取所有需要翻译的文本条目
	_extract_unity_text_entries(unity_data, source_lang, entries_to_translate)
	
	if entries_to_translate.is_empty():
		result.error = "未找到源语言 '" + source_lang + "' 的文本条目"
		return result
	
	print("📝 找到 ", entries_to_translate.size(), " 个需要翻译的条目")
	print("🎯 使用翻译模板: ", template_name)
	
	# 逐个翻译条目
	var translated_count = 0
	var total_entries = entries_to_translate.size()
	
	for i in range(total_entries):
		var entry = entries_to_translate[i]
		var original_text = entry.text
		
		# 发送翻译项目开始信号
		if translation_service:
			translation_service.translation_item_started.emit({
				"index": i,
				"total": total_entries,
				"text": original_text,
				"source_lang": source_lang,
				"target_lang": target_languages[0] if target_languages.size() > 0 else "zh-CN"
			})
		
		# 翻译到各目标语言（使用指定模板）
		for target_lang in target_languages:
			var translation_result = await translation_service.translate_text_with_template(original_text, source_lang, target_lang, service_name, template_name)
			
			if translation_result.success:
				# 将翻译结果写入Unity数据结构
				_set_unity_translation(unity_data, entry.key, target_lang, translation_result.translated_text)
				translated_count += 1
				
				# 发送翻译完成信号
				if translation_service:
					translation_service.translation_item_completed.emit({
						"index": i,
						"total": total_entries,
						"original_text": original_text,
						"translated_text": translation_result.translated_text,
						"success": true,
						"action": "新翻译"
					})
				
				# 显示翻译结果
				if source_text_edit and target_text_edit:
					source_text_edit.text += "[%d] %s\n" % [i + 1, original_text]
					target_text_edit.text += "[%d] %s (%s)\n" % [i + 1, translation_result.translated_text, target_lang]
			else:
				print("❌ 翻译失败: ", translation_result.error)
		
		# 更新进度
		var progress = float(i + 1) / float(total_entries)
		if translation_service:
			translation_service.translation_progress.emit(progress)
	
	result.success = true
	result.translated_count = translated_count
	return result

## 翻译Unity条目
func _translate_unity_entries(unity_data: Dictionary, source_lang: String, target_languages: Array, service_name: String) -> Dictionary:
	var result = {"success": false, "error": "", "translated_count": 0}
	var entries_to_translate = []
	
	# 提取所有需要翻译的文本条目
	_extract_unity_text_entries(unity_data, source_lang, entries_to_translate)
	
	if entries_to_translate.is_empty():
		result.error = "未找到源语言 '" + source_lang + "' 的文本条目"
		return result
	
	print("📝 找到 ", entries_to_translate.size(), " 个需要翻译的条目")
	
	# 逐个翻译条目
	var translated_count = 0
	var total_entries = entries_to_translate.size()
	
	for i in range(total_entries):
		var entry = entries_to_translate[i]
		var original_text = entry.text
		
		# 发送翻译项目开始信号
		if translation_service:
			translation_service.translation_item_started.emit({
				"index": i,
				"total": total_entries,
				"text": original_text,
				"source_lang": source_lang,
				"target_lang": target_languages[0] if target_languages.size() > 0 else "zh-CN"
			})
		
		# 翻译到各目标语言（使用Unity专用模板）
		for target_lang in target_languages:
			var translation_result = await translation_service.translate_text(original_text, source_lang, target_lang, service_name)
			
			if translation_result.success:
				# 将翻译结果写入Unity数据结构
				_set_unity_translation(unity_data, entry.key, target_lang, translation_result.translated_text)
				translated_count += 1
				
				# 发送翻译完成信号
				if translation_service:
					translation_service.translation_item_completed.emit({
						"index": i,
						"total": total_entries,
						"original_text": original_text,
						"translated_text": translation_result.translated_text,
						"success": true,
						"action": "新翻译"
					})
				
				# 显示翻译结果
				if source_text_edit and target_text_edit:
					source_text_edit.text += "[%d] %s\n" % [i + 1, original_text]
					target_text_edit.text += "[%d] %s (%s)\n" % [i + 1, translation_result.translated_text, target_lang]
			else:
				print("❌ 翻译失败: ", translation_result.error)
		
		# 更新进度
		var progress = float(i + 1) / float(total_entries)
		if translation_service:
			translation_service.translation_progress.emit(progress)
	
	result.success = true
	result.translated_count = translated_count
	return result

## 提取Unity文本条目
func _extract_unity_text_entries(unity_data: Dictionary, source_lang: String, entries_array: Array):
	if unity_data.has("StringDatabase"):
		# Unity Localization Package格式
		var tables = unity_data.StringDatabase.get("Tables", [])
		for table in tables:
			_extract_from_unity_table(table, source_lang, entries_array)
	elif unity_data.has("Tables"):
		# 简化格式
		for table in unity_data.Tables:
			_extract_from_unity_table(table, source_lang, entries_array)

## 从Unity表格中提取条目
func _extract_from_unity_table(table: Dictionary, source_lang: String, entries_array: Array):
	var table_data = table.get("TableData", [])
	
	for locale_data in table_data:
		if locale_data.get("LocaleIdentifier", "") == source_lang:
			var entries = locale_data.get("Entries", [])
			for entry in entries:
				var key_id = entry.get("Id", "")
				var text = entry.get("Value", "")
				
				if not text.is_empty():
					entries_array.append({
						"key": str(key_id),
						"text": text,
						"table": table.get("TableCollectionName", "")
					})

## 设置Unity翻译结果
func _set_unity_translation(unity_data: Dictionary, key_id: String, target_lang: String, translated_text: String):
	var tables = []
	
	if unity_data.has("StringDatabase"):
		tables = unity_data.StringDatabase.get("Tables", [])
	elif unity_data.has("Tables"):
		tables = unity_data.Tables
	
	for table in tables:
		var table_data = table.get("TableData", [])
		var target_locale_found = false
		
		# 查找目标语言的locale数据
		for locale_data in table_data:
			if locale_data.get("LocaleIdentifier", "") == target_lang:
				target_locale_found = true
				var entries = locale_data.get("Entries", [])
				
				# 查找匹配的条目ID并更新
				var entry_found = false
				for entry in entries:
					if str(entry.get("Id", "")) == key_id:
						entry["Value"] = translated_text
						entry_found = true
						break
				
				# 如果没找到条目，创建新的
				if not entry_found:
					entries.append({"Id": int(key_id), "Value": translated_text})
				break
		
		# 如果没找到目标语言的locale，创建新的
		if not target_locale_found:
			var new_locale = {
				"LocaleIdentifier": target_lang,
				"Entries": [{"Id": int(key_id), "Value": translated_text}]
			}
			table_data.append(new_locale)

@onready var lanbtn = $"TemplateConfigDialog_VBoxContainer_MainContainer_TemplateListContainer_ListButtonsContainer#DeleteTemplateButton"

func intLan():
	var translation_config = config_manager.get_translation_config()
	if translation_config.lan==null or 	translation_config.lan.length()<=0:
		translation_config.lan= OS.get_locale_language()
	TranslationServer.set_locale(translation_config.lan)
	
	
	if translation_config.lan=="zh":
		lanbtn.text="en"
	else:
		lanbtn.text="zh"
func _lanchange_button_down():
	var translation_config = config_manager.get_translation_config()
	
	if translation_config.lan=="zh":
		translation_config.lan="en"
	else:
		translation_config.lan="zh"
		
	TranslationServer.set_locale(translation_config.lan)	
	config_manager.save_config("translation", translation_config)
	if translation_config.lan=="zh":
		lanbtn.text="en"
	else:
		lanbtn.text="zh"

## 测试翻译功能
func _test_translation_after_init():
	print("=== 开始测试翻译功能 ===")
	
	# 等待几帧确保所有服务都已初始化
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	if not translation_service:
		print("❌ 错误：翻译服务未初始化")
		return
	
	# 获取知识库管理器
	var knowledge_base_manager = translation_service.knowledge_base_manager
	if not knowledge_base_manager:
		print("❌ 错误：知识库管理器未初始化")
		return
	
	print("✅ 知识库状态：", "启用" if config_manager.is_knowledge_base_enabled() else "禁用")
	
	# 测试搜索"一键翻译"术语
	print("\n=== 测试术语搜索 ===")
	var search_results = knowledge_base_manager.search_terms("一键翻译", 5)
	print("🔍 搜索'一键翻译'的结果数量：", search_results.size())
	
	for i in range(search_results.size()):
		var result = search_results[i]
		print("结果 %d:" % (i + 1))
		print("  匹配类型：%s" % result.get("match_type", "unknown"))
		print("  置信度：%.2f" % result.get("confidence", 0.0))
		
		var term = result.get("term", {})
		print("  术语源文本：%s" % term.get("source", ""))
		
		var target = term.get("target", {})
		if target.has("en"):
			print("  英文翻译：%s" % target.en)
		else:
			print("  ❌ 未找到英文翻译")
	
	# 测试翻译功能
	print("\n=== 测试翻译功能 ===")
	var source_text = "一键翻译"
	var source_lang = "zh"
	var target_lang = "ja"  # 改为测试日文翻译
	var service_name = "deepseek"
	var template_name = "basic"
	
	print("📝 准备翻译：'%s' (%s -> %s)" % [source_text, source_lang, target_lang])
	
	# 连接翻译完成信号
	if not translation_service.translation_completed.is_connected(_on_test_translation_completed):
		translation_service.translation_completed.connect(_on_test_translation_completed)
	if not translation_service.translation_failed.is_connected(_on_test_translation_failed):
		translation_service.translation_failed.connect(_on_test_translation_failed)
	
	# 执行翻译
	translation_service.translate_text_with_template(
		source_text,
		source_lang,
		target_lang,
		service_name,
		template_name
	)

## 测试翻译完成回调
func _on_test_translation_completed(result: Dictionary):
	print("\n=== 翻译测试完成 ===")
	print("✅ 原文：%s" % result.get("source_text", ""))
	print("✅ 译文：%s" % result.get("translated_text", ""))
	print("✅ 使用的服务：%s" % result.get("service_name", ""))
	print("✅ 使用的模板：%s" % result.get("template_name", ""))
	print("✅ 是否使用了知识库：%s" % ("是" if result.get("used_knowledge_base", false) else "否"))
	
	# 检查翻译结果是否正确
	var translated_text = result.get("translated_text", "")
	if "ワンクリック翻訳" in translated_text:
		print("🎉 翻译结果正确！包含了知识库中的日文术语")
	else:
		print("⚠️ 翻译结果可能不正确，未包含预期的术语")
		print("   预期包含：ワンクリック翻訳")
		print("   实际结果：%s" % translated_text)
	
	print("========================")

## 测试翻译失败回调
func _on_test_translation_failed(error_message: String):
	print("\n=== 翻译测试失败 ===")
	print("❌ 错误信息：%s" % error_message)
	print("======================")
