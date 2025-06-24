class_name PlainTextProcessor
extends FileProcessor

## 纯文本文件处理器
## 处理.txt等普通文本文件

## 提取可翻译内容
func extract_translatable_content(content: String) -> Dictionary:
	var texts = []
	var positions = []
	
	# 按段落分割文本
	var paragraphs = content.split("\n\n")
	var current_pos = 0
	
	for paragraph in paragraphs:
		var cleaned_paragraph = paragraph.strip_edges()
		
		if cleaned_paragraph.length() > 0 and _should_translate_string(cleaned_paragraph):
			# 查找段落在原始内容中的位置
			var start_pos = content.find(paragraph, current_pos)
			if start_pos != -1:
				texts.append(cleaned_paragraph)
				positions.append({
					"start": start_pos,
					"end": start_pos + paragraph.length(),
					"original": paragraph,
					"type": "paragraph"
				})
		
		current_pos += paragraph.length() + 2  # +2 for \n\n
	
	# 如果没有找到段落，按行处理
	if texts.is_empty():
		var lines = content.split("\n")
		current_pos = 0
		
		for line in lines:
			var cleaned_line = line.strip_edges()
			
			if cleaned_line.length() > 0 and _should_translate_string(cleaned_line):
				var start_pos = content.find(line, current_pos)
				if start_pos != -1:
					texts.append(cleaned_line)
					positions.append({
						"start": start_pos,
						"end": start_pos + line.length(),
						"original": line,
						"type": "line"
					})
			
			current_pos += line.length() + 1  # +1 for \n
	
	return {"texts": texts, "positions": positions}

## 重构文件内容
func reconstruct_content(original_content: String, positions: Array, translated_texts: Array) -> String:
	if positions.size() != translated_texts.size():
		push_error("位置数组和翻译文本数组大小不匹配")
		return original_content
	
	# 按位置倒序排序，从后往前替换避免位置偏移
	var sorted_data = []
	for i in range(positions.size()):
		if translated_texts[i].has("success") and translated_texts[i].success:
			sorted_data.append({
				"position": positions[i],
				"translation": translated_texts[i].translated_text
			})
	
	sorted_data.sort_custom(func(a, b): return a.position.start > b.position.start)
	
	var result = original_content
	for data in sorted_data:
		var pos = data.position
		var translation = data.translation
		
		# 保持原有的前后空白字符
		var original = pos.original
		var leading_spaces = _get_leading_spaces(original)
		var trailing_spaces = _get_trailing_spaces(original)
		
		var replacement = leading_spaces + translation + trailing_spaces
		result = result.substr(0, pos.start) + replacement + result.substr(pos.end)
	
	return result

## 获取支持的扩展名
func get_supported_extensions() -> Array:
	return [".txt", ".md", ".rst", ".log"]

## 获取前导空格
func _get_leading_spaces(text: String) -> String:
	var regex = RegEx.new()
	regex.compile("^\\s*")
	var result = regex.search(text)
	return result.get_string() if result else ""

## 获取后导空格
func _get_trailing_spaces(text: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\s*$")
	var result = regex.search(text)
	return result.get_string() if result else ""

## 验证纯文本格式（总是返回true）
func validate_file_format(content: String) -> bool:
	return true

## 重写父类方法，纯文本有不同的翻译判断逻辑
func _should_translate_string(text: String) -> bool:
	# 过滤掉太短的文本
	if text.length() < 3:
		return false
	
	# 过滤掉纯数字
	if text.is_valid_float() or text.is_valid_int():
		return false
	
	# 过滤URL
	if text.begins_with("http://") or text.begins_with("https://"):
		return false
	
	# 过滤文件路径
	if text.contains("/") or text.contains("\\"):
		return false
	
	# 过滤纯符号或代码
	var code_pattern = RegEx.new()
	code_pattern.compile("^[{}\\[\\]()<>+=\\-*/;:,.|&%$#@!`~]+$")
	if code_pattern.search(text):
		return false
	
	return true 