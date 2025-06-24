class_name GodotCSVProcessor
extends FileProcessor

## Godot CSV文件处理器
## 专门处理Godot多语言CSV文件的翻译

var csv_data: Array = []
var headers: Array = []
var key_column: int = 0

## 提取可翻译内容
func extract_translatable_content(content: String) -> Dictionary:
	var texts = []
	var positions = []
	
	# 解析CSV内容
	_parse_csv(content)
	
	if headers.is_empty():
		return {"texts": texts, "positions": positions}
	
	# 提取除了第一列（键名）外的所有文本内容
	for row_index in range(1, csv_data.size()):  # 跳过表头
		var row = csv_data[row_index]
		for col_index in range(1, row.size()):  # 跳过第一列的键名
			var text = row[col_index].strip_edges()
			if text.length() > 0 and _should_translate_string(text):
				texts.append(text)
				positions.append({
					"row": row_index,
					"col": col_index,
					"original": text,
					"language": headers[col_index] if col_index < headers.size() else "unknown"
				})
	
	return {"texts": texts, "positions": positions}

## 重构文件内容
func reconstruct_content(original_content: String, positions: Array, translated_texts: Array) -> String:
	if positions.size() != translated_texts.size():
		push_error("位置数组和翻译文本数组大小不匹配")
		return original_content
	
	# 重新解析CSV以确保数据一致
	_parse_csv(original_content)
	
	# 应用翻译结果
	for i in range(positions.size()):
		if translated_texts[i].has("success") and translated_texts[i].success:
			var pos = positions[i]
			var translation = translated_texts[i].translated_text
			
			# 更新CSV数据 - 安全检查
			if pos.row < csv_data.size():
				var row = csv_data[pos.row]
				if pos.col < row.size():
					row[pos.col] = translation
				else:
					# 如果行没有足够的列，扩展到所需的长度
					while row.size() <= pos.col:
						row.append("")
					row[pos.col] = translation
	
	# 重新生成CSV内容
	return _generate_csv()

## 添加新语言列
func add_language_column(language_code: String, source_language: String = "") -> bool:
	if headers.is_empty():
		return false
	
	# 检查语言是否已存在
	if language_code in headers:
		print("语言 ", language_code, " 已存在")
		return false
	
	# 添加新的语言列到表头
	headers.append(language_code)
	
	# 为每一行数据添加空列
	for row_index in range(csv_data.size()):
		var row = csv_data[row_index]
		if row_index == 0:
			# 表头行，直接添加语言代码
			row.append(language_code)
		else:
			# 数据行，添加空字符串，等待翻译
			row.append("")
	
	return true

## 获取指定语言列的内容用于翻译
func get_language_column_texts(language_code: String) -> Array:
	var col_index = headers.find(language_code)
	if col_index == -1:
		return []
	
	var texts = []
	for row_index in range(1, csv_data.size()):  # 跳过表头
		var row = csv_data[row_index]
		# 安全检查：确保行有足够的列
		if col_index < row.size():
			var text = row[col_index]
			texts.append(text)
		else:
			# 如果该行没有这个列，添加空字符串
			texts.append("")
	
	return texts

## 设置指定语言列的翻译内容
func set_language_column_texts(language_code: String, translated_texts: Array):
	var col_index = headers.find(language_code)
	if col_index == -1:
		return
	
	for row_index in range(1, min(csv_data.size(), translated_texts.size() + 1)):
		var text_index = row_index - 1
		if text_index < translated_texts.size():
			var translation = translated_texts[text_index]
			if translation.has("success") and translation.success:
				var row = csv_data[row_index]
				# 安全检查：确保行有足够的列
				if col_index < row.size():
					row[col_index] = translation.translated_text
				else:
					# 如果行没有足够的列，扩展到所需的长度
					while row.size() <= col_index:
						row.append("")
					row[col_index] = translation.translated_text

## 获取支持的扩展名
func get_supported_extensions() -> Array:
	return [".csv"]

## 解析CSV内容
func _parse_csv(content: String):
	csv_data.clear()
	headers.clear()
	
	var lines = content.split("\n")
	for line_index in range(lines.size()):
		var line = lines[line_index].strip_edges()
		if line.is_empty():
			continue
		
		var row = _parse_csv_line(line)
		csv_data.append(row)
		
		# 第一行作为表头
		if line_index == 0:
			headers = row.duplicate()

## 解析单行CSV
func _parse_csv_line(line: String) -> Array:
	var result = []
	var current_field = ""
	var in_quotes = false
	var i = 0
	
	while i < line.length():
		var char = line[i]
		
		if char == '"':
			if in_quotes and i + 1 < line.length() and line[i + 1] == '"':
				# 转义的引号
				current_field += '"'
				i += 1
			else:
				# 切换引号状态
				in_quotes = !in_quotes
		elif char == ',' and not in_quotes:
			# 字段分隔符
			result.append(current_field)
			current_field = ""
		else:
			current_field += char
		
		i += 1
	
	# 添加最后一个字段
	result.append(current_field)
	
	return result

## 生成CSV内容
func _generate_csv() -> String:
	var result = ""
	
	for row_index in range(csv_data.size()):
		var row = csv_data[row_index]
		var line_parts = []
		
		for field in row:
			var field_str = str(field)
			# 如果字段包含逗号、引号或换行符，需要加引号
			if field_str.contains(",") or field_str.contains('"') or field_str.contains("\n"):
				field_str = '"' + field_str.replace('"', '""') + '"'
			line_parts.append(field_str)
		
		result += ",".join(line_parts)
		if row_index < csv_data.size() - 1:
			result += "\n"
	
	return result

## 验证Godot CSV格式
func validate_file_format(content: String) -> bool:
	_parse_csv(content)
	
	print("CSV验证调试信息:")
	print("CSV行数: ", csv_data.size())
	print("表头: ", headers)
	
	# 检查是否有有效的表头和数据
	if csv_data.size() < 2:
		print("错误: CSV文件至少需要2行（表头+数据）")
		return false
	
	# 检查表头是否至少有2列（键列+至少一个语言列）
	if headers.size() < 2:
		print("错误: CSV文件至少需要2列（keys列+语言列）")
		return false
	
	# 检查第一列是否为"keys"或类似的键名列
	var first_header = headers[0].strip_edges().to_lower()
	if first_header != "keys" and first_header != "key" and first_header != "id":
		print("警告: 第一列不是标准的keys列，但继续处理")
	
	# 检查是否有数据行
	if csv_data.size() > 1:
		var first_row = csv_data[1]
		if first_row.size() == 0:
			print("错误: 第一行数据为空")
			return false
		
		# 安全检查：确保第一行至少有一列
		if first_row.size() > 0:
			var first_key = first_row[0].strip_edges()
			print("第一个键名: '", first_key, "'")
			
			# 放宽键名验证规则，只要不为空即可
			if first_key.is_empty():
				print("错误: 第一个键名为空")
				return false
		else:
			print("错误: 第一行数据没有足够的列")
			return false
	
	print("CSV格式验证通过")
	return true

## 获取可用的语言列表
func get_available_languages() -> Array:
	if headers.size() <= 1:
		return []
	
	# 返回除第一列外的所有列（语言列）
	return headers.slice(1)

## 获取所有键名
func get_all_keys() -> Array:
	var keys = []
	for row_index in range(1, csv_data.size()):
		if csv_data[row_index].size() > 0:
			keys.append(csv_data[row_index][0])
	return keys 
