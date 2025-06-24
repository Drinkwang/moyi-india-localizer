class_name BaiduTranslateService
extends AIServiceBase

## 百度翻译服务实现
## 使用百度翻译API进行文本翻译

const API_ENDPOINT = "/api/trans/vip/translate"

var http_request: HTTPRequest
var app_id: String
var secret_key: String
var base_url: String

func _init(service_config: Dictionary = {}):
	super(service_config)
	
	app_id = config.get("app_id", "")
	secret_key = config.get("secret_key", "")
	base_url = config.get("base_url", "https://fanyi-api.baidu.com")
	
	# 创建HTTP请求节点
	http_request = HTTPRequest.new()

## 翻译文本
func translate(text: String, source_lang: String, target_lang: String) -> Dictionary:
	if not _validate_config():
		return {"success": false, "error": "配置无效"}
	
	# 百度翻译语言代码映射
	var from_lang = _map_language_code(source_lang)
	var to_lang = _map_language_code(target_lang)
	
	if from_lang.is_empty() or to_lang.is_empty():
		return {"success": false, "error": "不支持的语言"}
	
	# 生成签名
	var salt = str(Time.get_unix_time_from_system())
	var sign = _generate_sign(text, salt)
	
	# 构建请求参数
	var params = {
		"q": text,
		"from": from_lang,
		"to": to_lang,
		"appid": app_id,
		"salt": salt,
		"sign": sign
	}
	
	# 发送请求
	var response = await _send_request(params)
	
	if response.success:
		return _parse_translation_response(response.data)
	else:
		return {"success": false, "error": response.error}

## 测试连接
func test_connection() -> Dictionary:
	if not _validate_config():
		return {"success": false, "error": "配置无效: 缺少APP ID或密钥"}
	
	# 发送简单的测试请求
	var test_result = await translate("Hello", "en", "zh")
	return {"success": test_result.success, "error": test_result.get("error", "")}

## 验证配置
func _validate_config() -> bool:
	return not app_id.is_empty() and not secret_key.is_empty()

## 映射语言代码到百度翻译格式
func _map_language_code(lang_code: String) -> String:
	var lang_map = {
		"en": "en",
		"zh": "zh",
		"ja": "jp",
		"ko": "kor",
		"es": "spa",
		"fr": "fra",
		"de": "de",
		"ru": "ru"
	}
	return lang_map.get(lang_code, "")

## 生成百度翻译签名
func _generate_sign(query: String, salt: String) -> String:
	var sign_str = app_id + query + salt + secret_key
	return sign_str.md5_text()

## 发送HTTP请求
func _send_request(params: Dictionary) -> Dictionary:
	var url = base_url + API_ENDPOINT
	
	# 构建查询字符串
	var query_string = ""
	for key in params.keys():
		if not query_string.is_empty():
			query_string += "&"
		query_string += key + "=" + params[key].percent_encode()
	
	var full_url = url + "?" + query_string
	return await _send_http_request(full_url, [], HTTPClient.METHOD_GET)

## 解析翻译响应
func _parse_translation_response(data: Dictionary) -> Dictionary:
	if not data.has("trans_result") or data.trans_result.is_empty():
		# 检查是否有错误信息
		if data.has("error_code"):
			var error_msg = "百度翻译错误: " + str(data.error_code)
			if data.has("error_msg"):
				error_msg += " - " + data.error_msg
			return {"success": false, "error": error_msg}
		return {"success": false, "error": "响应格式错误"}
	
	var result = data.trans_result[0]
	if not result.has("dst"):
		return {"success": false, "error": "响应内容错误"}
	
	var translated_text = result.dst.strip_edges()
	return {"success": true, "translated_text": translated_text} 