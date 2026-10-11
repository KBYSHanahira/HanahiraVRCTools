<div align="center">

# 🌸 HanahiraVRC

**VRChat の「困った」をワンクリックで直す、Windows 用の修復ツールキット**

🌐 **日本語** ｜ [English](README.en.md)

![License](https://img.shields.io/badge/license-MIT-ff7a18?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-1c1c1e?style=flat-square&labelColor=ff7a18)
![Single file](https://img.shields.io/badge/file-1%20.bat-ff7a18?style=flat-square)

![メニュー画面](docs/screenshot-menu.png)

[**⬇ ダウンロード**](https://github.com/KBYSHanahira/HanahiraVRCTools/archive/refs/heads/main.zip) ・ [使い方](#-クイックスタート) ・ [症状から選ぶ](#-症状から選ぶ) ・ [困ったとき](#-困ったとき-faq)

</div>

> ⚠️ 非公式のファンツールです。VRChat Inc. とは一切関係ありません。
> 画面の表示は、海外のユーザーも使えるよう英語です。

---

## 📑 目次

1. [できること](#-できること)
2. [クイックスタート](#-クイックスタート) ← **まずはここ**
3. [画面の見かた](#-画面の見かた)
4. [症状から選ぶ](#-症状から選ぶ)
5. [各ツールの詳細](#-各ツールの詳細)
6. [困ったとき (FAQ)](#-困ったとき-faq)
7. [安全性とプライバシー](#-安全性とプライバシー)
8. [アンインストール](#-アンインストール)
9. [開発者向けメモ](#-開発者向けメモ)

---

## ✨ できること

- 🎮 **ゲームの不具合** — 固まったプロセスの終了、キャッシュ削除、Easy Anti-Cheat 修復、ファイル整合性チェック、OSC リセット
- 💬 **Discord / IME** — DiscordHook によるクラッシュ対策、日本語入力ができない問題の診断
- 🌐 **ネットワークと音** — VRChat サーバーの状態確認、DNS / Winsock のリセット、オーディオ再起動
- 🧹 **PC のお掃除** — 一時ファイル・クラッシュダンプ・シェーダーキャッシュを、サイズを確認してから削除
- 🛡️ **安全設計** — 削除や変更の前に確認。設定のリセットは必ず自動バックアップ付き
- 📦 **ファイルは 1 つだけ** — インストール不要。`HanahiraVRC.bat` をダブルクリックするだけ

---

## 🚀 クイックスタート

ダウンロードから起動まで、約 1 分です。

### ステップ 1 ｜ ダウンロード

**[➡ ここをクリックして ZIP をダウンロード](https://github.com/KBYSHanahira/HanahiraVRCTools/archive/refs/heads/main.zip)**

または、このページ右上の緑の **`Code`** ボタン → **`Download ZIP`** を選びます。

### ステップ 2 ｜ 展開（解凍）

ダウンロードした `HanahiraVRCTools-main.zip` を **右クリック → 「すべて展開」**。

> ⚠️ ZIP の中から直接ダブルクリックしないでください。ログやバックアップを保存できず、正しく動きません。
> デスクトップなど、書き込める場所に展開するのがおすすめです。

### ステップ 3 ｜ 起動

展開したフォルダの **`HanahiraVRC.bat`** をダブルクリックします。

初回は、次のような青い画面が出ることがあります。

> **「Windows によって PC が保護されました」**

これは、署名のない個人製ツールに対して Windows が出す標準の警告です。

1. **「詳細情報」** をクリック
2. **「実行」** をクリック

> 中身は 1 つのテキストファイルなので、実行前にメモ帳で開いて内容を確認することもできます。

### ステップ 4 ｜ 使う

メニューの左側のキー（`1` `2` `F` など）を **押すだけ** です。Enter は不要です。

1. 直したい項目のキーを押す
2. 画面の案内に従う（`Y` / `N` で確認することがあります）
3. 終わったら、何かキーを押してメニューに戻る
4. 終了は **`X`**

### ステップ 5 ｜ 管理者権限が必要なとき

`*` マークの付いた項目（**NET**・**AUDIO**）は管理者権限が必要です。

- メニューで **`R`** を押すと、管理者として再起動できます
- または、`HanahiraVRC.bat` を **右クリック → 「管理者として実行」**

> 💡 **迷ったら** まず **`7` (DIAG)** で状態を確認 → それでも直らなければ **`E` (AUTOFIX)** を試してみてください。

---

## 💻 画面の見かた

![DIAG 画面](docs/screenshot-diag.png)

| 表示 | 意味 |
|---|---|
| 🟧 オレンジの四角 `1` `F` など | 押すキー |
| 上部の枠 | VRChat が起動中か、管理者権限か、C ドライブの空き容量 |
| `*` | 管理者権限が必要な項目 |
| `✔` / `▲` / `✖` | 成功 / 注意 / 失敗 |
| `[Y/N]` | `Y` で実行、`N` でキャンセル |

> 色や罫線がきれいに表示されない場合は、**Windows ターミナル**（Windows 11 の標準）で開いてください。

---

## 🩺 症状から選ぶ

| こんな症状 | おすすめの項目 |
|---|---|
| ゲームが起動しない / 起動直後に落ちる | **`3` EAC** → **`4` VERIFY** → **`F` DISCORD** |
| 起動画面で固まる、ずっと読み込み中 | **`1` KILL** → **`2` CACHE** |
| アバターが表示されない / 灰色のまま / ロードが終わらない | **`2` CACHE** |
| ログインできない / API エラー / 通信が不安定 | **`7` DIAG** で確認 → **`6` NET** |
| マイクが使えない / 音が出ない | **`8` AUDIO** |
| 日本語入力ができない | **`I` IME** |
| Discord を開いていると VRChat が落ちる・固まる | **`F` DISCORD** |
| OSC アプリが反応しない | **`5` OSC** |
| 設定がおかしい（画質・音量が戻らない） | **`A` BACKUP** → **`B` RESET** |
| PC 全体が重い / 空き容量が少ない | **`J` JUNK** |
| とにかくまとめて直したい | **`E` AUTOFIX** |

---

## 🔧 各ツールの詳細

<details>
<summary><b>🎮 ゲームの不具合</b></summary>

| キー | 名前 | 内容 | メモ |
|---|---|---|---|
| `1` | **KILL** | 固まった VRChat / Easy Anti-Cheat のプロセスを終了 | 保存していない作業は失われます |
| `2` | **CACHE** | アバター・ワールドのキャッシュを削除（HTTP / テクスチャキャッシュ、`config.json` の `cache_directory` にも対応） | 次回の読み込みは少し遅くなります |
| `3` | **EAC** | Easy Anti-Cheat を修復。全 Steam ライブラリからゲームを自動検出して、EAC のセットアップを起動 | 画面で **VRChat を選び「Repair Service」** を押してください |
| `4` | **VERIFY** | Steam にゲームファイルの整合性チェックを依頼 | 進行状況は Steam の画面に出ます |
| `5` | **OSC** | アバターごとの OSC 設定をリセット | ゲームが次回起動時に作り直します |

</details>

<details>
<summary><b>💬 Discord / 日本語入力</b></summary>

| キー | 名前 | 内容 | メモ |
|---|---|---|---|
| `F` | **DISCORD** | DiscordHook を無効化します。`1` VRChat を閉じずに実行 / `2` VRChat も閉じて実行（**おすすめ**）/ `3` 元に戻す | 終わったら Discord は自動で再起動します。Discord の更新で hook が戻ることがあるので、その時は再実行してください |
| `I` | **IME** | `1` 状態チェック / `2` テキスト入力サービスの再起動 / `3` 日本語 IME を有効にして VRChat を起動し直す / `4` Windows の言語設定を開く | VRChat は **起動時** の IME を使うため、ゲーム中の切り替えは効きません |

</details>

<details>
<summary><b>🌐 ネットワークと音</b></summary>

| キー | 名前 | 内容 | メモ |
|---|---|---|---|
| `6` | **NET** | DNS キャッシュのクリア + Winsock リセット | 🔐 管理者権限。完全に反映するには PC の再起動が必要 |
| `7` | **DIAG** | VRChat API の状態と応答時間、キャッシュサイズ、ログ数、インターネット接続を確認 | 何も変更しません。安全です |
| `8` | **AUDIO** | Windows のオーディオサービスを再起動 | 🔐 管理者権限 |

</details>

<details>
<summary><b>🗂️ データと設定</b></summary>

| キー | 名前 | 内容 | メモ |
|---|---|---|---|
| `9` | **LOGS** | 古い VRChat のログを削除 | 起動中のログはスキップされます |
| `A` | **BACKUP** | VRChat の設定（レジストリ）を `Backups\` に保存 | |
| `B` | **RESET** | VRChat の設定をリセット | 必ず自動バックアップしてから実行。アカウントやアバターは消えません |
| `C` | **FOLDERS** | データ / キャッシュ / バックアップ / ログのフォルダを開く | |

</details>

<details>
<summary><b>🧹 PC のお掃除</b></summary>

| キー | 名前 | 内容 | メモ |
|---|---|---|---|
| `J` | **JUNK** | 一時ファイル、クラッシュダンプ、エラーレポート、シェーダーキャッシュ（DirectX / NVIDIA）、サムネイルキャッシュを削除 | **先に一覧とサイズを表示し、確認してから** 削除。24 時間以内の一時ファイルは除外。ごみ箱を空にするかは別に確認します。Windows の一時フォルダも掃除するには管理者権限が必要 |

</details>

<details>
<summary><b>⚡ ショートカット</b></summary>

| キー | 名前 | 内容 |
|---|---|---|
| `D` | **LAUNCH** | VRChat を起動（VR / デスクトップモード） |
| `E` | **AUTOFIX** | プロセス終了 + キャッシュ削除 + ログ削除 + DNS クリアを一括実行。最後に VRChat を起動するか聞きます |
| `S` | **STEAM** | Steam を再起動 |
| `R` | **ADMIN** | 管理者として起動し直す（管理者で起動中は表示されません） |
| `X` | **EXIT** | 終了 |

</details>

---

## ❓ 困ったとき (FAQ)

<details>
<summary><b>起動してもすぐに閉じてしまう</b></summary>

ZIP の中から直接開いていませんか？ **先に「すべて展開」** してから、展開したフォルダの `HanahiraVRC.bat` を開いてください。

</details>

<details>
<summary><b>色が出ない / 罫線やロゴが崩れる</b></summary>

古いコンソールで開かれている可能性があります。**Windows ターミナル** を使ってください（Windows 11 の標準）。Windows 10 の場合は、Microsoft Store の「Windows Terminal」をインストールしてから、ターミナルの中で `HanahiraVRC.bat` を実行します。

</details>

<details>
<summary><b>「Windows によって PC が保護されました」と出る</b></summary>

署名のない個人製ツールに出る標準の警告です。**「詳細情報」→「実行」** で起動できます。

</details>

<details>
<summary><b>ウイルス対策ソフトに警告された</b></summary>

プロセスの終了やファイル削除、システム設定の変更を行うため、まれに誤検知されることがあります。不安なときは `HanahiraVRC.bat` をメモ帳で開いて、内容を確認してください。ソースはすべてこの 1 ファイルです。

</details>

<details>
<summary><b>「Run as Administrator」と言われる / NET・AUDIO が動かない</b></summary>

メニューで **`R`** を押して管理者として再起動するか、ファイルを右クリックして **「管理者として実行」** を選んでください。

</details>

<details>
<summary><b>「VRChat install folder not found」と出る（EAC）</b></summary>

Steam 版の VRChat のみ自動検出に対応しています。Steam 以外でインストールしている場合は、VRChat のフォルダにある `EasyAntiCheat` 内の `EasyAntiCheat*Setup.exe` を手動で起動して、**Repair Service** を選んでください。

</details>

<details>
<summary><b>CACHE を実行したのに「No cache found」と出る</b></summary>

すでに削除済み、またはキャッシュが空です。`7` (DIAG) で現在のサイズを確認できます。

</details>

<details>
<summary><b>日本語入力が直らない</b></summary>

1. **`I` → `3`** で日本語 IME を有効にして VRChat を起動し直す
2. ゲームの画面が開く前に、`Win + Space` で入力欄に「あ」が出る状態にしておく
3. それでも直らない場合は **`I` → `4`** で Windows の言語設定を開き、Microsoft IME の互換性設定（「以前のバージョンの Microsoft IME を使う」）を試す
4. ATOK など別の IME を使っている場合は、Microsoft IME に切り替えて確認する

</details>

---

## 🔒 安全性とプライバシー

- **個人ファイルには触れません。** 対象は VRChat のデータ、一時ファイル、キャッシュ、クラッシュダンプだけです
- 削除や設定変更の前には **確認** します。レジストリのリセットは **必ずバックアップ付き** です
- データを収集・送信しません。通信するのは **`7` DIAG** のときだけで、`api.vrchat.cloud` への接続確認と、`1.1.1.1` への ping です
- 実行内容は `Logs\HanahiraVRC.log` に記録されます
- 変更を加える場合があるもの（すべて確認つき）
  - **F DISCORD**: Discord の `DiscordHook*.dll` を `.disabled` に名前変更（元に戻せます）
  - **I IME**: 必要な場合のみ、既定の入力方式を日本語 IME に設定
  - **6 NET**: Winsock をリセット（再起動が必要）

---

## 🚮 アンインストール

インストールは不要なので、**展開したフォルダを削除するだけ** です。

元に戻したい設定がある場合:

| 変更したもの | 元に戻す方法 |
|---|---|
| DiscordHook を無効化した | **`F` → `3`** で復元 |
| VRChat の設定をリセットした | `Backups\` の `.reg` ファイルをダブルクリックで復元 |
| 既定の入力方式を日本語 IME にした | Windows の設定 → 時刻と言語 → 言語と地域 で変更 |

---

## 🧰 開発者向けメモ

- `.bat` は小さなランチャーで、本体は同じファイルの `#<PS>` 以降に埋め込まれた **PowerShell** です
- `cmd.exe` は LF のみの改行を正しく読めないため、**CRLF で保存** してください（`.gitattributes` の `*.bat -text` で保持しています）
- PowerShell の変数は大文字・小文字を区別しません（`$r` と `$R` は同じ変数）
- 非対話テスト用に、環境変数 `HVRC_KEYS`（押すキーの列）と `HVRC_COLS`（画面幅）が使えます

```powershell
$env:HVRC_KEYS = "7X"      # DIAG を実行して終了
.\HanahiraVRC.bat
```

---

<div align="center">

**[MIT License](LICENSE)** ・ Made with 🧡 for VRChat

</div>
