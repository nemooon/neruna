#!/bin/zsh
# make-app.sh の VERSION でビルドし、zip を GitHub リリースとして公開する。
# リリースが published になると bump-cask.yml が tap の Casks/neruna.rb を更新する。
#
# 手順:
#   1. make-app.sh の VERSION を上げる
#   2. コミットして push
#   3. ./make-release.sh
set -euo pipefail
cd "$(dirname "$0")"

VERSION=$(grep -E '^VERSION=' make-app.sh | cut -d'"' -f2)
ZIP="dist/Neruna-${VERSION}.zip"

if gh release view "v${VERSION}" >/dev/null 2>&1; then
    echo "エラー: リリース v${VERSION} は既に存在します。make-app.sh の VERSION を上げてください。" >&2
    exit 1
fi

./make-app.sh

rm -f "$ZIP"
# .app のメタデータを保つため ditto を使う（zip -r だと壊れることがある）
ditto -c -k --keepParent dist/Neruna.app "$ZIP"

gh release create "v${VERSION}" "$ZIP" \
    --title "Neruna ${VERSION}" \
    --notes "\`brew install --cask nemooon/tap/neruna\` でインストールできます。"

echo "リリースしました: v${VERSION}"
