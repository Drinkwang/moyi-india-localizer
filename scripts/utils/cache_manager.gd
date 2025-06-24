class_name CacheManager
extends RefCounted

## 缓存管理器
## 负责管理翻译结果的缓存

const CACHE_FILE_PATH = "user://translation_cache.dat"
const MAX_CACHE_SIZE = 10000  # 最大缓存条目数

var cache_data: Dictionary = {}
var cache_size: int = 0

func _init():
	load_cache()

## 获取翻译缓存
func get_translation(cache_key: String) -> String:
	if cache_data.has(cache_key):
		# 更新访问时间
		cache_data[cache_key]["last_accessed"] = Time.get_unix_time_from_system()
		return cache_data[cache_key]["text"]
	return ""

## 保存翻译到缓存
func save_translation(cache_key: String, translated_text: String):
	var current_time = Time.get_unix_time_from_system()
	
	# 如果缓存已满，清理最旧的条目
	if cache_size >= MAX_CACHE_SIZE and not cache_data.has(cache_key):
		_cleanup_old_entries()
	
	# 保存翻译
	if not cache_data.has(cache_key):
		cache_size += 1
	
	cache_data[cache_key] = {
		"text": translated_text,
		"created": current_time,
		"last_accessed": current_time
	}
	
	# 异步保存到文件
	call_deferred("_save_cache_to_file")

## 清理缓存
func clear_cache():
	cache_data.clear()
	cache_size = 0
	_save_cache_to_file()

## 从文件加载缓存
func load_cache():
	var file = FileAccess.open(CACHE_FILE_PATH, FileAccess.READ)
	if not file:
		return
	
	var cache_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(cache_string)
	
	if parse_result == OK and json.data is Dictionary:
		cache_data = json.data
		cache_size = cache_data.size()
	else:
		print("警告: 缓存文件格式错误，已重置缓存")
		cache_data = {}
		cache_size = 0

## 保存缓存到文件
func _save_cache_to_file():
	var file = FileAccess.open(CACHE_FILE_PATH, FileAccess.WRITE)
	if not file:
		print("错误: 无法保存缓存文件")
		return
	
	var json_string = JSON.stringify(cache_data)
	file.store_string(json_string)
	file.close()

## 清理旧的缓存条目
func _cleanup_old_entries():
	var entries_to_remove = []
	var current_time = Time.get_unix_time_from_system()
	
	# 找出最久未访问的条目
	for key in cache_data.keys():
		var entry = cache_data[key]
		var last_accessed = entry.get("last_accessed", 0)
		entries_to_remove.append({
			"key": key,
			"last_accessed": last_accessed
		})
	
	# 按访问时间排序
	entries_to_remove.sort_custom(func(a, b): return a.last_accessed < b.last_accessed)
	
	# 删除最旧的25%条目
	var remove_count = max(1, cache_size / 4)
	for i in range(remove_count):
		var key_to_remove = entries_to_remove[i]["key"]
		cache_data.erase(key_to_remove)
		cache_size -= 1

## 获取缓存统计信息
func get_cache_stats() -> Dictionary:
	return {
		"size": cache_size,
		"max_size": MAX_CACHE_SIZE,
		"hit_rate": _calculate_hit_rate()
	}

## 计算缓存命中率
func _calculate_hit_rate() -> float:
	# 这里可以实现更复杂的统计逻辑
	return 0.0 