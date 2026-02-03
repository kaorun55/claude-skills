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

### 2. 設定ファイルを作成

スキルディレクトリ内で:

```bash
cd .claude/skills/esa  # または ~/.claude/skills/esa
cp config.json.example config.json
```

編集して実際の値を入力:

```json
{
  "team_name": "your-team-name",
  "access_token": "your-access-token"
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
- トークンはスキルディレクトリ内の `config.json` で管理
- `config.json` は `.gitignore` に含まれています

## ライセンス

MIT
