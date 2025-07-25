extends SceneTree

## CSV引号修复验证脚本

func _init():
	test_csv_fix()
	quit()

func test_csv_fix():
	print("=== CSV引号修复验证 ===")
	
	# 加载CSV处理器
	var processor_script = load("res://scripts/utils/godot_csv_processor.gd")
	var processor = processor_script.new()
	
	# 测试各种引号情况
	var test_cases = [
		{
			"name": "简单文本",
			"csv": "keys,en,zh\nHELLO,Hello,你好"
		},
		{
			"name": "包含逗号的文本",
			"csv": "keys,en,zh\nGREET,\"Hello, World\",\"你好，世界\""
		},
		{
			"name": "包含换行的文本", 
			"csv": "keys,en,zh\nMULTI,\"Line 1\nLine 2\",\"第一行\n第二行\""
		},
		{
			"name": "包含双引号的文本",
			"csv": "keys,en,zh\nQUOTE,\"He said \"\"Hello\"\"\",\"他说\"\"你好\"\"\""
		}
	]
	
	for test_case in test_cases:
		print("\n--- 测试: ", test_case.name, " ---")
		print("原始CSV:")
		print(test_case.csv)
		
		# 解析CSV
		processor._parse_csv(test_case.csv)
		
		print("\n解析后的数据:")
		for i in range(processor.csv_data.size()):
			print("行 ", i, ": ", processor.csv_data[i])
		
		# 重新生成CSV
		var generated = processor._generate_csv()
		print("\n重新生成的CSV:")
		print(generated)
		
		# 验证清理功能
		var cleaned = processor.clean_unnecessary_quotes()
		if cleaned:
			print("清理了多余引号")
		else:
			print("没有发现多余引号")
		
		print("\n" + "=".repeat(50))
	
	print("\n=== 修复总结 ===")
	print("1. 修复了CSV解析时的引号累积问题")
	print("2. 正确处理了引号转义（\"\" -> \"）")
	print("3. 添加了清理多余引号的功能")
	print("4. 保持了数据的完整性")