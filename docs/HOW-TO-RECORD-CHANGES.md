# 環境変更の記録手順

開発環境を変更したとき、この手順に従って記録してください。

## 基本原則

> **「変更したら記録する」**
> 設定変更・ツールインストール・Dockerコンテナ追加など、
> 環境に変化があったら必ず CHANGELOG.md に記録する。

## 方法1: スクリプトを使う（推奨）

`scripts/record-env-change.sh` を使って記録します。

```bash
# 書式
bash ~/dev-environment-docs/scripts/record-env-change.sh <カテゴリ> <コマンド> <説明>

# 例
bash ~/dev-environment-docs/scripts/record-env-change.sh \
  "dev-tools" \
  "nvm install 22" \
  "Node.js v22 LTS をインストール"

bash ~/dev-environment-docs/scripts/record-env-change.sh \
  "claude-code" \
  "claude update" \
  "Claude Code を最新バージョンに更新"

bash ~/dev-environment-docs/scripts/record-env-change.sh \
  "infrastructure" \
  "docker compose up -d" \
  "新しい pgvector コンテナを追加"
```

## 方法2: 手動で CHANGELOG.md を直接編集

```bash
# エディタで開く
nano ~/dev-environment-docs/docs/CHANGELOG.md

# 以下のフォーマットで先頭に追記:
# ## YYYY-MM-DD HH:MM - [カテゴリ] 変更内容
# - 実行コマンドまたは変更ファイル
# - 変更理由・目的
```

## カテゴリ一覧

| カテゴリ名 | 対応ドキュメント | 変更例 |
|-----------|---------------|--------|
| `wsl2` | docs/01-wsl2/setup.md | wsl.conf変更、.wslconfig変更 |
| `shell` | docs/02-shell/setup.md | .bashrc変更、エイリアス追加 |
| `claude-code` | docs/03-claude-code/setup.md | settings.json変更、スキル追加 |
| `dev-tools` | docs/04-dev-tools/setup.md | Node.js/Python/Docker更新 |
| `git` | docs/05-git/setup.md | gitconfig変更、アカウント追加 |
| `tmux` | docs/06-tmux/setup.md | .tmux.conf変更 |
| `infrastructure` | docs/07-infrastructure/setup.md | コンテナ追加/削除、cron変更 |
| `bedrock` | docs/08-bedrock-diff/comparison.md | AWS設定変更 |

## 自動化オプション

### シェルフック（.bashrc への追加提案）

以下を `~/.bashrc` に追加すると、特定のコマンドを実行した際に自動で記録を促す:

```bash
# 環境変更コマンドの記録（~/.bashrc に追加）
_record_env_change_hook() {
  local last_cmd="$(history 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//')"

  # apt install / pip install / npm install / docker compose を検知
  if echo "$last_cmd" | grep -qE '^(sudo apt|apt) (install|remove|purge)|^(pip3?|python3? -m pip) install|^npm install -g|^nvm install|^docker compose'; then
    echo ""
    echo "💡 環境変更を記録しましょう:"
    echo "   bash ~/dev-environment-docs/scripts/record-env-change.sh <カテゴリ> \"$last_cmd\" \"変更理由\""
  fi
}

# PROMPT_COMMAND に追加
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }_record_env_change_hook"
```

> ⚠️ このフックは「記録を促す」提案のみを行います。実際の記録は手動で行ってください。

### 有効化手順

```bash
# ~/.bashrc を編集して上記スニペットを追加
nano ~/.bashrc

# 反映
source ~/.bashrc
```

## commit & push の手順

記録後はリポジトリにプッシュしてください:

```bash
cd ~/dev-environment-docs

git add docs/CHANGELOG.md
git commit -m "docs: 環境変更記録 $(date +%Y-%m-%d)"
git push
```

または `record-env-change.sh` の `--push` オプションを使う（自動commit & push）:

```bash
bash ~/dev-environment-docs/scripts/record-env-change.sh \
  "dev-tools" "npm install -g typescript" "TypeScript グローバルインストール" \
  --push
```

## Q&A

**Q: どんな変更を記録すべきか？**
A: パッケージインストール・設定ファイル変更・Dockerコンテナの追加削除・環境変数の追加など、
   「この環境を別のマシンで再現するために必要な情報」はすべて記録。

**Q: 毎回コミットすべきか？**
A: 1日1回でもOK。ただし大きな変更（新しいツールのインストール等）は即記録を推奨。

**Q: 間違えた記録を修正したい**
A: CHANGELOG.md を直接編集してください。削除より取り消し行の追記が望ましい:
   ```
   ## 2026-03-XX - [修正] XXX の記録を修正
   - 上記 YYYY-MM-DD の記録に誤りがあったため修正
   ```
