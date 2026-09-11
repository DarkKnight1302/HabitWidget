#!/bin/bash
set -euo pipefail

APP_NAME="HabitWidget"
BUNDLE_ID="com.robinparashar.habitwidget"
APP_PATH="$HOME/Applications/$APP_NAME.app"
PLIST_PATH="$HOME/Library/LaunchAgents/$BUNDLE_ID.plist"

echo "==> Stopping and removing launch agent..."
launchctl bootout "gui/$(id -u)/$BUNDLE_ID" >/dev/null 2>&1 || true
rm -f "$PLIST_PATH"

echo "==> Removing app..."
rm -rf "$APP_PATH"

echo ""
echo "Uninstalled. Your habit data is kept at:"
echo "  ~/Library/Application Support/HabitWidget/habits.json"
echo "Delete that folder too if you want a clean slate."
