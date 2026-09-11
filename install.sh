#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="HabitWidget"
BUNDLE_ID="com.robinparashar.habitwidget"
INSTALL_DIR="$HOME/Applications"
APP_PATH="$INSTALL_DIR/$APP_NAME.app"
PLIST_PATH="$HOME/Library/LaunchAgents/$BUNDLE_ID.plist"

./build.sh

echo "==> Installing to $APP_PATH ..."
mkdir -p "$INSTALL_DIR"
rm -rf "$APP_PATH"
cp -R "$PWD/dist/$APP_NAME.app" "$APP_PATH"

echo "==> Installing launch agent (auto-start at login)..."
mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$BUNDLE_ID</string>
    <key>ProgramArguments</key>
    <array>
        <string>$APP_PATH/Contents/MacOS/$APP_NAME</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>LimitLoadToSessionType</key>
    <string>Aqua</string>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
PLIST

launchctl bootout "gui/$(id -u)/$BUNDLE_ID" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"
launchctl kickstart -k "gui/$(id -u)/$BUNDLE_ID" >/dev/null 2>&1 || true

echo ""
echo "Installed. The widget is running now and will start automatically at login."
echo "Look for the checkmark icon in your menu bar to switch habits or quit."
