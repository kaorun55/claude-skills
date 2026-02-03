#!/bin/bash
# esa記事検索スクリプト
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
    echo "使用方法: $0 <検索クエリ>" >&2
    echo "例: $0 \"デプロイ 手順\"" >&2
    echo "例: $0 \"wip:false category:開発\"" >&2
    exit 1
fi

QUERY="$1"
PER_PAGE="${2:-20}"

# URLエンコード（安全な文字以外をエンコード）
urlencode() {
    local string="$1"
    python3 -c "import urllib.parse; print(urllib.parse.quote('''$string''', safe=''))"
}

ENCODED_QUERY=$(urlencode "$QUERY")

# API呼び出し（トークンはヘッダーで送信、URLには含めない）
RESPONSE=$(curl -s -f \
    -H "Authorization: Bearer ${ESA_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    "https://api.esa.io/v1/teams/${ESA_TEAM_NAME}/posts?q=${ENCODED_QUERY}&per_page=${PER_PAGE}" \
    2>&1) || {
    echo "エラー: API呼び出しに失敗しました" >&2
    echo "チーム名やトークンを確認してください" >&2
    exit 1
}

# レスポンス解析（jqがない場合はpython3を使用）
if command -v jq &> /dev/null; then
    TOTAL=$(echo "$RESPONSE" | jq -r '.total_count // 0')
    echo "検索結果: ${TOTAL}件"
    echo "---"
    echo "$RESPONSE" | jq -r '.posts[] | "[\(.number)] \(.full_name)\n  URL: https://\(env.ESA_TEAM_NAME).esa.io/posts/\(.number)\n  更新: \(.updated_at)\n  WIP: \(.wip)\n  タグ: \(.tags | join(", "))\n"'
else
    python3 << 'PYTHON_SCRIPT'
import json
import sys
import os

try:
    data = json.loads('''RESPONSE_PLACEHOLDER'''.replace("'''", ""))
except:
    data = json.loads(sys.stdin.read())

team = os.environ.get('ESA_TEAM_NAME', '')
print(f"検索結果: {data.get('total_count', 0)}件")
print("---")
for post in data.get('posts', []):
    tags = ", ".join(post.get('tags', []))
    print(f"[{post['number']}] {post['full_name']}")
    print(f"  URL: https://{team}.esa.io/posts/{post['number']}")
    print(f"  更新: {post['updated_at']}")
    print(f"  WIP: {post['wip']}")
    print(f"  タグ: {tags}")
    print()
PYTHON_SCRIPT
fi
