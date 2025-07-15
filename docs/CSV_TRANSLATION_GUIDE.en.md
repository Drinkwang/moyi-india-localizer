# Guide: Translating Multi-language CSV Files

## 🎮 Introduction

This tool includes a feature specifically for translating CSV files, allowing you to automatically add support for multiple languages to your game.

## 📁 Supported File Format

### Multi-language CSV Format
```csv
keys,en
HELLO_WORLD,Hello World
GAME_START,Start Game
MENU_SETTINGS,Settings
```

- **First Column**: Key name (usually uppercase letters and underscores).
- **Second and Subsequent Columns**: Translated text for various languages.
- **First Row**: Header row containing language codes.

## 🔧 How to Use

### 1. Switch to CSV Translation Mode
- In the "Translation Mode" dropdown on the main interface, select "CSV Translation".

### 2. Select a CSV File
- Click the "Select File" button.
- Choose your CSV file.
- Supported files: *.csv

### 3. Configure Language Settings
- **Source Language Code**: Enter the existing source language code (e.g., `en`).
- **Target Language Codes**: Enter the language codes to add, separated by commas (e.g., `zh,ja,ru,lzh`).

### 4. Choose a Translation Service
- Select the AI translation service you want to use.
- Supported: OpenAI, Claude, Baidu Translate, Tencent Translate, Local Models.

### 5. Start Translating
- Click the "Translate CSV" button.
- Wait for the translation to complete, monitoring the progress bar.

## 🌐 Supported Language Codes

### Common Language Codes
- `en` - English
- `zh` - Chinese (Simplified)
- `ja` - Japanese (日本語)
- `ko` - Korean (한국어)
- `ru` - Russian (Русский)
- `es` - Spanish (Español)
- `fr` - French (Français)
- `de` - German (Deutsch)
- `lzh` - Literary Chinese

### Custom Language Codes
You can use any custom language code; the tool will automatically create a corresponding column.

## 📝 Output

### File Naming
- **Original File**: `localization.csv`
- **Output File**: `localization_multilang.csv`

### File Content
The tool adds new language columns to your original CSV file:

**Before:**
```csv
keys,en
HELLO_WORLD,Hello World
GAME_START,Start Game
```

**After:**
```csv
keys,en,zh,ja,ru,lzh
HELLO_WORLD,Hello World,你好世界,こんにちは世界,Привет мир,你好世界
GAME_START,Start Game,Start Game,ゲーム開始,Начать игру,開始遊戲
```

## 💡 Tips & Tricks

### 1. Batch Language Addition
Add multiple languages at once:
```
zh,ja,ko,ru,es,fr,de
```

### 2. Step-by-Step Translation
For a large number of languages, you can translate in batches:
- **First pass**: `zh,ja`
- **Second pass**: `ko,ru`
- **Third pass**: `es,fr,de`

### 3. Quality Check
- After translation, it's recommended to manually review important text.
- Pay special attention to the accuracy of game-specific terminology.

## ⚠️ Important Notes

### File Requirements
1. The CSV file must be UTF-8 encoded.
2. The first column must be the key name.
3. Key names should ideally be uppercase with underscores.

### Translation Quality
1. AI translation may not be perfect; manual proofreading is advised.
2. Professional game terminology might require manual adjustments.
3. Be mindful of significant grammatical differences between languages.

### Performance
1. For large files, consider processing in batches.
2. Local models are slower but offer more privacy.
3. Web APIs require a stable internet connection.

## 🛠️ Troubleshooting

### Common Issues

**Problem: File format error**
- Check if the CSV file follows the expected format.
- Ensure the first column is for keys and the first row is the header.

**Problem: Source language column not found**
- Verify that the source language code you entered exists in the CSV header.
- Language codes are case-sensitive.

**Problem: Translation failed**
- Check your internet connection.
- Verify that your API key is correct.
- Confirm the translation service configuration.

**Problem: Output file is empty**
- Check for file write permissions.
- Ensure the target directory exists.

## 📚 Example File

The project includes a sample file `data/sample_localization.csv` that you can use to test the translation feature.

It contains common game UI text and serves as a great starting point for learning and testing. 
