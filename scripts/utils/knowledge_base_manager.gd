## 知识库管理器
## 
## 功能：
## - 本地术语库管理
## - 智能检索和匹配
## - 翻译提示增强
## - 不增加模型上下文负担

class_name KnowledgeBaseManager
extends RefCounted

# 内存缓存
var _term_cache: Dictionary = {}
var _context_rules: Array = []
var _hot_terms: Dictionary = {}

# 动态路径配置
var _config_manager: ConfigManager
var _kb_root_dir: String
var _documents_dir: String
var _index_dir: String
var _cache_dir: String

## 初始化知识库
func initialize(config_manager: ConfigManager = null):
	if config_manager:
		_config_manager = config_manager
	else:
		_config_manager = ConfigManager.new()
	
	# 检查知识库是否启用
	if not _config_manager.is_knowledge_base_enabled():
		print("ℹ️ 知识库功能已禁用，跳过初始化")
		return
	
	_update_paths()
	_ensure_directories()
	_load_cache()
	_load_context_rules()
	
	# 如果缓存为空，自动扫描并导入现有的术语文件
	if _term_cache.is_empty():
		_auto_import_existing_files()
	
	print("✅ 知识库管理器初始化完成，路径: ", _kb_root_dir, "，术语数量: ", _term_cache.size())

## 自动导入现有的术语文件
func _auto_import_existing_files():
	print("🔍 扫描现有术语文件...")
	
	# 扫描知识库根目录下的所有术语文件
	var files_to_import = []
	_scan_directory_for_terms(_kb_root_dir, files_to_import)
	
	if files_to_import.is_empty():
		print("ℹ️ 未找到现有术语文件")
		return
	
	print("📥 发现 ", files_to_import.size(), " 个术语文件，开始导入...")
	
	for file_info in files_to_import:
		var file_path = file_info.path
		var category = file_info.category
		
		print("  导入文件: ", file_path)
		var result = import_document(file_path, category)
		if result.success:
			print("  ✅ 导入成功")
		else:
			print("  ❌ 导入失败: ", result.error)

## 递归扫描目录查找术语文件
func _scan_directory_for_terms(dir_path: String, files_array: Array):
	var dir = DirAccess.open(dir_path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		
		var full_path = dir_path + "/" + file_name
		
		if dir.current_is_dir():
			# 递归扫描子目录
			_scan_directory_for_terms(full_path, files_array)
		else:
			# 检查是否是支持的术语文件
			var extension = file_name.get_extension().to_lower()
			if extension in ["txt", "csv", "json"]:
				var category = "game_terms"
				
				# 根据路径确定分类
				if "technical" in dir_path.to_lower():
					category = "technical_docs"
				elif "style" in dir_path.to_lower():
					category = "style_guides"
				
				files_array.append({
					"path": full_path,
					"category": category
				})
		
		file_name = dir.get_next()

## 更新路径配置
func _update_paths():
	_kb_root_dir = _config_manager.get_knowledge_base_root_path()
	_documents_dir = _kb_root_dir + "documents/"
	_index_dir = _kb_root_dir + "index/"
	_cache_dir = _kb_root_dir + "cache/"

## 确保目录存在
func _ensure_directories():
	var dirs = [_kb_root_dir, _documents_dir, _index_dir, _cache_dir,
				_documents_dir + "game_terms/",
				_documents_dir + "technical_docs/",
				_documents_dir + "style_guides/"]
	
	for dir_path in dirs:
		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.make_dir_recursive_absolute(dir_path)
			print("📁 创建目录: ", dir_path)

## 导入术语文档
func import_document(file_path: String, category: String = "game_terms") -> Dictionary:
	print("📥 开始导入文档: ", file_path)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {"success": false, "error": "无法打开文件"}
	
	var content = file.get_as_text()
	file.close()
	
	# 根据文件扩展名选择解析方式
	var terms = []
	var extension = file_path.get_extension().to_lower()
	
	match extension:
		"csv":
			terms = _parse_csv_terms(content)
		"json":
			terms = _parse_json_terms(content)
		"txt":
			terms = _parse_txt_terms(content)
		_:
			return {"success": false, "error": "不支持的文件格式"}
	
	if terms.is_empty():
		return {"success": false, "error": "未找到有效术语"}
	
	# 保存到知识库
	var kb_file_path = _documents_dir + category + "/" + file_path.get_file().get_basename() + ".json"
	var result = _save_terms_to_kb(kb_file_path, terms, category)
	
	if result.success:
		_update_index(terms, category)
		print("✅ 成功导入 ", terms.size(), " 个术语")
	
	return result

## 解析CSV术语
func _parse_csv_terms(content: String) -> Array:
	var terms = []
	var lines = content.split("\n")
	
	# 假设CSV格式：source,zh,en,ja,ru
	for i in range(1, lines.size()):  # 跳过标题行
		var line = lines[i].strip_edges()
		if line.is_empty():
			continue
		
		var parts = line.split(",")
		if parts.size() >= 3:
			var term = {
				"source": parts[0].strip_edges(),
				"target": {},
				"context": [],
				"confidence": 1.0,
				"frequency": 1
			}
			
			# 提取各语言翻译
			if parts.size() > 1 and not parts[1].is_empty():
				term.target["zh"] = parts[1].strip_edges()
			if parts.size() > 2 and not parts[2].is_empty():
				term.target["en"] = parts[2].strip_edges()
			if parts.size() > 3 and not parts[3].is_empty():
				term.target["ja"] = parts[3].strip_edges()
			if parts.size() > 4 and not parts[4].is_empty():
				term.target["ru"] = parts[4].strip_edges()
			
			terms.append(term)
	
	return terms

## 解析JSON术语
func _parse_json_terms(content: String) -> Array:
	var json = JSON.new()
	var parse_result = json.parse(content)
	
	if parse_result != OK:
		print("❌ JSON解析失败: ", json.get_error_message())
		return []
	
	var data = json.data
	if data is Dictionary and data.has("terms"):
		var terms_data = data.terms
		
		# 如果是Dictionary格式（缓存文件），转换为Array
		if terms_data is Dictionary:
			var terms_array = []
			for key in terms_data.keys():
				terms_array.append(terms_data[key])
			return terms_array
		# 如果是Array格式（原始文件），直接返回
		elif terms_data is Array:
			return terms_data
	elif data is Array:
		return data
	
	return []

## 解析TXT术语
func _parse_txt_terms(content: String) -> Array:
	var terms = []
	var lines = content.split("\n")
	
	# 支持两种格式：
	# 1. 简单格式：source = target
	# 2. 多语言格式：source = {"en": "英文", "ja": "日文", "ru": "俄文", "zh-TW": "繁体中文"}
	for line in lines:
		line = line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		
		var parts = line.split("=", false, 1)  # 只分割第一个等号
		if parts.size() == 2:
			var source_text = parts[0].strip_edges()
			var target_text = parts[1].strip_edges()
			
			var term = {
				"source": source_text,
				"target": {},
				"context": [],
				"confidence": 0.8,
				"frequency": 1
			}
			
			# 检查是否是JSON格式的多语言翻译
			if target_text.begins_with("{") and target_text.ends_with("}"):
				# 解析JSON格式的多语言翻译
				var json = JSON.new()
				var parse_result = json.parse(target_text)
				
				if parse_result == OK and json.data is Dictionary:
					term.target = json.data
					print("✅ 解析多语言术语: ", source_text, " -> ", json.data)
				else:
					print("❌ JSON解析失败，使用简单格式: ", target_text)
					# 如果JSON解析失败，回退到简单格式
					var target_lang = _detect_language(target_text)
					term.target[target_lang] = target_text
			else:
				# 简单格式：智能检测目标语言
				var target_lang = _detect_language(target_text)
				term.target[target_lang] = target_text
			
			terms.append(term)
	
	return terms

## 简单的语言检测函数
func _detect_language(text: String) -> String:
	# 检测是否包含中文字符
	var has_chinese = false
	for i in range(text.length()):
		var char_code = text.unicode_at(i)
		# 中文字符范围：0x4E00-0x9FFF
		if char_code >= 0x4E00 and char_code <= 0x9FFF:
			has_chinese = true
			break
	
	# 如果包含中文，返回中文代码
	if has_chinese:
		return "zh"
	
	# 否则假设是英文
	return "en"

## 保存术语到知识库
func _save_terms_to_kb(file_path: String, terms: Array, category: String) -> Dictionary:
	var kb_data = {
		"metadata": {
			"version": "1.0",
			"last_updated": Time.get_datetime_string_from_system(),
			"category": category,
			"term_count": terms.size()
		},
		"terms": terms
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return {"success": false, "error": "无法创建知识库文件"}
	
	file.store_string(JSON.stringify(kb_data, "\t"))
	file.close()
	
	return {"success": true, "file_path": file_path}

## 更新索引
func _update_index(terms: Array, category: String):
	# 更新术语映射索引
	for term in terms:
		var source = term.source.to_lower()
		_term_cache[source] = term
		
		# 更新频率统计
		if _hot_terms.has(source):
			_hot_terms[source] += 1
		else:
			_hot_terms[source] = 1
	
	# 保存索引到文件
	_save_index()

## 智能检索术语
func search_terms(query: String, max_results: int = 5) -> Array:
	# 检查知识库是否启用
	if not _config_manager or not _config_manager.is_knowledge_base_enabled():
		return []
	
	var results = []
	var query_lower = query.to_lower()
	
	# 1. 精确匹配
	if _term_cache.has(query_lower):
		results.append({
			"term": _term_cache[query_lower],
			"match_type": "exact",
			"confidence": 1.0
		})
	
	# 2. 模糊匹配
	for term_key in _term_cache.keys():
		if results.size() >= max_results:
			break
		
		# 跳过已经精确匹配的
		if term_key == query_lower:
			continue
		
		var similarity = _calculate_similarity(query_lower, term_key)
		if similarity > 0.6:  # 相似度阈值
			results.append({
				"term": _term_cache[term_key],
				"match_type": "fuzzy",
				"confidence": similarity
			})
	
	# 3. 按置信度排序
	results.sort_custom(func(a, b): return a.confidence > b.confidence)
	
	return results.slice(0, max_results)

## 计算字符串相似度（简化版编辑距离）
func _calculate_similarity(str1: String, str2: String) -> float:
	var len1 = str1.length()
	var len2 = str2.length()
	
	if len1 == 0 or len2 == 0:
		return 0.0
	
	# 简化版：基于公共子串长度
	var common_chars = 0
	var min_len = min(len1, len2)
	
	for i in range(min_len):
		if str1[i] == str2[i]:
			common_chars += 1
		else:
			break
	
	# 检查包含关系
	if str1 in str2 or str2 in str1:
		return 0.8
	
	return float(common_chars) / float(max(len1, len2))

## 为翻译增强提示
func enhance_prompt(source_text: String, source_lang: String, target_lang: String, base_prompt: String) -> String:
	print("=== 知识库增强提示词调试 ===")
	print("源文本: ", source_text)
	print("源语言: ", source_lang)
	print("目标语言: ", target_lang)
	
	# 检查知识库是否启用
	if not _config_manager or not _config_manager.is_knowledge_base_enabled():
		print("❌ 知识库未启用，返回原始提示词")
		return base_prompt
	
	var search_results = search_terms(source_text, 3)
	print("搜索结果数量: ", search_results.size())
	
	if search_results.is_empty():
		print("❌ 没有找到匹配的术语，返回原始提示词")
		return base_prompt
	
	var enhancement = "\n\n参考术语库："
	var has_enhancement = false
	
	for result in search_results:
		var term = result.term
		print("检查术语: ", term.source, " -> ", term.target)
		if term.target.has(target_lang):
			enhancement += "\n- \"" + term.source + "\" → \"" + term.target[target_lang] + "\""
			has_enhancement = true
			print("✅ 添加术语: ", term.source, " -> ", term.target[target_lang])
		else:
			print("❌ 术语没有目标语言翻译: ", target_lang)
	
	if has_enhancement:
		enhancement += "\n请参考上述术语保持翻译一致性。"
		var enhanced_prompt = base_prompt + enhancement
		print("✅ 增强后的提示词:")
		print("原始提示词: ", base_prompt)
		print("增强部分: ", enhancement)
		print("完整提示词: ", enhanced_prompt)
		print("=============================")
		return enhanced_prompt
	
	print("❌ 没有可用的术语增强，返回原始提示词")
	print("=============================")
	return base_prompt

## 加载缓存（带文件变化检测）
func _load_cache():
	var cache_file = _cache_dir + "term_cache.json"
	var should_reload = false
	
	if FileAccess.file_exists(cache_file):
		var file = FileAccess.open(cache_file, FileAccess.READ)
		if file:
			var json = JSON.new()
			var parse_result = json.parse(file.get_as_text())
			file.close()
			
			if parse_result == OK and json.data is Dictionary:
				var cache_data = json.data
				_term_cache = cache_data.get("terms", {})
				_hot_terms = cache_data.get("hot_terms", {})
				
				# 检查文件是否有变化
				var cached_file_info = cache_data.get("file_info", {})
				var current_file_info = _get_files_modification_info()
				
				should_reload = _has_files_changed(cached_file_info, current_file_info)
				
				if should_reload:
					print("🔄 检测到术语文件变化，重新加载...")
					_term_cache.clear()
					_hot_terms.clear()
				else:
					print("📋 已加载缓存: ", _term_cache.size(), " 个术语")
	else:
		should_reload = true
	
	# 如果需要重新加载，自动导入文件
	if should_reload:
		_auto_import_existing_files()

## 加载上下文规则
func _load_context_rules():
	var rules_file = _index_dir + "context_rules.json"
	if FileAccess.file_exists(rules_file):
		var file = FileAccess.open(rules_file, FileAccess.READ)
		if file:
			var json = JSON.new()
			var parse_result = json.parse(file.get_as_text())
			file.close()
			
			if parse_result == OK and json.data is Dictionary:
				_context_rules = json.data.get("rules", [])

## 保存索引
func _save_index():
	var index_data = {
		"terms": _term_cache,
		"hot_terms": _hot_terms,
		"last_updated": Time.get_datetime_string_from_system(),
		"file_info": _get_files_modification_info()
	}
	
	var file = FileAccess.open(_cache_dir + "term_cache.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(index_data, "\t"))
		file.close()

## 获取统计信息
func get_statistics() -> Dictionary:
	return {
		"total_terms": _term_cache.size(),
		"hot_terms_count": _hot_terms.size(),
		"cache_hit_rate": 0.895,  # 模拟数据
		"last_updated": Time.get_datetime_string_from_system()
	}

## 清理缓存
func clear_cache():
	_term_cache.clear()
	_hot_terms.clear()
	
	var cache_file = _cache_dir + "term_cache.json"
	if FileAccess.file_exists(cache_file):
		DirAccess.remove_absolute(cache_file)
	
	print("🗑️ 缓存已清理")

## 更改知识库路径（支持数据迁移）
func change_knowledge_base_path(new_path: String, migrate_data: bool = true) -> Dictionary:
	var old_path = _kb_root_dir
	var result = {"success": false, "error": "", "migrated_files": 0}
	
	# 验证新路径
	if new_path.is_empty():
		result.error = "路径不能为空"
		return result
	
	# 确保路径以/结尾
	if not new_path.ends_with("/"):
		new_path += "/"
	
	# 更新配置
	if not _config_manager.set_knowledge_base_root_path(new_path):
		result.error = "配置保存失败"
		return result
	
	# 如果需要迁移数据
	if migrate_data and DirAccess.dir_exists_absolute(old_path):
		var migration_result = _migrate_knowledge_base_data(old_path, new_path)
		result.migrated_files = migration_result.migrated_files
		if not migration_result.success:
			result.error = "数据迁移失败: " + migration_result.error
			return result
	
	# 更新路径并重新初始化
	_update_paths()
	_ensure_directories()
	_load_cache()
	_load_context_rules()
	
	result.success = true
	print("✅ 知识库路径已更改为: ", new_path)
	
	return result

## 迁移知识库数据
func _migrate_knowledge_base_data(old_path: String, new_path: String) -> Dictionary:
	var result = {"success": false, "error": "", "migrated_files": 0}
	
	# 创建新目录
	if not DirAccess.make_dir_recursive_absolute(new_path):
		result.error = "无法创建新目录"
		return result
	
	# 复制文件
	var dir = DirAccess.open(old_path)
	if not dir:
		result.error = "无法访问旧目录"
		return result
	
	var copy_result = _copy_directory_recursive(old_path, new_path)
	result.migrated_files = copy_result.copied_files
	
	if copy_result.success:
		result.success = true
		print("📦 已迁移 ", result.migrated_files, " 个文件")
	else:
		result.error = copy_result.error
	
	return result

## 递归复制目录
func _copy_directory_recursive(source_dir: String, target_dir: String) -> Dictionary:
	var result = {"success": false, "error": "", "copied_files": 0}
	
	var source = DirAccess.open(source_dir)
	if not source:
		result.error = "无法打开源目录"
		return result
	
	# 确保目标目录存在
	DirAccess.make_dir_recursive_absolute(target_dir)
	
	source.list_dir_begin()
	var file_name = source.get_next()
	
	while file_name != "":
		var source_path = source_dir + "/" + file_name
		var target_path = target_dir + "/" + file_name
		
		if source.current_is_dir():
			# 递归复制子目录
			var sub_result = _copy_directory_recursive(source_path, target_path)
			result.copied_files += sub_result.copied_files
			if not sub_result.success:
				result.error = sub_result.error
				return result
		else:
			# 复制文件
			if source.copy(source_path, target_path) == OK:
				result.copied_files += 1
			else:
				result.error = "复制文件失败: " + file_name
				return result
		
		file_name = source.get_next()
	
	result.success = true
	return result

## 获取当前知识库路径
func get_current_path() -> String:
	return _kb_root_dir

## 验证知识库路径
func validate_path(path: String) -> Dictionary:
	var result = {"valid": false, "error": "", "writable": false, "has_data": false}
	
	if path.is_empty():
		result.error = "路径不能为空"
		return result
	
	# 检查路径是否可访问
	var dir = DirAccess.open(path)
	if not dir:
		# 尝试创建目录
		if DirAccess.make_dir_recursive_absolute(path) != OK:
			result.error = "无法创建或访问该路径"
			return result
		dir = DirAccess.open(path)
	
	# 检查是否可写
	var test_file = path + "/test_write.tmp"
	var file = FileAccess.open(test_file, FileAccess.WRITE)
	if file:
		file.store_string("test")
		file.close()
		DirAccess.remove_absolute(test_file)
		result.writable = true
	else:
		result.error = "目录不可写"
		return result
	
	# 检查是否已有知识库数据
	if DirAccess.dir_exists_absolute(path + "/documents/") or DirAccess.dir_exists_absolute(path + "/index/"):
		result.has_data = true
	
	result.valid = true
	return result

## 获取所有术语文件的修改信息
func _get_files_modification_info() -> Dictionary:
	var file_info = {}
	var files_to_check = []
	
	# 扫描所有术语文件
	_scan_directory_for_terms(_kb_root_dir, files_to_check)
	
	for file_data in files_to_check:
		var file_path = file_data.path
		if FileAccess.file_exists(file_path):
			# 获取文件修改时间和大小
			var modified_time = FileAccess.get_modified_time(file_path)
			var file_access = FileAccess.open(file_path, FileAccess.READ)
			var file_size = 0
			if file_access:
				file_size = file_access.get_length()
				file_access.close()
			
			# 使用相对路径作为key，保持一致性
			var relative_path = file_path.replace(_kb_root_dir, "data/knowledge_base/")
			file_info[relative_path] = {
				"modified_time": modified_time,
				"size": file_size
			}
	
	return file_info

## 检查文件是否有变化
func _has_files_changed(cached_info: Dictionary, current_info: Dictionary) -> bool:
	# 检查文件数量是否变化
	if cached_info.size() != current_info.size():
		return true
	
	# 检查每个文件的修改时间和大小
	for file_path in current_info.keys():
		if not cached_info.has(file_path):
			return true  # 新文件
		
		var cached_file = cached_info[file_path]
		var current_file = current_info[file_path]
		
		if cached_file.modified_time != current_file.modified_time or \
		   cached_file.size != current_file.size:
			return true  # 文件已修改
	
	# 检查是否有文件被删除
	for file_path in cached_info.keys():
		if not current_info.has(file_path):
			return true  # 文件被删除
	
	return false
