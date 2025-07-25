extends SceneTree

func _init():
	clean_csv_file()
	quit()

func clean_csv_file():
	var file_path = "d:/Pro/translate/resources/languages/tool_language.csv"
	var backup_path = "d:/Pro/translate/resources/languages/tool_language_backup.csv"
	
	print("开始清理CSV文件...")
	
	# 读取原文件
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("无法打开文件: ", file_path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	# 备份原文件
	var backup_file = FileAccess.open(backup_path, FileAccess.WRITE)
	if backup_file:
		backup_file.store_string(content)
		backup_file.close()
		print("已创建备份文件: ", backup_path)
	
	# 清理多余引号
	var cleaned_content = clean_excessive_quotes(content)
	
	# 保存清理后的文件
	var output_file = FileAccess.open(file_path, FileAccess.WRITE)
	if output_file:
		output_file.store_string(cleaned_content)
		output_file.close()
		print("CSV文件清理完成!")
	else:
		print("无法写入文件: ", file_path)

func clean_excessive_quotes(content: String) -> String:
	var lines = content.split("\n")
	var cleaned_lines = []
	
	for line in lines:
		var cleaned_line = clean_line_quotes(line)
		cleaned_lines.append(cleaned_line)
	
	return "\n".join(cleaned_lines)

func clean_line_quotes(line: String) -> String:
	# 简单的引号清理策略
	# 1. 将连续的多个引号替换为单个引号
	var cleaned = line
	
	# 替换7个或更多连续引号为单个引号
	cleaned = cleaned.replace('"""""""', '"')
	
	# 替换6个连续引号为单个引号
	cleaned = cleaned.replace('""""""', '"')
	
	# 替换5个连续引号为单个引号
	cleaned = cleaned.replace('""""""', '"')
	
	# 替换4个连续引号为单个引号
	cleaned = cleaned.replace('""""', '"')
	
	# 替换3个连续引号为单个引号
	cleaned = cleaned.replace('"""', '"')
	
	# 替换2个连续引号为单个引号（如果不是转义）
	# 但保留字段开头和结尾的引号
	var result = ""
	var in_quotes = false
	var i = 0
	
	while i < cleaned.length():
		var char = cleaned[i]
		
		if char == '"':
			if not in_quotes:
				# 开始引号
				result += char
				in_quotes = true
			else:
				# 可能是结束引号或转义引号
				if i + 1 < cleaned.length() and cleaned[i + 1] == '"':
					# 转义引号，保留一个
					result += char
					i += 1  # 跳过下一个引号
				else:
					# 结束引号
					result += char
					in_quotes = false
		else:
			result += char
		
		i += 1
	
	return result