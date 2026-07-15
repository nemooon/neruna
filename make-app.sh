#!/bin/zsh
# リリースビルドして Neruna.app を dist/ に組み立てる
# リリース時はこの VERSION を上げてから ./make-release.sh を実行する
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="Neruna"
BUNDLE_ID="com.nemooon.neruna"
VERSION="0.1"
APP="dist/${APP_NAME}.app"

swift build -c release

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp ".build/release/${APP_NAME}" "$APP/Contents/MacOS/${APP_NAME}"
cp "Icon/${APP_NAME}.icns" "$APP/Contents/Resources/${APP_NAME}.icns"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"

echo "Built: $APP (${VERSION})"
echo "インストールする場合: cp -R $APP /Applications/"
