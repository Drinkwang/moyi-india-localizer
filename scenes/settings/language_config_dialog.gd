extends Window

@onready var english_button = $VBoxContainer/LanguageButtons/EnglishButton
@onready var chinese_button = $VBoxContainer/LanguageButtons/ChineseButton

signal language_changed(language_code)

func _ready():
	_connect_signals()
	_update_button_states()

func _connect_signals():
	english_button.pressed.connect(_on_english_pressed)
	chinese_button.pressed.connect(_on_chinese_pressed)

func _update_button_states():
	var current_language = TranslationServer.get_locale()
	english_button.disabled = (current_language == "en")
	chinese_button.disabled = (current_language == "zh")

func _on_english_pressed():
	language_changed.emit("en")
	_update_button_states()
	hide()

func _on_chinese_pressed():
	language_changed.emit("zh")
	_update_button_states()
	hide()