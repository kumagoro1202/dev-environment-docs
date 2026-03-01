#!/bin/bash
# record-env-change.sh - 環境変更を CHANGELOG.md に記録するスクリプト
#
# 使い方:
#   bash ~/dev-environment-docs/scripts/record-env-change.sh <カテゴリ> <コマンド> <説明> [--push]
#
# 引数:
#   カテゴリ   : wsl2 / shell / claude-code / dev-tools / git / tmux / infrastructure / bedrock
#   コマンド   : 実行したコマンド（例: "npm install -g typescript"）
#   説明       : 変更理由・目的（例: "TypeScript グローバルインストール"）
#   --push     : (オプション) 記録後に git commit & push を実行
#
# 例:
#   bash ~/dev-environment-docs/scripts/record-env-change.sh \
#     "dev-tools" "nvm install 22" "Node.js v22 LTS インストール"
#
#   bash ~/dev-environment-docs/scripts/record-env-change.sh \
#     "claude-code" "claude update" "Claude Code 最新化" --push

set -euo pipefail

# ==============================
# 設定
# ==============================
REPO_DIR="${HOME}/dev-environment-docs"
CHANGELOG="${REPO_DIR}/docs/CHANGELOG.md"

# ==============================
# 引数チェック
# ==============================
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <カテゴリ> <コマンド> <説明> [--push]"
  echo ""
  echo "カテゴリ例: wsl2 / shell / claude-code / dev-tools / git / tmux / infrastructure / bedrock"
  echo ""
  echo "例:"
  echo "  $0 \"dev-tools\" \"npm install -g typescript\" \"TypeScript グローバルインストール\""
  echo "  $0 \"claude-code\" \"claude update\" \"Claude Code 最新化\" --push"
  exit 1
fi

CATEGORY="$1"
COMMAND="$2"
DESCRIPTION="$3"
DO_PUSH=false

# オプション解析
for arg in "$@"; do
  if [ "$arg" = "--push" ]; then
    DO_PUSH=true
  fi
done

# ==============================
# 検証
# ==============================
if [ ! -f "$CHANGELOG" ]; then
  echo "ERROR: CHANGELOG.md が見つかりません: $CHANGELOG"
  echo "先にリポジトリをクローンしてください: git clone https://github.com/kumagoro1202/dev-environment-docs.git ~/dev-environment-docs"
  exit 1
fi

# ==============================
# CHANGELOG エントリの作成
# ==============================
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
ENTRY="## ${TIMESTAMP} - [${CATEGORY}] ${DESCRIPTION}

- コマンド: \`${COMMAND}\`
- 実行日時: ${TIMESTAMP}

---

"

# CHANGELOG.md の先頭コメント直後（最初の --- の後）に挿入
# マーカー行を見つけて、その後ろに挿入
MARKER="<!-- 新しい変更はここより上に追記してください -->"

if grep -qF "$MARKER" "$CHANGELOG"; then
  # マーカーの前に挿入（一時ファイル経由）
  TMP_FILE=$(mktemp)
  awk -v entry="${ENTRY}" -v marker="${MARKER}" '
    $0 == marker { print entry }
    { print }
  ' "$CHANGELOG" > "$TMP_FILE"
  mv "$TMP_FILE" "$CHANGELOG"
else
  # マーカーがない場合はファイル末尾に追記
  echo "" >> "$CHANGELOG"
  echo "$ENTRY" >> "$CHANGELOG"
fi

echo "✅ CHANGELOG.md に記録しました:"
echo "   カテゴリ: ${CATEGORY}"
echo "   コマンド: ${COMMAND}"
echo "   説明: ${DESCRIPTION}"
echo "   日時: ${TIMESTAMP}"

# ==============================
# Git commit & push（オプション）
# ==============================
if [ "$DO_PUSH" = true ]; then
  cd "$REPO_DIR"

  if ! git diff --quiet docs/CHANGELOG.md; then
    git add docs/CHANGELOG.md
    git commit -m "docs: 環境変更記録 [${CATEGORY}] ${DESCRIPTION} (${TIMESTAMP})"
    git push
    echo "✅ GitHub にプッシュしました"
  else
    echo "⚠️  CHANGELOG.md に変更がありませんでした"
  fi
fi
