class_name TranslationService
extends RefCounted

## AI翻译游戏开发工具 - 翻译服务核心接口
## 
## 作者: 鹏砚 (Drinkwang)
## 开发方式: 人机协作 (与Claude AI共同开发)
## 
## 功能: 负责协调各种AI服务进行翻译工作

signal translation_completed(result: Dictionary)
signal translation_failed(error: String)
signal translation_progress(progress: float)
signal translation_item_started(item_info: Dictionary)  # 新增：开始翻译某个项目
signal translation_item_completed(item_info: Dictionary)  # 新增：完成翻译某个项目
signal translation_paused()  # 新增：翻译暂停
signal translation_resumed()  # 新增：翻译恢复
signal translation_cancelled()  # 新增：翻译取消

var ai_service_manager: AIServiceManager
var config_manager: ConfigManager
var cache_manager: CacheManager

# 翻译状态管理
enum TranslationState {
	IDLE,      # 空闲状态
	RUNNING,   # 正在翻译
	PAUSED,    # 暂停状态
	CANCELLED  # 已取消
}

var current_state: TranslationState = TranslationState.IDLE
var current_translation_info: Dictionary = {}  # 当前翻译信息

func _init():
	ai_service_manager = AIServiceManager.new()
	config_manager = ConfigManager.new()
	cache_manager = CacheManager.new()

## 翻译单个文本
func translate_text(text: String, source_lang: String, target_lang: String, service_name: String = "") -> Dictionary:
	if text.is_empty():
		return {"success": false, "error": "文本为空"}
	
	# 检查是否启用增量翻译，只有在增量模式下才使用缓存
	var config_manager = ConfigManager.new()
	var use_cache = config_manager.is_incremental_translation_enabled()
	
	# 检查缓存（仅在增量模式下）
	var cache_key = _generate_cache_key(text, source_lang, target_lang)
	if use_cache:
		var cached_result = cache_manager.get_translation(cache_key)
		if cached_result:
			return {"success": true, "translated_text": cached_result}
	
	# 获取AI服务
	var service = ai_service_manager.get_service(service_name)
	if not service:
		return {"success": false, "error": "AI服务不可用"}
	
	# 执行翻译
	var result = await service.translate(text, source_lang, target_lang)
	
	if result.success:
		# 缓存结果（仅在增量模式下）
		if use_cache:
			cache_manager.save_translation(cache_key, result.translated_text)
		translation_completed.emit(result)
	else:
		translation_failed.emit(result.error)
	
	return result

## 使用指定模板翻译文本
func translate_text_with_template(text: String, source_lang: String, target_lang: String, service_name: String = "", template_name: String = "") -> Dictionary:
	if text.is_empty():
		return {"success": false, "error": "文本为空"}
	
	# 检查是否启用增量翻译，只有在增量模式下才使用缓存
	var config_manager = ConfigManager.new()
	var use_cache = config_manager.is_incremental_translation_enabled()
	
	# 检查缓存（包含模板信息，仅在增量模式下）
	var cache_key = _generate_cache_key_with_template(text, source_lang, target_lang, template_name)
	if use_cache:
		var cached_result = cache_manager.get_translation(cache_key)
		if cached_result:
			return {"success": true, "translated_text": cached_result}
	
	# 获取AI服务
	var service = ai_service_manager.get_service(service_name)
	if not service:
		return {"success": false, "error": "AI服务不可用"}
	
	# 执行翻译（传递模板名称）
	var result = await service.translate_with_template(text, source_lang, target_lang, template_name)
	
	if result.success:
		# 缓存结果（仅在增量模式下）
		if use_cache:
			cache_manager.save_translation(cache_key, result.translated_text)
		translation_completed.emit(result)
	else:
		translation_failed.emit(result.error)
	
	return result

## 生成包含模板信息的缓存键
func _generate_cache_key_with_template(text: String, source_lang: String, target_lang: String, template_name: String) -> String:
	var base_key = _generate_cache_key(text, source_lang, target_lang)
	return base_key + "_" + str(template_name.hash())

## 暂停翻译
func pause_translation():
	if current_state == TranslationState.RUNNING:
		current_state = TranslationState.PAUSED
		translation_paused.emit()
		print("🔄 翻译已暂停")

## 恢复翻译
func resume_translation():
	if current_state == TranslationState.PAUSED:
		current_state = TranslationState.RUNNING
		translation_resumed.emit()
		print("▶️ 翻译已恢复")

## 取消翻译
func cancel_translation():
	if current_state == TranslationState.RUNNING or current_state == TranslationState.PAUSED:
		current_state = TranslationState.CANCELLED
		translation_cancelled.emit()
		print("❌ 翻译已取消")

## 获取当前翻译状态
func get_translation_state() -> TranslationState:
	return current_state

## 获取当前翻译信息
func get_current_translation_info() -> Dictionary:
	return current_translation_info

## 批量翻译文本
func translate_batch(texts: Array, source_lang: String, target_lang: String, service_name: String = "") -> Array:
	print("🚀 开始批量翻译:")
	print("  文本数量: ", texts.size())
	print("  源语言: ", source_lang)
	print("  目标语言: ", target_lang)
	print("  服务: ", service_name)
	
	var results = []
	var total = texts.size()
	
	if total == 0:
		print("⚠️ 没有文本需要翻译")
		return results
	
	# 设置翻译状态
	current_state = TranslationState.RUNNING
	current_translation_info = {
		"total": total,
		"completed": 0,
		"current_text": "",
		"source_lang": source_lang,
		"target_lang": target_lang,
		"service": service_name
	}
	
	# 获取翻译设置
	var config_manager = ConfigManager.new()
	var translation_config = config_manager.get_translation_config()
	var settings = translation_config.get("translation_settings", {})
	var delay_between_requests = settings.get("translation_delay", 1.0)
	
	print("  延迟设置: ", delay_between_requests, "秒")
	
	for i in range(total):
		print("\n--- 翻译项目 ", i+1, "/", total, " ---")
		
		# 检查翻译状态
		while current_state == TranslationState.PAUSED:
			print("⏸️ 翻译暂停中，等待恢复...")
			await Engine.get_main_loop().create_timer(0.5).timeout  # 等待恢复
		
		# 检查是否被取消
		if current_state == TranslationState.CANCELLED:
			print("🚫 翻译被取消，已完成 %d/%d 项" % [i, total])
			break
		
		var current_text = texts[i]
		print("原文: '", current_text, "'")
		
		# 更新当前翻译信息
		current_translation_info.completed = i
		current_translation_info.current_text = current_text
		
		# 发送开始翻译信号
		translation_item_started.emit({
			"index": i,
			"total": total,
			"text": current_text,
			"source_lang": source_lang,
			"target_lang": target_lang
		})
		
		# 执行翻译 - 处理空文本
		var result: Dictionary
		if current_text.strip_edges().is_empty():
			print("⏭️ 空文本，跳过翻译")
			result = {"success": true, "translated_text": current_text}
		else:
			print("🔄 调用AI服务翻译...")
			result = await translate_text(current_text, source_lang, target_lang, service_name)
			if result.get("success", false):
				print("✅ 翻译成功: '", result.get("translated_text", ""), "'")
			else:
				print("❌ 翻译失败: ", result.get("error", ""))
		
		results.append(result)
		
		# 发送完成翻译信号
		translation_item_completed.emit({
			"index": i,
			"total": total,
			"original_text": current_text,
			"translated_text": result.get("translated_text", ""),
			"success": result.get("success", false),
			"error": result.get("error", "")
		})
		
		# 更新进度
		var progress = float(i + 1) / float(total)
		translation_progress.emit(progress)
		print("当前进度: ", int(progress * 100), "%")
		
		# 如果不是最后一项，添加延迟以避免API限制
		if i < total - 1 and delay_between_requests > 0:
			print("⏳ 等待 ", delay_between_requests, " 秒...")
			await Engine.get_main_loop().create_timer(delay_between_requests).timeout
	
	# 重置状态
	current_state = TranslationState.IDLE
	current_translation_info.clear()
	
	print("✅ 批量翻译完成，总共处理 ", results.size(), " 项")
	return results

## 翻译文件
func translate_file(file_path: String, source_lang: String, target_lang: String, service_name: String = "", file_type: String = "") -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {"success": false, "error": "无法打开文件"}
	
	var content = file.get_as_text()
	file.close()
	
	# 根据文件类型处理内容
	var processor = _get_file_processor(file_path, file_type)
	var processed_content = processor.extract_translatable_content(content)
	
	# 翻译内容
	var translated_parts = await translate_batch(processed_content.texts, source_lang, target_lang, service_name)
	
	# 重构文件内容
	var final_content = processor.reconstruct_content(content, processed_content.positions, translated_parts)
	
	# 保存翻译后的文件
	var output_path = _generate_output_path(file_path, target_lang)
	var output_file = FileAccess.open(output_path, FileAccess.WRITE)
	if output_file:
		output_file.store_string(final_content)
		output_file.close()
		return {"success": true, "output_path": output_path}
	else:
		return {"success": false, "error": "无法保存翻译文件"}

## 翻译Godot CSV文件（添加新语言列）- 自动生成输出路径版本
func translate_godot_csv(file_path: String, source_lang: String, target_languages: Array, service_name: String = "") -> Dictionary:
	var output_path = _generate_output_path(file_path, "multilang")
	return await translate_godot_csv_with_output(file_path, output_path, source_lang, target_languages, service_name)

## 翻译Godot CSV文件（添加新语言列）- 指定输出路径版本
func translate_godot_csv_with_output(file_path: String, output_path: String, source_lang: String, target_languages: Array, service_name: String = "") -> Dictionary:
	print("=== 开始CSV翻译 ===")
	print("输入文件: ", file_path)
	print("输出文件: ", output_path)
	print("源语言: ", source_lang)
	print("目标语言: ", target_languages)
	print("服务: ", service_name)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {"success": false, "error": "无法打开文件"}
	
	var content = file.get_as_text()
	file.close()
	
	print("文件内容长度: ", content.length())
	print("文件内容预览: ", content.substr(0, 200))
	
	# 使用Godot CSV处理器
	var processor = GodotCSVProcessor.new()
	
	# 验证文件格式
	if not processor.validate_file_format(content):
		return {"success": false, "error": "无效的Godot CSV格式"}
	
	# 解析原始文件
	processor._parse_csv(content)
	
	print("CSV解析完成:")
	print("  表头: ", processor.headers)
	print("  数据行数: ", processor.csv_data.size())
	print("  可用语言: ", processor.get_available_languages())
	
	# 获取源语言列的文本
	var source_texts = processor.get_language_column_texts(source_lang)
	print("源语言 '", source_lang, "' 文本数量: ", source_texts.size())
	
	if source_texts.is_empty():
		return {"success": false, "error": "找不到源语言列: " + source_lang + "。可用语言: " + str(processor.get_available_languages())}
	
	# 显示源文本示例
	print("源文本示例 (前5个):")
	for i in range(min(5, source_texts.size())):
		print("  [", i, "] '", source_texts[i], "'")
	
	# 统计需要翻译的非空文本
	var non_empty_texts = []
	for text in source_texts:
		if not text.strip_edges().is_empty():
			non_empty_texts.append(text)
	
	print("需要翻译的非空文本数量: ", non_empty_texts.size(), "/", source_texts.size())
	
	if non_empty_texts.is_empty():
		print("⚠️ 源语言列没有需要翻译的内容（全部为空）")
		return {"success": false, "error": "源语言列 '" + source_lang + "' 没有需要翻译的内容"}
	
	# 设置CSV翻译状态
	current_state = TranslationState.RUNNING
	current_translation_info = {
		"total": source_texts.size(),
		"completed": 0,
		"current_text": "",
		"source_lang": source_lang,
		"target_languages": target_languages,
		"service": service_name
	}
	
	# 为每种目标语言创建新列并翻译
	var total_languages = target_languages.size()
	var successfully_added_languages = []
	
	for i in range(target_languages.size()):
		var target_lang = target_languages[i]
		print("\n--- 处理目标语言: ", target_lang, " (", i+1, "/", total_languages, ") ---")
		
		# 检查语言列是否已存在
		if target_lang in processor.headers:
			print("🔍 语言列 '", target_lang, "' 已存在，进行增量翻译...")
		else:
			# 添加新语言列
			if not processor.add_language_column(target_lang):
				print("❌ 无法添加语言列: ", target_lang)
				continue
			print("✅ 成功添加新语言列: ", target_lang)
		
		# 获取现有的目标语言翻译（如果存在）
		var existing_target_texts = []
		if target_lang in processor.headers:
			existing_target_texts = processor.get_language_column_texts(target_lang)
		else:
			# 如果是新列，创建空数组
			for j in range(source_texts.size()):
				existing_target_texts.append("")
		
		# 智能增量翻译：只翻译需要的项目
		print("🚀 开始智能增量翻译 ", source_texts.size(), " 个文本项...")
		var translated_results = []
		var need_translation_count = 0
		var already_translated_count = 0
		var empty_source_count = 0
		
		# 统计需要翻译的项目数量
		for j in range(source_texts.size()):
			var source_text = source_texts[j]
			var existing_target = existing_target_texts[j] if j < existing_target_texts.size() else ""
			
			if source_text.strip_edges().is_empty():
				empty_source_count += 1
			elif not existing_target.strip_edges().is_empty() and config_manager.is_incremental_translation_enabled():
				already_translated_count += 1
			else:
				need_translation_count += 1
		
		print("翻译统计:")
		print("  需要翻译: ", need_translation_count, " 项")
		print("  已有翻译: ", already_translated_count, " 项")
		print("  空源文本: ", empty_source_count, " 项")
		print("  总计: ", source_texts.size(), " 项")
		
		# 智能增量翻译：逐项处理
		for j in range(source_texts.size()):
			# 检查翻译状态 - 暂停处理
			while current_state == TranslationState.PAUSED:
				print("⏸️ CSV翻译暂停中，等待恢复...")
				await Engine.get_main_loop().create_timer(0.5).timeout
			
			# 检查是否被取消
			if current_state == TranslationState.CANCELLED:
				print("🚫 CSV翻译被取消，已完成 %d/%d 项，语言 %d/%d" % [j, source_texts.size(), i+1, total_languages])
				# 将剩余项目设为空结果并退出
				for remaining in range(j, source_texts.size()):
					translated_results.append({"success": true, "translated_text": existing_target_texts[remaining] if remaining < existing_target_texts.size() else ""})
				break
			
			var source_text = source_texts[j]
			var existing_target = existing_target_texts[j] if j < existing_target_texts.size() else ""
			var result: Dictionary
			var action_taken = ""
			
			# 更新当前翻译信息
			current_translation_info.completed = j
			current_translation_info.current_text = source_text
			
			# 发送开始翻译信号
			translation_item_started.emit({
				"index": j,
				"total": source_texts.size(),
				"text": source_text,
				"source_lang": source_lang,
				"target_lang": target_lang,
				"language_index": i + 1,
				"total_languages": total_languages
			})
			
			# 决定处理策略
			if source_text.strip_edges().is_empty():
				# 源文本为空，目标也设为空
				result = {"success": true, "translated_text": ""}
				action_taken = "空源文本"
			elif not existing_target.strip_edges().is_empty() and config_manager.is_incremental_translation_enabled():
				# 增量翻译启用且目标已有翻译，保持现有翻译
				result = {"success": true, "translated_text": existing_target}
				action_taken = "保持现有翻译(增量模式)"
			else:
				# 需要翻译：源文本不为空且(目标为空 或 增量翻译未启用)
				if not existing_target.strip_edges().is_empty() and not config_manager.is_incremental_translation_enabled():
					action_taken = "重新翻译(非增量模式)"
				else:
					action_taken = "新翻译"
				# 只在每20项输出一次翻译信息
				if j % 20 == 0:
					print("  [", j+1, "/", source_texts.size(), "] 🔄 翻译: '", source_text.substr(0, 50), "'")

				# 检查是否有模板参数传递
				var template_name = current_translation_info.get("template", "")
				if template_name.is_empty():
					result = await translate_text(source_text, source_lang, target_lang, service_name)
				else:
					result = await translate_text_with_template(source_text, source_lang, target_lang, service_name, template_name)
				
				# 减少成功/失败信息的输出频率
				if not result.get("success", false) or j % 20 == 0:
					if result.get("success", false):
						print("    ✅ [", j+1, "] 成功: '", result.get("translated_text", "").substr(0, 30), "...'")
					else:
						print("    ❌ [", j+1, "] 失败: ", result.get("error", ""))
			
			translated_results.append(result)
			
			# 发送完成翻译信号
			translation_item_completed.emit({
				"index": j,
				"total": source_texts.size(),
				"original_text": source_text,
				"translated_text": result.get("translated_text", ""),
				"success": result.get("success", false),
				"error": result.get("error", ""),
				"action": action_taken,
				"language_index": i + 1,
				"total_languages": total_languages
			})
			
			# 更新单个语言的翻译进度，减少频繁输出
			var lang_progress = float(j + 1) / float(source_texts.size())
			var overall_progress = (float(i) + lang_progress) / float(total_languages)
			translation_progress.emit(overall_progress)
			
			# 只在每20项或最后一项时输出进度
			if j % 20 == 0 or j == source_texts.size() - 1:
				print("🔄 进度更新: ", int(overall_progress * 100), "% (", j+1, "/", source_texts.size(), " 项，语言 ", i+1, "/", total_languages, ")")
				await Engine.get_main_loop().process_frame
		print("✅ 语言 '", target_lang, "' 增量翻译完成")
		
		# 统计增量翻译结果
		var new_translation_count = 0
		var kept_translation_count = 0
		var empty_count = 0
		var failed_count = 0
		
		for k in range(translated_results.size()):
			var result = translated_results[k]
			var source_text = source_texts[k]
			var existing_target = existing_target_texts[k] if k < existing_target_texts.size() else ""
			
			if source_text.strip_edges().is_empty():
				empty_count += 1
			elif not existing_target.strip_edges().is_empty() and config_manager.is_incremental_translation_enabled():
				kept_translation_count += 1
			elif result.get("success", false):
				new_translation_count += 1
			else:
				failed_count += 1
		
		print("增量翻译统计:")
		print("  新翻译: ", new_translation_count, " 项")
		print("  保持现有: ", kept_translation_count, " 项")
		print("  空文本: ", empty_count, " 项")
		print("  翻译失败: ", failed_count, " 项")
		print("  总计: ", translated_results.size(), " 项")
		
		# 设置翻译后的内容
		processor.set_language_column_texts(target_lang, translated_results)
		successfully_added_languages.append(target_lang)
		
		# 检查是否被取消（语言层面）
		if current_state == TranslationState.CANCELLED:
			print("🚫 CSV翻译被完全取消")
			break
		
		# 更新进度
		var progress = float(i + 1) / float(total_languages)
		translation_progress.emit(progress)
		print("当前总进度: ", int(progress * 100), "%")
	
	# 重置翻译状态
	var was_cancelled = current_state == TranslationState.CANCELLED
	current_state = TranslationState.IDLE
	current_translation_info.clear()
	
	if was_cancelled:
		print("⚠️ CSV翻译被用户取消")
		if successfully_added_languages.is_empty():
			return {"success": false, "error": "翻译被取消，没有完成任何语言"}
		else:
			# 即使被取消，也保存已完成的部分
			print("📋 保存已完成的部分翻译...")
	elif successfully_added_languages.is_empty():
		return {"success": false, "error": "没有成功处理任何目标语言"}
	
	# 生成最终的CSV内容
	print("\n--- 生成输出文件 ---")
	var final_content = processor._generate_csv()
	print("生成的CSV内容长度: ", final_content.length())
	
	# 保存文件到指定的输出路径
	var output_file = FileAccess.open(output_path, FileAccess.WRITE)
	if output_file:
		output_file.store_string(final_content)
		output_file.close()
		print("✅ 文件保存成功: ", output_path)
		if was_cancelled:
			print("=== CSV翻译已取消（部分完成）===")
			return {"success": true, "output_path": output_path, "languages_added": successfully_added_languages, "cancelled": true}
		else:
			print("=== CSV翻译完成 ===")
			return {"success": true, "output_path": output_path, "languages_added": successfully_added_languages}
	else:
		print("❌ 无法保存翻译文件: ", output_path)
		return {"success": false, "error": "无法保存翻译文件"}

## 生成缓存键
func _generate_cache_key(text: String, source_lang: String, target_lang: String) -> String:
	var combined = text + source_lang + target_lang
	return combined.md5_text()

## 获取文件处理器
func _get_file_processor(file_path: String, file_type: String = "") -> FileProcessor:
	var extension = file_path.get_extension()
	
	# 如果指定了文件类型，优先使用
	if file_type == "godot_csv":
		return GodotCSVProcessor.new()
	
	match extension:
		"gd":
			return GDScriptProcessor.new()
		"cs":
			return CSharpProcessor.new()
		"json":
			return JSONProcessor.new()
		"csv":
			return GodotCSVProcessor.new()
		_:
			return PlainTextProcessor.new()

## 带模板的CSV翻译（包装版本）
func translate_godot_csv_with_output_and_template(file_path: String, output_path: String, source_lang: String, target_languages: Array, service_name: String = "", template_name: String = "") -> Dictionary:
	print("🎯 使用模板 '", template_name, "' 进行CSV翻译")
	
	# 创建临时的翻译信息，包含模板参数
	var original_info = current_translation_info.duplicate(true)
	
	# 修改current_translation_info以包含模板信息
	current_translation_info = {
		"total": 0,
		"completed": 0,
		"current_text": "",
		"source_lang": source_lang,
		"target_languages": target_languages,
		"service": service_name,
		"template": template_name  # 添加模板信息
	}
	
	# 调用原始的CSV翻译方法
	var result = await translate_godot_csv_with_output(file_path, output_path, source_lang, target_languages, service_name)
	
	# 恢复原始翻译信息
	current_translation_info = original_info
	
	return result

## 生成输出文件路径
func _generate_output_path(original_path: String, target_lang: String) -> String:
	var base_name = original_path.get_basename()
	var extension = original_path.get_extension()
	return base_name + "_" + target_lang + "." + extension
