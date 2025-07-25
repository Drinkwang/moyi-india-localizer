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
	if col_index == -1 or col_index == 0:  # 不允许修改第一列（id/keys列）
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
	return ["csv"]

## 内部方法，用于解析CSV内容
## 注意：正确处理CSV引号转义，避免引号累积问题
func _parse_csv(content: String):
	csv_data.clear()
	headers.clear()

	if content.is_empty():
		return

	var all_rows_data = []
	var current_row_data = []
	var current_field = ""
	var in_quotes = false
	var i = 0
	
	while i < content.length():
		var char = content[i]
		
		if char == '"':
			if in_quotes:
				# 检查是否是转义的引号（双引号）
				if i + 1 < content.length() and content[i + 1] == '"':
					# 转义的引号，添加一个引号到字段内容
					current_field += '"'
					i += 1  # 跳过下一个引号
				else:
					# 引号结束，不添加引号到字段内容
					in_quotes = false
			else:
				# 引号开始，不添加引号到字段内容
				in_quotes = true
		elif char == ',' and not in_quotes:
			current_row_data.append(current_field.strip_edges())
			current_field = ""
		elif char == "\n" and not in_quotes:
			current_row_data.append(current_field.strip_edges())
			if current_row_data.size() > 0:
				all_rows_data.append(current_row_data)
			current_row_data = []
			current_field = ""
		else:
			current_field += char
		
		i += 1

	# 添加最后一个字段和最后一行
	if current_field.length() > 0 or current_row_data.size() > 0:
		current_row_data.append(current_field.strip_edges())
		all_rows_data.append(current_row_data)

	if all_rows_data.is_empty():
		return

	# Godot的CSV导入器会忽略空的尾随行
	# 确保我们的解析器也这样做
	var last_row_index = all_rows_data.size() - 1
	while last_row_index >= 0:
		var row = all_rows_data[last_row_index]
		var is_empty = true
		for item in row:
			if not item.is_empty():
				is_empty = false
				break
		if is_empty:
			all_rows_data.remove_at(last_row_index)
			last_row_index -= 1
		else:
			break
	
	if all_rows_data.is_empty():
		return

	# 将解析的数据赋给csv_data
	csv_data = all_rows_data

	# 设置表头
	if not csv_data.is_empty():
		headers = csv_data[0]
		key_column = 0 # 假设第一列总是key

## 内部方法，用于将CSV数据生成为字符串
## 注意：这个实现会正确处理带逗号、引号和换行符的字段
func _generate_csv() -> String:
	var lines: Array
	for row_data in csv_data:
		var line_items: Array
		for item in row_data:
			var field = item
			# 如果字段包含逗号、引号或换行符，则用双引号括起来
			if field.contains(",") or field.contains("\"") or field.contains("\n"):
				# Godot要求将字段内的引号转义为两个引号 ""
				field = field.replace("\"", "\"\"")
				field = "\"" + field + "\""
			line_items.append(field)
		lines.append(",".join(line_items))
	
	# Godot CSV以换行符结束
	return "\n".join(lines) + "\n"

## 验证文件格式
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

## 清理CSV中的多余引号
## 这个函数可以修复由于复制粘贴导致的引号问题
func clean_unnecessary_quotes() -> bool:
	var cleaned = false
	
	for row_index in range(csv_data.size()):
		var row = csv_data[row_index]
		for col_index in range(row.size()):
			var original_cell = row[col_index]
			var cleaned_cell = _clean_cell_quotes(original_cell)
			
			if cleaned_cell != original_cell:
				row[col_index] = cleaned_cell
				cleaned = true
				print("清理单元格 [", row_index, ",", col_index, "]: '", original_cell, "' -> '", cleaned_cell, "'")
	
	return cleaned

## 内部方法：清理单个单元格的多余引号
func _clean_cell_quotes(cell: String) -> String:
	if cell.is_empty():
		return cell
	
	# 移除首尾的多余引号（如果内容不需要引号包围）
	if cell.begins_with('"') and cell.ends_with('"') and cell.length() >= 2:
		var inner_content = cell.substr(1, cell.length() - 2)
		
		# 检查内容是否真的需要引号
		# 只有包含逗号、换行符或引号的内容才需要引号包围
		if not (inner_content.contains(",") or inner_content.contains("\n") or inner_content.contains('"')):
			return inner_content
	
	return cell

## 验证并修复CSV格式
func validate_and_fix_csv() -> Dictionary:
	var result = {
		"valid": true,
		"issues_found": [],
		"fixes_applied": []
	}
	
	# 检查并清理多余引号
	if clean_unnecessary_quotes():
		result.fixes_applied.append("清理了多余的引号")
	
	# 检查行列一致性
	if csv_data.size() > 0:
		var expected_columns = headers.size()
		for row_index in range(1, csv_data.size()):
			var row = csv_data[row_index]
			if row.size() != expected_columns:
				result.issues_found.append("行 " + str(row_index) + " 列数不匹配，期望 " + str(expected_columns) + " 列，实际 " + str(row.size()) + " 列")
				
				# 自动修复：补齐缺失的列
				while row.size() < expected_columns:
					row.append("")
					result.fixes_applied.append("为行 " + str(row_index) + " 补齐了缺失的列")
	
	if result.issues_found.size() > 0:
		result.valid = false
	
	return result
