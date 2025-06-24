class_name CSharpProcessor
extends FileProcessor

## C#文件处理器
## 专门处理.cs文件的翻译需求

## 提取可翻译内容
func extract_translatable_content(content: String) -> Dictionary:
	var all_texts = []
	var all_positions = []
	
	# 提取字符串字面量
	var string_data = _extract_string_literals(content, ['"'])
	all_texts.append_array(string_data.texts)
	all_positions.append_array(string_data.positions)
	
	# 提取注释中的文本
	var comment_data = _extract_comments(content)
	all_texts.append_array(comment_data.texts)
	all_positions.append_array(comment_data.positions)
	
	return {"texts": all_texts, "positions": all_positions}

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
		
		# 重构字符串或注释
		var replacement = ""
		if pos.has("quote"):  # 字符串字面量
			replacement = pos.quote + translation + pos.quote
		else:  # 注释
			replacement = pos.prefix + translation
		
		result = result.substr(0, pos.start) + replacement + result.substr(pos.end)
	
	return result

## 获取支持的扩展名
func get_supported_extensions() -> Array:
	return [".cs"]

## 提取C#注释
func _extract_comments(content: String) -> Dictionary:
	var texts = []
	var positions = []
	
	# 提取单行注释 //
	var single_line_regex = RegEx.new()
	single_line_regex.compile("//\\s*(.+?)(?=\\n|$)")
	var single_results = single_line_regex.search_all(content)
	
	for result in single_results:
		var comment_text = result.get_string(1).strip_edges()
		if comment_text.length() > 0 and _should_translate_string(comment_text):
			texts.append(comment_text)
			positions.append({
				"start": result.get_start(),
				"end": result.get_end(),
				"original": result.get_string(),
				"prefix": "// "
			})
	
	# 提取多行注释 /* */
	var multi_line_regex = RegEx.new()
	multi_line_regex.compile("/\\*\\s*([\\s\\S]*?)\\s*\\*/")
	var multi_results = multi_line_regex.search_all(content)
	
	for result in multi_results:
		var comment_text = result.get_string(1).strip_edges()
		if comment_text.length() > 0 and _should_translate_string(comment_text):
			texts.append(comment_text)
			positions.append({
				"start": result.get_start(),
				"end": result.get_end(),
				"original": result.get_string(),
				"prefix": "/* ",
				"suffix": " */"
			})
	
	return {"texts": texts, "positions": positions}

## 验证C#文件格式
func validate_file_format(content: String) -> bool:
	# 简单验证：检查是否包含C#关键字
	var csharp_keywords = ["using", "namespace", "class", "public", "private", "static", "void"]
	for keyword in csharp_keywords:
		if content.contains(keyword):
			return true
	return false 