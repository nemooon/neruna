# Neruna（寝るな）

macOSのメニューバーに常駐する `caffeinate` のラッパーアプリ。
Macのスリープ（ディスプレイ＋システムアイドル）を防止します。

## インストール

```sh
brew install --cask nemooon/tap/neruna
xattr -dr com.apple.quarantine /Applications/Neruna.app
```

Apple Developer ID 署名なしのため、macOS が quarantine 属性を付けて起動を
ブロックします。上の `xattr` で属性を外してから起動してください。
または、一度起動を試したあと「システム設定 → プライバシーとセキュリティ」の
セキュリティ欄で「このまま開く」を選びます。

> macOS 15 (Sequoia) 以降、右クリック →「開く」による回避は
> [Apple が削除](https://www.idownloadblog.com/2024/08/07/apple-macos-sequoia-gatekeeper-change-install-unsigned-apps-mac/)しました。
> `brew install --cask --no-quarantine` も Homebrew 6.x で廃止されているため、
> 現状 `xattr` が唯一のコマンドラインでの手段です。

macOS 13 (Ventura) 以降が必要です。

## 使い方

メニューバーのカップアイコン ☕ をクリックしてメニューから選択:

- **無期限にオン** — オフにするまでスリープ防止
- **15分 / 30分 / 1時間 / 2時間** — 指定時間だけスリープ防止（`caffeinate -t` で自動終了）
- **オフにする** — 即座に解除
- **ログイン時に起動** — ログイン項目への登録をトグル（`.app`から起動しているときのみ有効）
- メニュー先頭に現在の状態と残り時間を表示

ログイン項目は「いま起動している .app のパス」で登録されます。
`/Applications` に置いてから有効にするのがおすすめです（`dist/` のまま登録して
後で移動すると、ログイン項目が古いパスを指したままになるため）。

アイコンは有効時に塗りつぶし（`cup.and.saucer.fill`）、無効時はグレーアウトします。
アプリ終了時は caffeinate プロセスも道連れで終了します。

## ビルド

```sh
# 開発中の実行
swift run

# .app バンドルを作る（dist/Neruna.app）
./make-app.sh
cp -R dist/Neruna.app /Applications/
```

## アイコン

- `Icon/Neruna.icon` — Icon Composer 用のデザイン原本（Liquid Glass 対応）。
  `open Icon/Neruna.icon` で編集できます
- `Icon/icon-flat.svg` — `.icns` 生成用の合成版
- `./make-icns.sh` — `Icon/Neruna.icns` を再生成。Icon Composer で調整した場合は
  1024x1024 の PNG に書き出して `./make-icns.sh <書き出したPNG>` で反映

`.icon` を直接アプリに組み込むにはフル Xcode（actool）が必要なため、
CLTのみの環境では `.icns` を `make-app.sh` がバンドルに同梱します。

## リリース

1. `make-app.sh` の `VERSION` を上げてコミット・push
2. `./make-release.sh` — ビルド → zip → GitHub リリースを作成
3. リリース公開をトリガーに `.github/workflows/bump-cask.yml` が動き、
   [nemooon/homebrew-tap](https://github.com/nemooon/homebrew-tap) の
   `Casks/neruna.rb` の version と sha256 を自動更新します

ワークフローには tap へ push できる PAT を `TAP_GITHUB_TOKEN` として
リポジトリシークレットに登録しておく必要があります。

## 仕組み

`/usr/bin/caffeinate -di`（時間指定時は `-t <秒>` を追加）をサブプロセスとして
起動・停止するだけの薄いラッパーです。依存ライブラリなし、AppKit のみ。

- `Sources/Neruna/CaffeinateController.swift` — caffeinate プロセスの管理
- `Sources/Neruna/AppDelegate.swift` — NSStatusItem とメニュー
