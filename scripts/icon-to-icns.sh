#!/bin/bash
# アイコン原稿を Resources/Neruna.icns に変換する
# 引数なし: Resources/icon-flat.svg をレンダリングして使う
# 引数あり: Icon Composer からエクスポートした 1024x1024 PNG を使う
#   例: scripts/icon-to-icns.sh ~/Desktop/Neruna-export.png
set -euo pipefail

cd "$(dirname "$0")/.."

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

if [[ $# -ge 1 ]]; then
    MASTER=$1
else
    qlmanage -t -s 1024 -o "$TMP" Resources/icon-flat.svg >/dev/null
    MASTER="$TMP/icon-flat.svg.png"
fi

ICONSET="$TMP/Neruna.iconset"
mkdir -p "$ICONSET"

for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$MASTER" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    double=$((size * 2))
    sips -z "$double" "$double" "$MASTER" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$ICONSET" -o Resources/Neruna.icns
echo "更新しました: Resources/Neruna.icns"
