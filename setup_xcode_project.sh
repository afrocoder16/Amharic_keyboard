#!/usr/bin/env bash
# =============================================================================
# setup_xcode_project.sh
# Creates the AmharicKeyboard Xcode project structure.
# Run this script on a Mac with Xcode 15+ installed.
# Usage: bash setup_xcode_project.sh
# =============================================================================

set -euo pipefail

PROJECT_NAME="AmharicKeyboard"
BUNDLE_PREFIX="com.yourname"          # ← CHANGE THIS to your Apple Developer bundle ID prefix
APP_GROUP="group.com.amharickeyboard"  # ← Must match entitlements files
DEPLOYMENT_TARGET="16.0"

echo "🔧 Setting up $PROJECT_NAME..."

# ── 1. Create Xcode project via xcodegen (if installed) ───────────────────────
if command -v xcodegen &> /dev/null; then
    echo "✅ xcodegen found — generating project..."
    cat > project.yml << YAML
name: $PROJECT_NAME
options:
  bundleIdPrefix: $BUNDLE_PREFIX
  deploymentTarget:
    iOS: "$DEPLOYMENT_TARGET"
  xcodeVersion: "15"
  generateEmptyDirectories: true

settings:
  SWIFT_VERSION: "5.9"
  IPHONEOS_DEPLOYMENT_TARGET: "$DEPLOYMENT_TARGET"
  DEBUG_INFORMATION_FORMAT: dwarf-with-dsym

packages:
  AmharicCore:
    path: Shared

targets:
  AmharicKeyboard:
    type: application
    platform: iOS
    sources:
      - path: ContainerApp
    dependencies:
      - package: AmharicCore
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: $BUNDLE_PREFIX.$PROJECT_NAME
      PRODUCT_NAME: Amharic Keyboard
      DEVELOPMENT_TEAM: ""
      CODE_SIGN_ENTITLEMENTS: ContainerApp/AmharicKeyboardApp.entitlements
    info:
      path: ContainerApp/Info.plist
      properties: {}

  KeyboardExtension:
    type: app-extension
    platform: iOS
    sources:
      - path: KeyboardExtension
    dependencies:
      - package: AmharicCore
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: $BUNDLE_PREFIX.$PROJECT_NAME.KeyboardExtension
      PRODUCT_NAME: AmharicKeyboardExtension
      DEVELOPMENT_TEAM: ""
      CODE_SIGN_ENTITLEMENTS: KeyboardExtension/AmharicKeyboard.entitlements
    info:
      path: KeyboardExtension/Info.plist
      properties: {}
YAML
    xcodegen generate
    echo "✅ Xcode project generated: $PROJECT_NAME.xcodeproj"

else
    echo "⚠️  xcodegen not found."
    echo "   Install it with: brew install xcodegen"
    echo ""
    echo "   OR create the project manually in Xcode:"
    echo ""
    echo "   1. Open Xcode → File → New → Project"
    echo "      → iOS → App → Name: AmharicKeyboard"
    echo "      → Bundle ID: $BUNDLE_PREFIX.$PROJECT_NAME"
    echo "      → Language: Swift, Interface: Storyboard"
    echo ""
    echo "   2. Add Keyboard Extension target:"
    echo "      → File → New → Target → Custom Keyboard Extension"
    echo "      → Name: KeyboardExtension"
    echo "      → Bundle ID: $BUNDLE_PREFIX.$PROJECT_NAME.KeyboardExtension"
    echo ""
    echo "   3. Add Local Package:"
    echo "      → File → Add Package Dependencies → Add Local → select Shared/"
    echo "      → Link AmharicCore to BOTH targets"
    echo ""
    echo "   4. Add App Group to both targets:"
    echo "      → Signing & Capabilities → + Capability → App Groups"
    echo "      → Group: $APP_GROUP"
    echo ""
    echo "   5. Replace auto-generated KeyboardViewController.swift with"
    echo "      the one in KeyboardExtension/"
    echo ""
    echo "   6. Add source files:"
    echo "      → Drag ContainerApp/ files into AmharicKeyboard target"
    echo "      → Drag KeyboardExtension/ files into KeyboardExtension target"
fi

echo ""
echo "📋 Post-setup checklist:"
echo "  [ ] Set your Apple Developer Team in Signing & Capabilities for both targets"
echo "  [ ] Update BUNDLE_PREFIX in this script to match your Apple Developer account"
echo "  [ ] Build and run the AmharicKeyboard target on your iPhone or Simulator"
echo "  [ ] Go to Settings → General → Keyboard → Keyboards → Add New Keyboard → Amharic"
echo "  [ ] Enable 'Allow Full Access' for translation features"
echo ""
echo "📖 Translation API setup:"
echo "  The keyboard uses LibreTranslate by default."
echo "  To configure a custom endpoint, edit:"
echo "  KeyboardExtension/Views/TranslationMode/TranslationView.swift"
echo "  Change the LibreTranslateClient baseURL to your hosted instance."
echo ""
echo "🎉 Done!"
