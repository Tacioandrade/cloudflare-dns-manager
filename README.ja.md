[Português](README.md) | [English](README.en.md) | [Français](README.fr.md) | [Español](README.es.md) | [简体中文](README.zh.md) | [日本語](README.ja.md)

# Cloudflare DNS Manager

Cloudflare API を通じて DNS レコードを管理する Flutter アプリケーションです。

この README には全プラットフォーム共通の情報を掲載しています。ビルドコマンド、テスト、各プラットフォーム固有の詳細は [Android](README-Android.md)、[Linux](README-Linux.md)、[Windows](README-Windows.md) のガイドを参照してください。

## 機能

- ローカルパスワード認証と、対応プラットフォームでの生体認証ログイン。
- アプリを閉じて再度開いたときの自動ログアウト。
- 設定可能なドメイン一覧と DNS レコードエディター。
- Cloudflare プロキシ切り替え、CDN キャッシュ削除、API トークン検証。
- ライト、ダーク、システムテーマ。ポルトガル語、英語、フランス語、スペイン語、簡体字中国語、日本語に対応。
- アプリ内のローカライズされたバージョン履歴。

## アクセスとセキュリティ

初回利用時にアプリのパスワードを作成します。新しいセッションごとに認証が必要です。セッションはメモリ内にのみ存在します。パスワードはランダムなソルト付き PBKDF2-HMAC-SHA256 ハッシュとして安全なプラットフォームストレージに保存されます。Cloudflare トークンも安全に保存されます。テーマと DNS 設定は通常のローカル設定に保存されます。

## Cloudflare API トークン

1. アプリにログインします。
2. **設定**を開きます。
3. [Cloudflare API トークン](https://dash.cloudflare.com/profile/api-tokens)を貼り付けます。
4. **テスト**、続いて**保存**を選択します。

### 登録済みドメインの管理専用 API トークン

既存ドメインの一覧表示、有効化の確認、CDN キャッシュの削除を行うには、次を設定します：

- **ゾーン / Zone → ゾーン / Zone → 編集 / Edit**：ゾーンの一覧表示と保留中ゾーンの有効化再確認に使用します。
- **ゾーン / Zone → キャッシュの削除 / Cache Purge → パージ / Purge**：CDN キャッシュの削除に使用します。

この構成では、DNS レコードの作成、変更、削除はできません。

### 新しいドメインの追加と既存ドメインの管理用 API トークン

上記の権限に次を追加してください：

- **ゾーン / Zone → DNS → 編集 / Edit**：DNS レコードの一覧表示、作成、変更、削除に使用します。
- **ゾーンリソース / Zone resources → 含める / Include → すべてのゾーン / All zones**。
- **ユーザー / User → メンバーシップ / Memberships → 読み取り / Read**。ドメインのないアカウントを含む、アクセス可能なすべてのアカウントを一覧表示するために推奨します。

## アーキテクチャ

- Flutter / Dart。機密でないローカル状態には `shared_preferences` を使用します。
- 秘密情報には `flutter_secure_storage`、生体認証には `local_auth`、通信と外部リンクには `http` と `url_launcher` を使用します。

## 既知の問題

Windows には Microsoft Visual C++ Redistributable 2015–2022 が必要です。DLL が見つからない場合は [Microsoft 公式ダウンロードページ](https://learn.microsoft.com/ja-jp/cpp/windows/latest-supported-vc-redist) からインストールしてください。

## ライセンス

MIT
