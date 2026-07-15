#!/bin/zsh
# リリースビルドして Neruna.app を dist/ に組み立てる
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release

APP=dist/Neruna.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp .build/release/Neruna "$APP/Contents/MacOS/Neruna"
cp Icon/Neruna.icns "$APP/Contents/Resources/Neruna.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Neruna</string>
    <key>CFBundleIdentifier</key>
    <string>com.nemoto.neruna</string>
    <key>CFBundleName</key>
    <string>Neruna</string>
    <key>CFBundleIconFile</key>
    <string>Neruna</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"

echo "Built: $APP"
echo "インストールする場合: cp -R $APP /Applications/"
