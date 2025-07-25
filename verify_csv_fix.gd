extends SceneTree

func _init():
	verify_csv_fix()
	quit()

func verify_csv_fix():
	print("=== CSV引号修复验证报告 ===")
	
	var file_path = "d:/Pro/translate/resources/languages/tool_language.csv"
	var processor_path = "d:/Pro/translate/godot_csv_processor.gd"
	
	# 加载CSV处理器
	var processor_script = load(processor_path)
	var processor = processor_script.new()
	
	# 读取CSV文件
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("❌ 无法打开CSV文件")
		return
	
	var content = file.get_as_text()
	file.close()
	
	print("📁 文件路径: ", file_path)
	print("📊 文件大小: ", content.length(), " 字符")
	
	# 检查多重引号问题
	var quote_issues = check_quote_issues(content)
	print("🔍 引号问题检查:")
	print("  - 7个连续引号: ", quote_issues["seven_quotes"], " 处")
	print("  - 6个连续引号: ", quote_issues["six_quotes"], " 处")
	print("  - 5个连续引号: ", quote_issues["five_quotes"], " 处")
	print("  - 4个连续引号: ", quote_issues["four_quotes"], " 处")
	print("  - 3个连续引号: ", quote_issues["three_quotes"], " 处")
	
	var total_issues = quote_issues["seven_quotes"] + quote_issues["six_quotes"] + quote_issues["five_quotes"] + quote_issues["four_quotes"] + quote_issues["three_quotes"]
	
	if total_issues == 0:
		print("✅ 没有发现多重引号问题！")
	else:
		print("⚠️  仍有 ", total_issues, " 处引号问题需要处理")
	
	# 测试CSV解析
	print("\n🧪 CSV解析测试:")
	var parsed_data = processor.parse_csv(content)
	if parsed_data.size() > 0:
		print("✅ CSV解析成功，共 ", parsed_data.size(), " 行数据")
		print("📋 第一行数据: ", parsed_data[0])
		if parsed_data.size() > 1:
			print("📋 第二行数据: ", parsed_data[1])
	else:
		print("❌ CSV解析失败")
	
	# 测试重新生成CSV
	print("\n🔄 CSV重新生成测试:")
	var regenerated_csv = processor.generate_csv(parsed_data)
	if regenerated_csv.length() > 0:
		print("✅ CSV重新生成成功，长度: ", regenerated_csv.length(), " 字符")
		
		# 检查重新生成的CSV是否有新的引号问题
		var new_quote_issues = check_quote_issues(regenerated_csv)
		var new_total_issues = new_quote_issues["seven_quotes"] + new_quote_issues["six_quotes"] + new_quote_issues["five_quotes"] + new_quote_issues["four_quotes"] + new_quote_issues["three_quotes"]
		
		if new_total_issues == 0:
			print("✅ 重新生成的CSV没有引号问题")
		else:
			print("⚠️  重新生成的CSV有 ", new_total_issues, " 处引号问题")
	else:
		print("❌ CSV重新生成失败")
	
	print("\n=== 验证完成 ===")

func check_quote_issues(content: String) -> Dictionary:
	return {
		"seven_quotes": content.count('"""""""'),
		"six_quotes": content.count('""""""'),
		"five_quotes": content.count('""""""'),
		"four_quotes": content.count('""""'),
		"three_quotes": content.count('"""')
	}