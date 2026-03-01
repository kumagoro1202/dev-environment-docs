# dev-environment-docs

WSL2 + Claude Code 開発環境のカスタマイズ記録。バニラ状態からの差分と再現手順をまとめています。

## 環境概要

| 項目 | 値 |
|------|-----|
| OS | Ubuntu 24.04.3 LTS on WSL2 |
| Windows | Windows 11 |
| Claude Code | Max プラン (claude-opus-4-6) |
| 用途 | マルチエージェントAI開発環境 |

## ドキュメント構成

| ドキュメント | 内容 |
|-------------|------|
| [docs/01-wsl2/setup.md](docs/01-wsl2/setup.md) | WSL2基盤の設定（systemd, ネットワーク） |
| [docs/02-shell/setup.md](docs/02-shell/setup.md) | シェル環境（bash, エイリアス, nvm） |
| [docs/03-claude-code/setup.md](docs/03-claude-code/setup.md) | Claude Code設定（hooks, permissions, スキル） |
| [docs/04-dev-tools/setup.md](docs/04-dev-tools/setup.md) | 開発ツール（Node.js, Python, Docker） |
| [docs/05-git/setup.md](docs/05-git/setup.md) | Git/GitHub設定（マルチアカウント） |
| [docs/06-tmux/setup.md](docs/06-tmux/setup.md) | tmux設定（マルチペイン） |
| [docs/07-infrastructure/setup.md](docs/07-infrastructure/setup.md) | 常駐インフラ（Docker, cron） |
| [docs/08-bedrock-diff/comparison.md](docs/08-bedrock-diff/comparison.md) | Claude Max vs AWS Bedrock 差異比較 |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | 環境変更ログ |
| [docs/HOW-TO-RECORD-CHANGES.md](docs/HOW-TO-RECORD-CHANGES.md) | 変更記録手順 |

## 自動記録の仕組み

`scripts/record-env-change.sh` を使うと環境変更を `docs/CHANGELOG.md` に自動記録できます。

```bash
# 使い方
bash ~/dev-environment-docs/scripts/record-env-change.sh "shell" "nvm install 22" "Node.js v22 LTS インストール"
```

詳細は [docs/HOW-TO-RECORD-CHANGES.md](docs/HOW-TO-RECORD-CHANGES.md) を参照。

## バニラWSL2からの主な差分

- systemd 有効化（/etc/wsl.conf）
- wslconfig: mirrored networking + autoMemoryReclaim
- nvm による Node.js バージョン管理
- Docker Desktop ではなく Docker Engine (daemon)
- Claude Code マルチエージェント構成（tmux + 複数セッション）
- 31個のカスタムスキル（~/.claude/skills/）
- Gitea（ローカルGitサーバー）常駐
- kakeibo-app Docker環境常駐

最終更新: 2026-03-01
