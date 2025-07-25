extends ScriptableObject

## CSV引号问题测试和修复脚本

func _ready():
	test_csv_quotes_issue()

func test_csv_quotes_issue():
	print("=== CSV引号问题分析 ===")
	
	# 创建测试CSV内容
	var test_csv_content = """keys,en,zh
HELLO,Hello,你好
QUOTE_TEST,"Hello, World","你好，世界"
MULTILINE_TEST,"Line 1
Line 2","第一行
第二行"
COMPLEX_QUOTE,"""Hello ""World""","你好""世界"""
	
	print("原始CSV内容:")
	print(test_csv_content)
	print("\n" + "="*50 + "\n")
	
	# 测试当前的CSV处理器
	var processor = GodotCSVProcessor.new()
	processor._parse_csv(test_csv_content)
	
	print("解析后的数据:")
	for i in range(processor.csv_data.size()):
		print("行 ", i, ": ", processor.csv_data[i])
	
	print("\n生成的CSV:")
	var generated_csv = processor._generate_csv()
	print(generated_csv)
	
	print("\n" + "="*50 + "\n")
	
	# 分析问题
	analyze_quote_issues(processor)
	
	# 提供修复方案
	provide_fix_solution()

func analyze_quote_issues(processor: GodotCSVProcessor):
	print("=== 引号问题分析 ===")
	
	for row_index in range(processor.csv_data.size()):
		var row = processor.csv_data[row_index]
		for col_index in range(row.size()):
			var cell = row[col_index]
			if cell.begins_with('"') and cell.ends_with('"'):
				print("发现引号包围的单元格 [", row_index, ",", col_index, "]: ", cell)
				
				# 检查是否是多余的引号
				var inner_content = cell.substr(1, cell.length() - 2)
				if not (inner_content.contains(",") or inner_content.contains('"') or inner_content.contains("\n")):
					print("  -> 这个引号可能是多余的，内容: '", inner_content, "'")
				else:
					print("  -> 这个引号是必要的（包含特殊字符）")

func provide_fix_solution():
	print("=== 修复方案 ===")
	print("问题根源:")
	print("1. CSV解析时保留了所有引号（第158行: current_field += char）")
	print("2. 生成CSV时又会根据内容添加引号")
	print("3. 这导致了引号的累积")
	print()
	print("解决方案:")
	print("1. 修改_parse_csv方法，正确处理引号转义")
	print("2. 在解析时移除外层引号，只保留内容")
	print("3. 正确处理双引号转义（\"\" -> \"）")
	print()
	print("具体修复:")
	print("- 修改第158行的引号处理逻辑")
	print("- 添加引号转义处理")
	print("- 确保解析和生成的对称性")

# 修复后的解析方法示例
func fixed_parse_csv(content: String):
	print("\n=== 修复后的解析方法示例 ===")
	
	var csv_data = []
	var current_row_data = []
	var current_field = ""
	var in_quotes = false
	var i = 0
	
	while i < content.length():
		var char = content[i]
		
		if char == '"':
			if in_quotes:
				# 检查是否是转义的引号
				if i + 1 < content.length() and content[i + 1] == '"':
					# 转义的引号，添加一个引号到字段
					current_field += '"'
					i += 1  # 跳过下一个引号
				else:
					# 引号结束
					in_quotes = false
			else:
				# 引号开始
				in_quotes = true
		elif char == ',' and not in_quotes:
			current_row_data.append(current_field)
			current_field = ""
		elif char == "\n" and not in_quotes:
			current_row_data.append(current_field)
			if current_row_data.size() > 0:
				csv_data.append(current_row_data)
			current_row_data = []
			current_field = ""
		else:
			current_field += char
		
		i += 1
	
	# 添加最后一个字段和行
	if current_field.length() > 0 or current_row_data.size() > 0:
		current_row_data.append(current_field)
		csv_data.append(current_row_data)
	
	print("修复后解析的数据:")
	for i in range(csv_data.size()):
		print("行 ", i, ": ", csv_data[i])