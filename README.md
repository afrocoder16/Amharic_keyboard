# Amharic Keyboard for iPhone

A native iOS Custom Keyboard Extension for Amharic (Ethiopic/ግዕዝ) speakers, built with Swift. Works system-wide in any iPhone app — just like Gboard or SwiftKey.

## Features

| Feature | Description |
|---------|-------------|
| **Amharic Keyboard** | QWERTY Latin layout with transliteration: type `selam` → `ሰላም` |
| **Handwriting Input** | Draw Ethiopic characters by hand; tap candidates to insert |
| **Word Predictions** | Suggestion bar with prefix completion and bigram next-word |
| **Translation** | Amharic ↔ English translation via LibreTranslate API |

## Project Structure

```
AmharicKeyboard/
├── Shared/                     # Local Swift Package (AmharicCore)
│   ├── Sources/AmharicCore/
│   │   ├── Transliteration/    # TransliterationEngine, EthiopicCharacterMap
│   │   ├── Prediction/         # WordPredictionEngine, WordFrequencyStore
│   │   ├── Handwriting/        # StrokeRecognizer ($N algorithm), StrokeNormalizer
│   │   └── Translation/        # LibreTranslateClient, TranslationCache
│   └── Resources/
│       ├── amharic_wordlist.txt     # Word frequency list
│       ├── amharic_bigrams.json     # Bigram next-word table
│       └── ethiopic_strokes.json   # Handwriting recognition templates
│
├── ContainerApp/               # Required iOS host app (onboarding + settings guide)
├── KeyboardExtension/          # UIInputViewController keyboard extension
│   ├── KeyboardViewController.swift
│   └── Views/
│       ├── TypingMode/         # QWERTY keyboard with transliteration
│       ├── HandwritingMode/    # Canvas + stroke recognition + candidates
│       ├── TranslationMode/    # Amharic ↔ English translation panel
│       ├── TabBar/             # Keyboard / Draw / Translate tabs
│       └── Shared/             # SuggestionBarView, KeyboardTheme
└── setup_xcode_project.sh      # Helper script to generate Xcode project
```

## Getting Started

### Requirements
- Mac with Xcode 15+
- iPhone running iOS 16+ (or Simulator)
- Apple Developer account (free account works for Simulator testing)

### Setup

**Option A — Using xcodegen (recommended):**
```bash
brew install xcodegen
# Edit BUNDLE_PREFIX in setup_xcode_project.sh first
bash setup_xcode_project.sh
open AmharicKeyboard.xcodeproj
```

**Option B — Manual Xcode setup:**
1. Open Xcode → File → New → Project → iOS App → Name: `AmharicKeyboard`
2. Add a new target: File → New → Target → **Custom Keyboard Extension** → Name: `KeyboardExtension`
3. Add local package: File → Add Package Dependencies → Add Local → select `Shared/`
4. Link `AmharicCore` to **both** targets
5. Add App Group `group.com.amharickeyboard` to both targets' Signing & Capabilities
6. Drag source files from `ContainerApp/` and `KeyboardExtension/` into the respective targets
7. Replace the generated `KeyboardViewController.swift` with the one in this repo

### Enable on iPhone
1. Run the app on your iPhone
2. Go to **Settings → General → Keyboard → Keyboards → Add New Keyboard**
3. Select **Amharic**
4. Enable **Allow Full Access** for translation features
5. In any text field, tap the 🌐 globe key to switch to Amharic

## How Transliteration Works

The keyboard uses greedy longest-match transliteration. Type Latin characters and they are converted to Amharic syllables in real time:

| You type | You get | Notes |
|----------|---------|-------|
| `la` | `ላ` | 4th order (a vowel) |
| `le` | `ለ` | 1st order (e/neutral) |
| `sha` | `ሻ` | Digraph `sh` + vowel |
| `selam` | `ሰላም` | Full word |
| `Ethiopia` | `ኢትዮጵያ` | Transliterates naturally |

In-progress syllables appear underlined (marked text) until resolved.

## Translation API

The keyboard uses [LibreTranslate](https://libretranslate.com) by default. To use a self-hosted instance or different API, edit `LibreTranslateClient.swift`:

```swift
let service = LibreTranslateClient(
    baseURL: URL(string: "https://your-instance.example.com")!,
    apiKey: "your-api-key"  // optional
)
```

Translation requires **Allow Full Access** to be enabled in the keyboard settings.

## Contributing Word Data

To improve word predictions:
1. Download the [Amharic Wikipedia dump](https://dumps.wikimedia.org/amwiki/)
2. Process with `wikiextractor` + whitespace tokenization
3. Replace `Shared/Resources/amharic_wordlist.txt` with the frequency-ranked output
4. Update `amharic_bigrams.json` with bigram co-occurrence counts

To improve handwriting recognition:
1. Record real stroke samples using a template recording tool
2. Normalize and add entries to `Shared/Resources/ethiopic_strokes.json`
