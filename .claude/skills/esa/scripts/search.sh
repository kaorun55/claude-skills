#!/bin/bash
# esa記事検索スクリプト
# セキュリティ: トークンはログ出力しない、読み取り専用API使用

set -euo pipefail

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config.json"

# 設定ファイルから読み込み（環境変数が未設定の場合）
if [[ -z "${ESA_ACCESS_TOKEN:-}" ]] || [[ -z "${ESA_TEAM_NAME:-}" ]]; then
    if [[ -f "$CONFIG_FILE" ]]; then
        ESA_TEAM_NAME="${ESA_TEAM_NAME:-$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['team_name'])" 2>/dev/null)}"
        ESA_ACCESS_TOKEN="${ESA_ACCESS_TOKEN:-$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['access_token'])" 2>/dev/null)}"
    fi
fi

# 設定チェック
if [[ -z "${ESA_ACCESS_TOKEN:-}" ]] || [[ "$ESA_ACCESS_TOKEN" == "your-access-token" ]]; then
    echo "エラー: アクセストークンが設定されていません" >&2
    echo "設定方法: ${CONFIG_FILE} を編集してください" >&2
    exit 1
fi

if [[ -z "${ESA_TEAM_NAME:-}" ]] || [[ "$ESA_TEAM_NAME" == "your-team-name" ]]; then
    echo "エラー: チーム名が設定されていません" >&2
    echo "設定方法: ${CONFIG_FILE} を編集してください" >&2
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

# レスポンス解析
if command -v jq &> /dev/null; then
    TOTAL=$(echo "$RESPONSE" | jq -r '.total_count // 0')
    echo "検索結果: ${TOTAL}件"
    echo "---"
    echo "$RESPONSE" | ESA_TEAM_NAME="$ESA_TEAM_NAME" jq -r '.posts[] | "[\(.number)] \(.full_name)\n  URL: https://\(env.ESA_TEAM_NAME).esa.io/posts/\(.number)\n  更新: \(.updated_at)\n  WIP: \(.wip)\n  タグ: \(.tags | join(", "))\n"'
else
    echo "$RESPONSE" | python3 -c "
import json
import sys

data = json.load(sys.stdin)
team = '$ESA_TEAM_NAME'
print(f\"検索結果: {data.get('total_count', 0)}件\")
print('---')
for post in data.get('posts', []):
    tags = ', '.join(post.get('tags', []))
    print(f\"[{post['number']}] {post['full_name']}\")
    print(f\"  URL: https://{team}.esa.io/posts/{post['number']}\")
    print(f\"  更新: {post['updated_at']}\")
    print(f\"  WIP: {post['wip']}\")
    print(f\"  タグ: {tags}\")
    print()
"
fi
