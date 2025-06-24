# 知识库功能集成示例

## 📋 快速开始

### 1. 初始化知识库
```gdscript
# 在TranslationService中集成
var knowledge_base: KnowledgeBaseManager

func _ready():
    knowledge_base = KnowledgeBaseManager.new()
    knowledge_base.initialize()
```

### 2. 导入术语文档
```gdscript
# 导入CSV术语文件
var result = knowledge_base.import_document("data/game_terms.csv", "game_terms")
if result.success:
    print("✅ 术语导入成功")
else:
    print("❌ 导入失败: ", result.error)
```

### 3. 增强翻译提示
```gdscript
# 在翻译前增强提示
func translate_with_knowledge_base(text: String, source_lang: String, target_lang: String) -> String:
    var base_prompt = "请将以下{source_language}文本翻译成{target_language}：\n\n{text}"
    
    # 使用知识库增强提示
    var enhanced_prompt = knowledge_base.enhance_prompt(text, source_lang, target_lang, base_prompt)
    
    # 调用AI服务进行翻译
    return await ai_service.translate(enhanced_prompt)
```

## 🗂️ 支持的文档格式

### CSV格式示例
```csv
source,zh,en,ja,ru
Start Game,开始游戏,Start Game,ゲーム開始,Начать игру
Settings,设置,Settings,設定,Настройки
Exit,退出,Exit,終了,Выход
```

### JSON格式示例
```json
{
  "metadata": {
    "category": "game_terms",
    "version": "1.0"
  },
  "terms": [
    {
      "source": "Start Game",
      "target": {
        "zh": "开始游戏",
        "ja": "ゲーム開始",
        "ru": "Начать игру"
      },
      "context": ["main_menu", "button"],
      "confidence": 1.0
    }
  ]
}
```

### TXT格式示例
```txt
# 游戏界面术语
Start Game = 开始游戏
Settings = 设置
Exit = 退出
```

## 🔍 检索功能演示

### 基本检索
```gdscript
# 搜索相关术语
var results = knowledge_base.search_terms("start game", 5)
for result in results:
    print("匹配类型: ", result.match_type)
    print("置信度: ", result.confidence)
    print("术语: ", result.term.source, " → ", result.term.target.zh)
```

### 智能提示增强
```gdscript
# 原始提示
var base_prompt = "请将英文翻译成中文：Start Game"

# 增强后的提示
var enhanced_prompt = knowledge_base.enhance_prompt("Start Game", "en", "zh", base_prompt)
print(enhanced_prompt)

# 输出结果：
# 请将英文翻译成中文：Start Game
# 
# 参考术语库：
# - "Start Game" → "开始游戏"
# 请参考上述术语保持翻译一致性。
```

## 🎯 实际使用场景

### 场景1：游戏界面翻译
当翻译"Settings"时，知识库自动匹配到历史翻译"设置"，确保界面术语的一致性。

### 场景2：批量CSV翻译
在处理大型CSV文件时，知识库为每个术语提供一致性检查，避免同一术语的不同翻译。

### 场景3：上下文感知翻译
根据文本长度和类型，知识库应用不同的翻译规则，如按钮文本使用简洁风格。

## 📊 性能优化

### 缓存机制
- 热门术语保持在内存中
- 查询结果缓存提高响应速度
- 增量索引更新减少IO操作

### 检索优化
```gdscript
# 设置缓存大小
knowledge_base.set_cache_limit(1000)  # 缓存1000个常用术语

# 清理过期缓存
knowledge_base.cleanup_cache(30)  # 清理30天未使用的缓存

# 获取性能统计
var stats = knowledge_base.get_statistics()
print("缓存命中率: ", stats.cache_hit_rate)
```

## 🔧 高级配置

### 自定义相似度阈值
```gdscript
# 调整模糊匹配的相似度阈值
knowledge_base.set_similarity_threshold(0.7)  # 默认0.6
```

### 上下文规则配置
```json
{
  "context_rules": [
    {
      "rule_id": "ui_buttons",
      "conditions": {
        "text_length": {"max": 15},
        "category": "ui"
      },
      "actions": {
        "prefer_concise": true,
        "style_note": "按钮文本应简洁明了"
      }
    }
  ]
}
```

## 🧪 测试用例

### 基础功能测试
```gdscript
func test_knowledge_base():
    var kb = KnowledgeBaseManager.new()
    kb.initialize()
    
    # 测试导入
    var import_result = kb.import_document("test_terms.csv")
    assert(import_result.success, "导入应该成功")
    
    # 测试检索
    var search_results = kb.search_terms("start", 3)
    assert(search_results.size() > 0, "应该找到匹配结果")
    
    # 测试提示增强
    var enhanced = kb.enhance_prompt("Start Game", "en", "zh", "基础提示")
    assert("术语库" in enhanced, "应该包含术语库信息")
    
    print("✅ 所有测试通过")
```

## 📈 效果对比

### 使用前 vs 使用后

**使用前：**
```
原文: "Start Game"
翻译: "启动游戏"  # 可能不一致

原文: "Start"  
翻译: "开始"      # 术语不统一
```

**使用后：**
```
原文: "Start Game"
翻译: "开始游戏"  # 与术语库一致

原文: "Start"
翻译: "开始"      # 保持一致性，参考"Start Game"
```

## 🚀 部署建议

### 1. 渐进式部署
- 先在小范围项目中测试
- 逐步扩大术语库规模
- 收集用户反馈优化算法

### 2. 数据管理
- 定期备份术语库
- 建立术语审核流程
- 维护高质量的术语数据

### 3. 团队协作
- 使用版本控制管理术语库
- 建立术语贡献流程
- 定期同步团队术语库

## 💡 最佳实践

1. **术语库建设**：从现有翻译项目中提取高频术语
2. **质量控制**：定期审核和更新术语库
3. **性能监控**：监控检索性能和命中率
4. **用户反馈**：收集翻译人员的使用反馈
5. **持续优化**：根据使用数据优化算法和规则 