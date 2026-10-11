# HanahiraVRC

🌐 **日本語** | [English](README.en.md)

VRChat のよくある不具合をワンクリックで直す、Windows 用の **オールインワン修復ツールキット**です。
`HanahiraVRC.bat` をダブルクリックして、メニューから修復を選ぶだけ。ファイルは 1 つだけです。

![メニュー画面](docs/screenshot-menu.png)

> ⚠️ これは非公式のファンツールです。VRChat Inc. とは一切関係ありません。
> 画面の表示は海外のユーザーも使えるよう、英語になっています。

## 主な機能

| キー | ツール | できること |
|---|---|---|
| 1 | KILL | 固まった VRChat / Easy Anti-Cheat のプロセスを終了 |
| 2 | CACHE | アバター・ワールドのキャッシュを削除（HTTP / テクスチャキャッシュ、`config.json` の `cache_directory` にも対応） |
| 3 | EAC | Easy Anti-Cheat を修復（すべての Steam ライブラリからゲームを自動検出） |
| 4 | VERIFY | Steam でゲームファイルの整合性を確認 |
| 5 | OSC | OSC 設定をリセット |
| F | DISCORD | DiscordHook を無効化（VRChat を閉じる／閉じないを選択可）。元に戻す機能と、Discord の自動再起動つき |
| I | IME | VRChat で日本語入力（IME）ができない問題を診断・修正 |
| 6 | NET | DNS キャッシュのクリア + Winsock リセット *（管理者権限）* |
| 7 | DIAG | VRChat API の状態、キャッシュサイズ、ログ数を確認 |
| 8 | AUDIO | Windows オーディオサービスを再起動（マイク・音が出ないとき）*（管理者権限）* |
| 9 | LOGS | 古い VRChat のログを削除 |
| A / B | BACKUP / RESET | VRChat の設定（レジストリ）をバックアップ／リセット（リセット前に必ず自動バックアップ） |
| C | FOLDERS | データ・キャッシュ・バックアップ・ログのフォルダを開く |
| J | JUNK | 一時ファイル、クラッシュダンプ、シェーダーキャッシュを掃除（削除前にサイズを表示して確認） |
| D / E / S | LAUNCH / AUTOFIX / STEAM | VRChat を起動（VR／デスクトップ）、ワンクリック掃除、Steam を再起動 |

## スクリーンショット

![DIAG 画面](docs/screenshot-diag.png)

## 使い方

1. [`HanahiraVRC.bat`](HanahiraVRC.bat) をダウンロードします。
2. ダブルクリックで起動します。
3. 管理者権限が必要な項目（`◆` マーク）を使うときは、メニューで **R** を押すと管理者として再起動できます。

- 色や罫線をきれいに表示するため、**Windows ターミナル**（Windows 11 の標準）での利用をおすすめします。
- ログは `Logs\HanahiraVRC.log`、レジストリのバックアップは `Backups\` に、スクリプトと同じ場所へ保存されます。

## 安全性について

- 削除や変更をする操作は、実行前に確認します。ドキュメントなどの個人ファイルには触れません。
- 設定のリセットは、必ずバックアップを作成してから実行します。
- `JUNK` は、一時ファイルとキャッシュだけを対象にします。ごみ箱を空にする操作は別途確認します。

## 技術メモ

- `.bat` は小さなランチャーで、本体は同じファイルに埋め込まれた PowerShell です。
- `cmd.exe` は LF のみの改行を正しく読めないため、このファイルは **CRLF** で保存してください（`.gitattributes` で保持しています）。

## ライセンス

[MIT](LICENSE)
