# claude-skill-esa

Claude Codeでesaの記事を検索・取得するスキルです。

## インストール

### 方法1: プロジェクトにコピー

```bash
# スキルディレクトリをコピー
cp -r .claude/skills/esa /path/to/your-project/.claude/skills/
```

### 方法2: 個人スキルとしてインストール（全プロジェクトで使用可能）

```bash
# 個人スキルディレクトリにコピー
cp -r .claude/skills/esa ~/.claude/skills/
```

## 設定

### 1. esaアクセストークンを取得

1. [esa](https://esa.io) にログイン
2. Settings → Applications → Personal access tokens
3. 「Generate new token」で **Read** スコープのみのトークンを作成

### 2. 環境変数を設定

`.claude/settings.json` を作成:

```bash
cp .claude/settings.json.example .claude/settings.json
```

編集して実際の値を入力:

```json
{
  "env": {
    "ESA_TEAM_NAME": "your-team-name",
    "ESA_ACCESS_TOKEN": "your-access-token"
  }
}
```

### 3. Claude Codeを再起動

## 使い方

```
/esa デプロイ手順        # キーワードで検索
/esa 123                 # 記事番号で取得
/esa wip:false 開発      # フィルタ付き検索
```

詳細は [.claude/skills/esa/README.md](.claude/skills/esa/README.md) を参照。

## セキュリティ

- 読み取り専用（記事の変更不可）
- トークンは環境変数で管理（コードにハードコードしない）
- `.claude/settings.json` は `.gitignore` に含まれています

## ライセンス

MIT
