#!/bin/bash
# bundle.sh の VERSION でビルドし、zip を GitHub リリースとして公開する。
# リリースが published になると bump-cask.yml が tap の Casks/neruna.rb を更新する。
#
# 手順:
#   1. scripts/bundle.sh の VERSION を上げる
#   2. コミットして push
#   3. scripts/release.sh
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION=$(grep -E '^VERSION=' scripts/bundle.sh | cut -d'"' -f2)
ZIP="dist/Neruna-${VERSION}.zip"

if gh release view "v${VERSION}" >/dev/null 2>&1; then
    echo "エラー: リリース v${VERSION} は既に存在します。scripts/bundle.sh の VERSION を上げてください。" >&2
    exit 1
fi

scripts/bundle.sh

rm -f "$ZIP"
# .app の拡張属性を保ったまま固める(展開側も ditto -x -k を使うと署名が保たれる)
ditto -c -k --keepParent dist/Neruna.app "$ZIP"

gh release create "v${VERSION}" "$ZIP" \
    --title "Neruna ${VERSION}" \
    --notes "\`brew install --cask nemooon/tap/neruna\` でインストールできます。"

echo "リリースしました: v${VERSION}"
