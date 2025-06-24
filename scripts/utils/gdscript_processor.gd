class_name GDScriptProcessor
extends FileProcessor

## GDScript文件处理器
## 专门处理.gd文件的翻译需求

## 提取可翻译内容
func extract_translatable_content(content: String) -> Dictionary:
	var all_texts = []
	var all_positions = []
	
	# 提取字符串字面量
	var string_data = _extract_string_literals(content, ['"', "'"])
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
	return [".gd"]

## 提取注释
func _extract_comments(content: String) -> Dictionary:
	var texts = []
	var positions = []
	
	var lines = content.split("\n")
	var current_pos = 0
	
	for line_index in range(lines.size()):
		var line = lines[line_index]
		var comment_start = line.find("#")
		
		if comment_start != -1:
			var comment_text = line.substr(comment_start + 1).strip_edges()
			
			# 过滤掉文档字符串标记和空注释
			if comment_text.length() > 0 and not comment_text.begins_with("#") and _should_translate_string(comment_text):
				var line_start = current_pos
				var comment_global_start = line_start + comment_start
				
				texts.append(comment_text)
				positions.append({
					"start": comment_global_start,
					"end": comment_global_start + comment_text.length() + 1,
					"original": "#" + comment_text,
					"prefix": "# "
				})
		
		current_pos += line.length() + 1  # +1 for newline
	
	return {"texts": texts, "positions": positions}

## 验证GDScript文件格式
func validate_file_format(content: String) -> bool:
	# 简单验证：检查是否包含GDScript关键字
	var gdscript_keywords = ["extends", "class_name", "func", "var", "const", "signal"]
	for keyword in gdscript_keywords:
		if content.contains(keyword):
			return true
	return false 