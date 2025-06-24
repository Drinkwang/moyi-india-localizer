# Unity Localization Package 翻译功能使用指南

## 🎯 功能概述

Unity多语言翻译功能专门支持Unity Localization Package生成的JSON格式文件，能够智能识别文本条目并进行批量翻译，同时保持Unity本地化系统的完整性。

## 🚀 快速开始

### 1. 选择翻译模式
在主界面的"翻译模式"下拉菜单中选择 **"Unity多语言文件"**

### 2. 选择Unity文件
1. 点击 **"选择文件"** 按钮
2. 浏览并选择Unity Localization Package导出的JSON文件
3. 系统会自动验证文件格式

### 3. 配置语言设置
- **源语言代码**：输入源语言（默认：`en`）
- **目标语言代码**：输入目标语言，用逗号分隔（默认：`zh-CN,ja,ko,ru`）

### 4. 开始翻译
1. 选择翻译服务（需要预先配置API密钥）
2. 点击 **"翻译Unity文件"** 开始处理
3. 查看实时翻译进度和结果

## 📁 支持的Unity文件格式

### Unity Localization Package JSON格式

#### 标准格式
```json
{
  "StringDatabase": {
    "Tables": [
      {
        "TableCollectionName": "UI Text",
        "SharedTableData": {
          "Entries": [
            {"Id": 1, "Key": "menu_start"},
            {"Id": 2, "Key": "menu_settings"}
          ]
        },
        "TableData": [
          {
            "LocaleIdentifier": "en",
            "Entries": [
              {"Id": 1, "Value": "Start Game"},
              {"Id": 2, "Value": "Settings"}
            ]
          }
        ]
      }
    ]
  }
}
```

## 🎮 语言代码规范

### Unity常用语言代码
```
en        - 英语
zh-CN     - 简体中文
zh-TW     - 繁体中文
ja        - 日语
ko        - 韩语
ru        - 俄语
fr        - 法语
de        - 德语
es        - 西班牙语
```

## 🎯 最佳实践

### 1. 文件准备
- ✅ **使用标准导出**：从Unity Localization Package导出标准JSON格式
- ✅ **保持完整性**：确保包含所有必要的元数据字段
- ✅ **备份原文件**：翻译前备份原始文件

### 2. 语言配置
- 🎯 **确认源语言**：确保源语言代码与文件中的实际语言匹配
- 🌍 **选择目标语言**：根据游戏发布地区选择合适的目标语言
- 📝 **使用标准代码**：采用Unity支持的标准语言代码

### 3. 翻译质量
- 🎮 **游戏术语一致性**：保持游戏专有名词的翻译一致性
- 📱 **界面适配**：考虑不同语言文本长度对UI的影响
- 🎭 **文化适应**：适应目标语言的文化和表达习惯

## 🛠️ 故障排除

### 常见问题

**问题1：文件格式不支持**
```
❌ 不是有效的Unity Localization Package格式
```
**解决方案：**
- 确认文件来自Unity Localization Package
- 检查JSON格式是否正确
- 验证必要字段是否存在

**问题2：未找到源语言条目**
```
❌ 未找到源语言 'en' 的文本条目
```
**解决方案：**
- 检查源语言代码是否正确
- 确认文件中是否包含该语言的数据
- 验证LocaleIdentifier字段的值

这个翻译功能让Unity游戏的多语言本地化变得更加简单和高效！🎮✨ 