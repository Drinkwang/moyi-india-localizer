# 知识库功能实现总结

## 概述

本文档总结了翻译工具中知识库功能的完整实现，包括核心功能、UI集成、服务集成和使用方法。

## 核心组件

### 1. 知识库管理器 (`KnowledgeBaseManager`)
- **文件位置**: `scripts/utils/knowledge_base_manager.gd`
- **主要功能**:
  - 术语管理（添加、删除、更新、搜索）
  - 提示词增强
  - 相似度计算
  - 数据持久化

### 2. 配置管理器 (`ConfigManager`)
- **文件位置**: `scripts/utils/config_manager.gd`
- **知识库相关配置**:
  - `is_knowledge_base_enabled()`: 检查知识库是否启用
  - `set_knowledge_base_enabled(enabled)`: 设置知识库启用状态
  - `get_knowledge_base_root_path()`: 获取知识库根路径
  - `set_knowledge_base_root_path(path)`: 设置知识库根路径
  - `set_knowledge_base_similarity_threshold(threshold)`: 设置相似度阈值
  - `set_knowledge_base_cache_size(size)`: 设置缓存大小

## UI 集成

### 1. 主界面集成
- **文件位置**: `scenes/main/main.tscn` 和 `scenes/main/main.gd`
- **UI 组件**:
  - 知识库配置按钮 (`KnowledgeBaseConfigButton`)
  - 知识库启用复选框 (`kb_enabled_check`)
  - 知识库配置对话框 (`KnowledgeBaseConfigDialog`)

### 2. 配置对话框功能
- 启用/禁用知识库功能
- 设置知识库路径
- 配置相似度阈值
- 设置缓存大小
- 数据迁移和备份选项

## 翻译服务集成

所有翻译服务都已集成知识库功能，包括以下新增方法：

### 1. Claude 服务 (`claude_service.gd`)
```gdscript
# 使用知识库增强翻译
func translate_with_knowledge_base(text: String, source_lang: String, target_lang: String, knowledge_base_manager: KnowledgeBaseManager) -> Dictionary

# 使用模板翻译
func translate_with_template(text: String, source_lang: String, target_lang: String, template: String) -> Dictionary

# 使用模板和知识库增强翻译
func translate_with_template_and_knowledge_base(text: String, source_lang: String, target_lang: String, template: String, knowledge_base_manager: KnowledgeBaseManager) -> Dictionary
```

### 2. 本地模型服务 (`local_model_service.gd`)
- 支持 Ollama 和 LocalAI 提供商
- 实现了相同的知识库增强方法
- 根据提供商类型选择不同的请求格式

### 3. 百度翻译服务 (`baidu_translate_service.gd`)
- 虽然百度翻译 API 不支持自定义提示词
- 为保持接口一致性，实现了相同的方法
- 这些方法直接调用原始的 `translate` 方法

### 4. 腾讯翻译服务 (`tencent_translate_service.gd`)
- 与百度翻译服务类似
- 实现了知识库相关方法以保持接口一致性
- 直接调用原始的 `translate` 方法

## 知识库数据结构

### 术语结构
```gdscript
{
    "id": "唯一标识符",
    "source": "源文本",
    "target": {
        "zh": "中文翻译",
        "en": "英文翻译",
        "ja": "日文翻译"
        # 其他语言...
    },
    "context": "使用上下文",
    "category": "分类标签",
    "created_at": "创建时间",
    "updated_at": "更新时间"
}
```

### 搜索结果结构
```gdscript
{
    "term": "术语对象",
    "similarity": "相似度分数 (0.0-1.0)"
}
```

## 使用流程

### 1. 启用知识库功能
1. 打开主界面的知识库配置对话框
2. 勾选"启用知识库功能"复选框
3. 设置知识库路径（可选）
4. 配置相似度阈值和缓存大小（可选）
5. 点击"应用"保存配置

### 2. 添加术语
```gdscript
var kb_manager = KnowledgeBaseManager.new()
kb_manager.initialize(config_manager)

var result = kb_manager.add_term(
    "Player",                           # 源文本
    {"zh": "玩家", "ja": "プレイヤー"},    # 目标翻译
    "游戏角色",                         # 上下文
    "game_ui"                          # 分类
)
```

### 3. 搜索术语
```gdscript
var search_results = kb_manager.search_terms("Player health", 5)
for result in search_results:
    print("术语: %s, 相似度: %.2f" % [result.term.source, result.similarity])
```

### 4. 增强翻译提示
```gdscript
var base_prompt = "请将以下英文翻译成中文："
var enhanced_prompt = kb_manager.enhance_prompt(
    "Player health is low",  # 待翻译文本
    "en",                   # 源语言
    "zh",                   # 目标语言
    base_prompt             # 基础提示
)
```

## 配置选项

### 知识库设置
- **启用状态**: 控制知识库功能的开启/关闭
- **根路径**: 知识库数据存储位置
- **相似度阈值**: 术语匹配的最低相似度要求 (默认: 0.7)
- **缓存大小**: 内存中缓存的术语数量 (默认: 1000)

### 高级选项
- **自动备份**: 定期备份知识库数据
- **数据迁移**: 在更改路径时迁移现有数据

## 性能优化

### 1. 缓存机制
- 内存缓存常用术语
- 可配置缓存大小
- LRU 缓存策略

### 2. 相似度计算
- 使用高效的字符串相似度算法
- 可配置相似度阈值
- 早期退出优化

### 3. 数据存储
- JSON 格式存储
- 增量保存
- 压缩存储选项

## 测试

### 测试脚本
- **文件位置**: `test_knowledge_base_integration.gd`
- **测试内容**:
  - 配置管理器功能
  - 知识库管理器基础功能
  - 术语添加和搜索
  - 提示词增强

### 运行测试
```bash
# 在项目根目录运行
godot --headless --script test_knowledge_base_integration.gd
```

## 故障排除

### 常见问题
1. **知识库无法启用**
   - 检查路径权限
   - 确认路径存在
   - 查看错误日志

2. **术语搜索无结果**
   - 检查相似度阈值设置
   - 确认术语已正确添加
   - 验证搜索关键词

3. **提示词未增强**
   - 确认知识库已启用
   - 检查是否有匹配的术语
   - 验证目标语言设置

### 调试方法
- 启用详细日志输出
- 使用测试脚本验证功能
- 检查配置文件内容

## 未来扩展

### 计划功能
1. **术语导入/导出**
   - 支持 CSV、Excel 格式
   - 批量导入功能
   - 数据验证

2. **智能术语建议**
   - 基于翻译历史自动建议术语
   - 机器学习优化
   - 用户反馈集成

3. **多用户协作**
   - 共享知识库
   - 版本控制
   - 冲突解决

4. **高级搜索**
   - 正则表达式搜索
   - 分类过滤
   - 时间范围筛选

## 总结

知识库功能已完全集成到翻译工具中，提供了：
- ✅ 完整的术语管理系统
- ✅ 直观的用户界面
- ✅ 所有翻译服务的集成
- ✅ 灵活的配置选项
- ✅ 性能优化和缓存
- ✅ 测试和调试工具

该功能可以显著提高翻译的一致性和准确性，特别适用于专业术语较多的翻译场景。