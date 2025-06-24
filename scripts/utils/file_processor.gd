class_name FileProcessor
extends RefCounted

## 文件处理器基类
## 定义各种文件类型处理器的通用接口

## 从文件内容中提取可翻译的文本
## 返回格式: {"texts": Array, "positions": Array}
func extract_translatable_content(content: String) -> Dictionary:
	push_error("extract_translatable_content方法必须由子类实现")
	return {"texts": [], "positions": []}

## 重构文件内容，将翻译后的文本插入原位置
func reconstruct_content(original_content: String, positions: Array, translated_texts: Array) -> String:
	push_error("reconstruct_content方法必须由子类实现")
	return original_content

## 验证文件格式是否正确
func validate_file_format(content: String) -> bool:
	return true

## 获取支持的文件扩展名
func get_supported_extensions() -> Array:
	return []

## 提取字符串字面量的通用方法
func _extract_string_literals(content: String, quote_chars: Array = ['"', "'"]) -> Dictionary:
	var texts = []
	var positions = []
	
	for quote_char in quote_chars:
		var regex = RegEx.new()
		regex.compile(quote_char + "([^" + quote_char + "\\\\]*(\\\\.[^" + quote_char + "\\\\]*)*)" + quote_char)
		
		var results = regex.search_all(content)
		for result in results:
			var full_match = result.get_string()
			var inner_text = result.get_string(1)
			
			# 过滤掉空字符串和特殊字符串
			if inner_text.length() > 0 and _should_translate_string(inner_text):
				texts.append(inner_text)
				positions.append({
					"start": result.get_start(),
					"end": result.get_end(),
					"original": full_match,
					"quote": quote_char
				})
	
	return {"texts": texts, "positions": positions}

## 判断字符串是否应该被翻译
func _should_translate_string(text: String) -> bool:
	# 过滤掉纯数字、URL、路径等
	if text.is_valid_float() or text.is_valid_int():
		return false
	
	# 过滤URL
	if text.begins_with("http://") or text.begins_with("https://") or text.begins_with("ftp://"):
		return false
	
	# 过滤文件路径
	if text.begins_with("/") or text.contains("\\") or text.ends_with(".exe") or text.ends_with(".dll"):
		return false
	
	# 过滤纯符号
	var symbol_pattern = RegEx.new()
	symbol_pattern.compile("^[!@#$%^&*()_+\\-=\\[\\]{}|;':\",./<>?`~]+$")
	if symbol_pattern.search(text):
		return false
	
	return true 