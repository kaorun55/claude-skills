#!/bin/bash
# esa記事取得スクリプト
# セキュリティ: トークンはログ出力しない、読み取り専用API使用

set -euo pipefail

# 環境変数チェック
if [[ -z "${ESA_ACCESS_TOKEN:-}" ]]; then
    echo "エラー: ESA_ACCESS_TOKEN が設定されていません" >&2
    echo "設定方法: export ESA_ACCESS_TOKEN='your-token'" >&2
    exit 1
fi

if [[ -z "${ESA_TEAM_NAME:-}" ]]; then
    echo "エラー: ESA_TEAM_NAME が設定されていません" >&2
    echo "設定方法: export ESA_TEAM_NAME='your-team'" >&2
    exit 1
fi

# 引数チェック
if [[ $# -lt 1 ]]; then
    echo "使用方法: $0 <記事番号>" >&2
    echo "例: $0 123" >&2
    exit 1
fi

POST_NUMBER="$1"

# 記事番号が数値かチェック（インジェクション防止）
if ! [[ "$POST_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "エラー: 記事番号は数値で指定してください" >&2
    exit 1
fi

# API呼び出し（トークンはヘッダーで送信、URLには含めない）
RESPONSE=$(curl -s -f \
    -H "Authorization: Bearer ${ESA_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    "https://api.esa.io/v1/teams/${ESA_TEAM_NAME}/posts/${POST_NUMBER}" \
    2>&1) || {
    echo "エラー: API呼び出しに失敗しました" >&2
    echo "記事番号が正しいか確認してください: ${POST_NUMBER}" >&2
    exit 1
}

# レスポンス解析（jqがない場合はpython3を使用）
if command -v jq &> /dev/null; then
    echo "# $(echo "$RESPONSE" | jq -r '.full_name')"
    echo ""
    echo "- 記事番号: $(echo "$RESPONSE" | jq -r '.number')"
    echo "- URL: https://${ESA_TEAM_NAME}.esa.io/posts/$(echo "$RESPONSE" | jq -r '.number')"
    echo "- カテゴリ: $(echo "$RESPONSE" | jq -r '.category // "なし"')"
    echo "- タグ: $(echo "$RESPONSE" | jq -r '.tags | join(", ")')"
    echo "- WIP: $(echo "$RESPONSE" | jq -r '.wip')"
    echo "- 作成日: $(echo "$RESPONSE" | jq -r '.created_at')"
    echo "- 更新日: $(echo "$RESPONSE" | jq -r '.updated_at')"
    echo ""
    echo "---"
    echo ""
    echo "$RESPONSE" | jq -r '.body_md'
else
    python3 << PYTHON_SCRIPT
import json
import os

response = '''$(echo "$RESPONSE" | sed "s/'''/\\\\'''/g")'''
data = json.loads(response)

team = os.environ.get('ESA_TEAM_NAME', '')
print(f"# {data.get('full_name', 'タイトルなし')}")
print()
print(f"- 記事番号: {data.get('number')}")
print(f"- URL: https://{team}.esa.io/posts/{data.get('number')}")
print(f"- カテゴリ: {data.get('category') or 'なし'}")
print(f"- タグ: {', '.join(data.get('tags', []))}")
print(f"- WIP: {data.get('wip')}")
print(f"- 作成日: {data.get('created_at')}")
print(f"- 更新日: {data.get('updated_at')}")
print()
print("---")
print()
print(data.get('body_md', ''))
PYTHON_SCRIPT
fi
