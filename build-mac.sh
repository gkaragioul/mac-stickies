#!/usr/bin/env bash
# Builds "Mac Stickies.app" and Mac-Stickies-mac.dmg into dist-mac/.
# Needs Xcode (or the Command Line Tools) with Swift 5.9 or newer.
set -euo pipefail

VERSION="1.0.1"
APP_NAME="Mac Stickies"
BUNDLE_ID="com.gkaragioul.mac-stickies"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$ROOT/dist-mac"
APP="$OUT/$APP_NAME.app"

cd "$ROOT"
swift build -c release --arch arm64 --arch x86_64
BIN="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/StickyNotesApp"

rm -rf "$OUT"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/StickyNotesApp"
cp Assets/IconGen/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundleDisplayName</key><string>$APP_NAME</string>
  <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
  <key>CFBundleExecutable</key><string>StickyNotesApp</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$VERSION</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSHumanReadableCopyright</key><string>Copyright © 2026 George Karagioules. MIT License.</string>
</dict>
</plist>
PLIST
codesign --force --deep --sign - "$APP"

mkdir -p "$OUT/dmg"
ditto "$APP" "$OUT/dmg/$APP_NAME.app"
ln -s /Applications "$OUT/dmg/Applications"
cp LICENSE "$OUT/dmg/LICENSE.txt"
hdiutil create -volname "$APP_NAME $VERSION" -srcfolder "$OUT/dmg" -fs APFS -format ULFO -ov "$OUT/Mac-Stickies-mac.dmg" >/dev/null
rm -rf "$OUT/dmg"
echo "Built $OUT/Mac-Stickies-mac.dmg"
