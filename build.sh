#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="HabitWidget"
BUNDLE_ID="com.robinparashar.habitwidget"
ARCH="$(uname -m)"
TARGET="${ARCH}-apple-macos14.0"

APP_DIR="$PWD/dist/$APP_NAME.app"
BINARY="$APP_DIR/Contents/MacOS/$APP_NAME"

echo "==> Compiling $APP_NAME for $TARGET..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

swiftc \
    -O \
    -target "$TARGET" \
    -o "$BINARY" \
    Sources/HabitWidget/*.swift

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>Habit Widget</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "==> Signing (ad-hoc)..."
codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || echo "  (ad-hoc signing skipped)"

echo "==> Built: $APP_DIR"
