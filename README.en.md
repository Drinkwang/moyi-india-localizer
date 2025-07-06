# AI Game Dev Translation Tool

An AI-powered translation software built with Godot, specifically designed for translating text in game development. It supports local large language models (LLMs) and various online API services.

> 👨‍💻 **Developer**: [Peng Yan (鹏砚)](https://space.bilibili.com/13061595) | 🤖 **AI Co-developer**: Built in collaboration with Claude AI

## 🎉 New Feature Highlights

### 🚀 Real API Translation
- **No More Mock-ups** - All major AI services now use real API calls.
- **Instant Translation** - Ready to use immediately after configuring your API keys.
- **High-Quality Results** - Utilizes real AI models for professional-grade translations.
- **Error Handling** - Comes with complete error reporting and retry mechanisms.

### 🎮 Dedicated CSV Translation
- **Batch Language Addition** - Add support for multiple languages to your game at once.
- **Smart Format Protection** - Preserves your CSV structure and key integrity.
- **Incremental Translation** - Intelligently skips already translated entries, perfect for iterative work.

### ⚙️ Visual AI Service Configuration
- **Built-in Config UI** - No need to manually edit configuration files.
- **Multi-Service Support** - OpenAI, Claude, Baidu Translate, local models, DeepSeek, etc.
- **One-Click Connection Test** - Verify your API configuration instantly.
- **Hot-Reloading** - Changes take effect immediately after saving.

### 🌐 Custom Language Configuration
- **Flexible Definitions** - Define the meaning of any language code yourself.
- **Visual Management** - Add, modify, and delete language mappings through a GUI.
- **Default Overrides** - Easily change the default meaning of codes like `lzh`.
- **Instant Effect** - Configurations are applied across all AI services right away.

## Features

- 🤖 **Multiple AI Translation Services**
  - Local LLMs (Ollama, LocalAI, etc.)
  - Web APIs (OpenAI, Claude, Baidu Translate, Tencent Translate, etc.)
- 🎮 **Optimized for Game Development**
  - Dedicated processor for multi-language CSV files (compatible with Unity, Godot, Unreal).
  - Translation for code files like GDScript, C#, JSON, etc.
- 🔧 **Visual Configuration Interface**
  - Graphical setup for AI services.
  - Dual translation modes (Basic Text / CSV Translation).
- 📁 **Batch File Translation**
  - Support for various programming language file formats.
  - Smart content recognition and protection.
- 🎨 **Modern UI Design**
  - Intuitive user interface.
  - Real-time progress display.

## 🚀 Quick Start

### Installation
1. Clone the project to your local machine.
2. Open the project with Godot 4.x.
3. Run the main scene: `scenes/main/main.tscn`.

### ⚡ Quick Translation Guide
1. **Configure AI Service**: Click "Configure AI Service" and set up your API key.
2. **Select Mode**: Choose "CSV Translation" or "Basic Text Translation".
3. **Start Translating**:
   - **CSV Mode**: Select a file → Leave language settings empty (to use defaults) → Click "Translate CSV".
   - **Text Mode**: Enter text → Select languages → Click "Translate".
4. **View Results**: Check the output and status messages after completion.

### 💡 First-Time Use Recommendations
- **Recommended Service**: DeepSeek (cost-effective) or OpenAI (stable and reliable).
- **Test Connection**: Always use the "Test Connection" feature after configuration.
- **Start Small**: Translate a small batch of content first to test the results.

## 🔧 AI Service Configuration

#### ⚠️ Important: Using Real APIs
This tool now uses real API calls, which means you need to:
1. **Get API Keys** - Obtain valid API keys from the respective service providers.
2. **Mind the Cost** - Real API calls will incur costs. Use them wisely.
3. **Network Access** - Ensure your network can reach the API services.

#### Method 1: Visual Configuration (Recommended)
1. After running the project, click the "**Configure AI Service**" button.
2. In the dialog:
   - Select the tab for the AI service you want to use.
   - Check "Enable XXX Service".
   - Fill in your valid API key and other settings.
   - Click "**Save Configuration**".

## 🎮 Using CSV Translation

#### Step 1: Prepare Your CSV File
Ensure your CSV file is formatted correctly:
```csv
keys,en
HELLO_WORLD,Hello World
GAME_START,Start Game
```

#### Step 2: Start Translating
1. Select "**CSV Translation**" mode.
2. Click "**Select File**" and choose your CSV file.
3. **Source Language**: Enter `en` (or leave empty for default).
4. **Target Languages**: Enter `zh,ja,ru` (or leave empty for default).
5. Choose an AI translation service.
6. Click "**Translate CSV**".

## 💡 Tips & Tricks

#### Smart Default Settings
- **Default Source**: `zh` (Simplified Chinese) - Leave the field empty.
- **Default Targets**: `en,ja,ru,lzh` (English, Japanese, Russian, Traditional Chinese) - Leave the field empty.
- **Auto-Detection**: The system uses defaults automatically and displays the actual settings in the status bar.

#### 🌐 Language Configuration Management
1. **Open Language Config**: Click the "**Language Config**" button on the main screen.
2. **View Settings**: See a list of all language codes and their current meanings.
3. **Customize a Code**:
   - Enter a language code (e.g., `lzh`).
   - Enter a display name (e.g., `Literary Chinese`).
   - Click "**Add/Update**".
4. **Apply Changes**: Click "**Save Configuration**" to make the settings effective. 