#!/bin/bash
set -e

APP_NAME="Hidecons"
APP_DIR="$HOME/Applications/$APP_NAME.app"
CONTENTS="$APP_DIR/Contents"
MACOS="$CONTENTS/MacOS"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔨 Compiling $APP_NAME..."
swiftc -O -o "/tmp/$APP_NAME" "$SCRIPT_DIR/Hidecons.swift" -framework Cocoa -framework ServiceManagement

echo "📦 Creating app bundle..."
mkdir -p "$MACOS"

cp "/tmp/$APP_NAME" "$MACOS/$APP_NAME"

cat > "$CONTENTS/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Hidecons</string>
    <key>CFBundleIdentifier</key>
    <string>com.hidecons.app</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>Hidecons</string>
    <key>LSBackgroundOnly</key>
    <true/>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Installed to $APP_DIR"
echo ""
echo "🚀 Launching..."
open "$APP_DIR"
echo ""
echo "You should see an eye icon (👁) in your menu bar."
echo "Click it → Toggle Desktop Icons to hide/show."
echo ""
echo "To launch at login:"
echo "  System Settings → General → Login Items → add $APP_DIR"
