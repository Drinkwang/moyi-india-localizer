class_name JSONProcessor
extends FileProcessor

## JSON文件处理器
## 专门处理.json文件的翻译需求

## 提取可翻译内容
func extract_translatable_content(content: String) -> Dictionary:
	var texts = []
	var positions = []
	
	# 解析JSON
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result != OK:
		push_error("JSON格式错误: " + json.error_string)
		return {"texts": texts, "positions": positions}
	
	# 递归提取字符串值
	_extract_json_strings(json.data, content, "", texts, positions)
	
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
		var translation = data.translation.replace('"', '\\"')  # 转义引号
		var replacement = '"' + translation + '"'
		
		result = result.substr(0, pos.start) + replacement + result.substr(pos.end)
	
	return result

## 获取支持的扩展名
func get_supported_extensions() -> Array:
	return [".json"]

## 递归提取JSON字符串
func _extract_json_strings(data: Variant, content: String, path: String, texts: Array, positions: Array):
	if data is Dictionary:
		for key in data.keys():
			var value = data[key]
			var current_path = path + "." + str(key) if path != "" else str(key)
			
			if value is String and _should_translate_string(value):
				# 在原始内容中查找这个字符串的位置
				var string_pos = _find_json_string_position(content, str(key), value)
				if string_pos != -1:
					texts.append(value)
					positions.append({
						"start": string_pos,
						"end": string_pos + value.length() + 2,  # +2 for quotes
						"path": current_path,
						"original": '"' + value + '"'
					})
			elif value is Dictionary or value is Array:
				_extract_json_strings(value, content, current_path, texts, positions)
	
	elif data is Array:
		for i in range(data.size()):
			var value = data[i]
			var current_path = path + "[" + str(i) + "]"
			
			if value is String and _should_translate_string(value):
				# 在原始内容中查找这个字符串的位置
				var string_pos = _find_array_string_position(content, i, value)
				if string_pos != -1:
					texts.append(value)
					positions.append({
						"start": string_pos,
						"end": string_pos + value.length() + 2,  # +2 for quotes
						"path": current_path,
						"original": '"' + value + '"'
					})
			elif value is Dictionary or value is Array:
				_extract_json_strings(value, content, current_path, texts, positions)

## 查找JSON字符串在原始内容中的位置
func _find_json_string_position(content: String, key: String, value: String) -> int:
	# 简化的位置查找，实际应用中可能需要更复杂的逻辑
	var pattern = '"' + key + '"\\s*:\\s*"' + value + '"'
	var regex = RegEx.new()
	regex.compile(pattern)
	var result = regex.search(content)
	
	if result:
		# 返回值字符串的开始位置
		var full_match = result.get_string()
		var value_start = full_match.find('"' + value + '"')
		return result.get_start() + value_start
	
	return -1

## 查找数组中字符串的位置
func _find_array_string_position(content: String, index: int, value: String) -> int:
	# 简化实现，实际可能需要更复杂的解析
	var search_pattern = '"' + value + '"'
	var start_pos = 0
	
	for i in range(index + 1):
		var pos = content.find(search_pattern, start_pos)
		if pos == -1:
			return -1
		if i == index:
			return pos
		start_pos = pos + 1
	
	return -1

## 验证JSON文件格式
func validate_file_format(content: String) -> bool:
	var json = JSON.new()
	return json.parse(content) == OK 