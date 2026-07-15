# Neruna（寝るな）

macOSのメニューバーに常駐する `caffeinate` のラッパーアプリ。
Macのスリープ（ディスプレイ＋システムアイドル）を防止します。

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

## 仕組み

`/usr/bin/caffeinate -di`（時間指定時は `-t <秒>` を追加）をサブプロセスとして
起動・停止するだけの薄いラッパーです。依存ライブラリなし、AppKit のみ。

- `Sources/Neruna/CaffeinateController.swift` — caffeinate プロセスの管理
- `Sources/Neruna/AppDelegate.swift` — NSStatusItem とメニュー
