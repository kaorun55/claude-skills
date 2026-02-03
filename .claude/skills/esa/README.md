# esa スキル for Claude Code

esaの記事を検索・取得するClaude Codeスキルです。

## 機能

- 記事の検索（キーワード、カテゴリ、タグなど）
- 記事の取得（記事番号指定）

※ 読み取り専用です。記事の作成・更新・削除は行いません。

## セットアップ

### 1. esaアクセストークンの取得

1. [esa](https://esa.io) にログイン
2. 右上のアイコン → Settings → Applications → Personal access tokens
3. 「Generate new token」をクリック
4. **Read** スコープのみを選択（セキュリティのため）
5. トークンをコピー

### 2. 環境変数の設定

プロジェクトの `.claude/settings.json` に設定:

```json
{
  "env": {
    "ESA_TEAM_NAME": "your-team-name",
    "ESA_ACCESS_TOKEN": "your-access-token"
  }
}
```

> **重要**: `.claude/settings.json` を `.gitignore` に追加してください。

### 3. Claude Codeを再起動

設定を反映するため、Claude Codeを再起動してください。

## 使い方

### スラッシュコマンド

```
/esa デプロイ手順
/esa 123
```

### 自然言語

```
esaでデプロイ手順を検索して
esaの記事123を見せて
```

### 検索フィルタ

| フィルタ | 説明 | 例 |
|----------|------|-----|
| `wip:true/false` | WIP状態 | `/esa wip:false` |
| `category:名前` | カテゴリ | `/esa category:開発` |
| `tag:名前` | タグ | `/esa tag:手順書` |
| `user:名前` | 作成者 | `/esa user:tanaka` |

フィルタは組み合わせ可能:

```
/esa wip:false category:開発 デプロイ
```

## ファイル構成

```
.claude/skills/esa/
├── SKILL.md        # スキル定義
├── README.md       # このファイル
├── SECURITY.md     # セキュリティ考慮事項
└── scripts/
    ├── search.sh   # 検索スクリプト
    └── get.sh      # 取得スクリプト
```

## セキュリティ

- アクセストークンは環境変数で管理
- Bearer認証でAPIにアクセス（URLにトークンを含めない）
- 読み取り専用APIのみ使用
- 入力値のバリデーション実装

詳細は [SECURITY.md](./SECURITY.md) を参照。

## 制限事項

- esa APIレートリミット: 75リクエスト/15分
- 1回の検索で最大20件を取得

## ライセンス

MIT
