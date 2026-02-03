---
name: esa
description: esaから記事を検索・取得する。「esaで〇〇を検索」「esaの記事を見せて」などのリクエストに対応。
argument-hint: "[検索クエリ または 記事番号]"
allowed-tools: Bash(bash .claude/skills/esa/scripts/*.sh *)
---

# esa スキル

esaチームの記事を検索・取得するスキルです。読み取り専用で、記事の作成・更新・削除は行いません。

## 前提条件

以下の環境変数が設定されている必要があります:

- `ESA_ACCESS_TOKEN`: esaのアクセストークン（必須）
- `ESA_TEAM_NAME`: esaのチーム名（必須）

## 使用可能なコマンド

### 記事の検索

```bash
bash .claude/skills/esa/scripts/search.sh "検索クエリ"
```

検索クエリには以下のフィルタが使用可能:
- `wip:true` / `wip:false`: WIP状態でフィルタ
- `kind:stock` / `kind:flow`: 記事の種類でフィルタ
- `category:カテゴリ名`: カテゴリでフィルタ
- `user:ユーザー名`: 作成者でフィルタ
- `tag:タグ名`: タグでフィルタ

### 記事の取得

```bash
bash .claude/skills/esa/scripts/get.sh 記事番号
```

記事番号を指定して、記事の詳細（タイトル、本文、カテゴリ、タグなど）を取得します。

## セキュリティに関する注意

- アクセストークンは環境変数から読み込み、ログや出力には含めません
- 読み取り専用APIのみを使用し、記事の変更は行いません
- APIレスポンスに含まれる機密情報（メールアドレスなど）は表示しません

## 使用例

ユーザー: 「esaでデプロイ手順を検索して」
→ `bash .claude/skills/esa/scripts/search.sh "デプロイ 手順"`

ユーザー: 「esaの記事123を見せて」
→ `bash .claude/skills/esa/scripts/get.sh 123`

ユーザー: 「esaでWIPではない記事を検索」
→ `bash .claude/skills/esa/scripts/search.sh "wip:false"`
