extends SceneTree

## CSV引号清理脚本

func _init():
	clean_csv_file()
	quit()

func clean_csv_file():
	print("=== 开始清理CSV文件中的多余引号 ===")
	
	var csv_path = "res://resources/languages/tool_language.csv"
	var file = FileAccess.open(csv_path, FileAccess.READ)
	if not file:
		print("错误: 无法打开文件 ", csv_path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	print("原始文件大小: ", content.length(), " 字符")
	
	# 加载CSV处理器
	var processor_script = load("res://scripts/utils/godot_csv_processor.gd")
	var processor = processor_script.new()
	
	# 解析CSV
	processor._parse_csv(content)
	print("解析完成，共 ", processor.csv_data.size(), " 行数据")
	
	# 清理多余引号
	var cleaned = processor.clean_unnecessary_quotes()
	if cleaned:
		print("清理了多余引号")
		
		# 重新生成CSV
		var new_content = processor._generate_csv()
		
		# 保存清理后的文件
		var output_file = FileAccess.open(csv_path, FileAccess.WRITE)
		if output_file:
			output_file.store_string(new_content)
			output_file.close()
			print("文件已保存，新大小: ", new_content.length(), " 字符")
			print("清理完成！")
		else:
			print("错误: 无法保存文件")
	else:
		print("没有发现需要清理的多余引号")
	
	# 验证清理结果
	print("\n=== 验证清理结果 ===")
	verify_cleaning_result(processor)

func verify_cleaning_result(processor):
	var problem_count = 0
	
	for row_index in range(processor.csv_data.size()):
		var row = processor.csv_data[row_index]
		for col_index in range(row.size()):
			var cell = row[col_index]
			
			# 检查是否还有多重引号
			if cell.contains('"""'):
				print("发现多重引号在 [", row_index, ",", col_index, "]: ", cell.substr(0, 50), "...")
				problem_count += 1
			
			# 检查是否有不必要的引号包围
			if cell.begins_with('"') and cell.ends_with('"') and cell.length() > 2:
				var inner = cell.substr(1, cell.length() - 2)
				if not (inner.contains(",") or inner.contains('"') or inner.contains("\n")):
					print("发现可能不必要的引号在 [", row_index, ",", col_index, "]: ", cell)
					problem_count += 1
	
	if problem_count == 0:
		print("✓ 验证通过，没有发现引号问题")
	else:
		print("⚠ 发现 ", problem_count, " 个潜在问题")