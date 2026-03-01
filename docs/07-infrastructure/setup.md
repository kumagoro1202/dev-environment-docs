# インフラ・常駐サービス

## 確認コマンドと実際の値

```bash
$ docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
NAMES                       IMAGE                              STATUS
kakeibo-dev-frontend        kakeibo-dev-frontend               Up 3 days
kakeibo-dev-backend         backend-nablarch:latest            Up 3 days (healthy)
kakeibo-dev-postgres        postgres:14-alpine                 Up 3 days (healthy)
kakeibo-dev-test-postgres   postgres:14-alpine                 Up 3 days
kakeibo-app-frontend-1      kakeibo-app-frontend               Up 3 days
kakeibo-app-backend-1       backend-nablarch:latest            Up 3 days (healthy)
kakeibo-postgres            postgres:14-alpine                 Up 3 days (healthy)
kakeibo-test-postgres       postgres:14-alpine                 Up 4 days
gitea-gitea-1               gitea/gitea:latest                 Up 4 days
nablarch-mcp-pgvector       pgvector/pgvector:pg16             Exited (0) 4 days ago

$ crontab -l
0 3 * * * /home/kuma/kakeibo-app/scripts/kakeibo-db-backup.sh >> /home/kuma/kakeibo-app/backups/cron.log 2>&1
```

## 常駐 Docker サービス一覧

### 1. kakeibo-app（家計簿アプリ）本番環境

| コンテナ | 役割 | ポート |
|---------|------|--------|
| kakeibo-app-backend-1 | Nablarch バックエンド API | 8080 |
| kakeibo-app-frontend-1 | フロントエンド | 3000 |
| kakeibo-postgres | PostgreSQL 14 (本番DB) | 5432 |
| kakeibo-test-postgres | PostgreSQL 14 (テストDB) | 5433 |

### 2. kakeibo-dev（家計簿アプリ）開発環境

| コンテナ | 役割 | ポート |
|---------|------|--------|
| kakeibo-dev-backend | 開発用バックエンド | 8081 |
| kakeibo-dev-frontend | 開発用フロントエンド | 3001 |
| kakeibo-dev-postgres | 開発用DB | 5434 |
| kakeibo-dev-test-postgres | 開発テストDB | 5435 |

### 3. Gitea（ローカルGitサーバー）

| 項目 | 内容 |
|------|------|
| 用途 | 社内ドキュメント・非公開リポジトリのローカルミラー |
| イメージ | gitea/gitea:latest |
| 状態 | 常時稼働 |

### 4. nablarch-mcp-pgvector（停止中）

RAG用のpgvectorデータベース。現在は停止状態。必要時に起動する。

## cron ジョブ

| スケジュール | コマンド | 用途 |
|------------|---------|------|
| 毎日午前3時 | kakeibo-db-backup.sh | 家計簿DBの自動バックアップ |

バックアップ先: `/home/kuma/kakeibo-app/backups/`

## systemd 有効サービス（主要なもの）

```bash
$ systemctl list-units --state=active --type=service
containerd.service    # Docker のコンテナランタイム
docker.service        # Docker Engine
cron.service          # cron デーモン
rsyslog.service       # システムログ
dbus.service          # D-Bus（プロセス間通信）
```

## 再現手順

### kakeibo-app 起動

```bash
cd ~/kakeibo-app
docker compose up -d  # 本番環境
```

### Gitea 起動

```bash
cd ~/gitea  # Gitea の docker-compose.yml がある場所
docker compose up -d
```

### cron ジョブ設定

```bash
crontab -e
# 以下を追加:
# 0 3 * * * /home/kuma/kakeibo-app/scripts/kakeibo-db-backup.sh >> /home/kuma/kakeibo-app/backups/cron.log 2>&1
```

## 注意事項

- 本番DBと開発DBは**ポート番号で分離**されている。誤接続に注意
- テストコードは必ずテスト専用DBポートを使用すること
- `docker compose down -v` は**絶対に使わない**（ボリューム削除→データ消失）

## バックアップ方針

| 対象 | 方式 | 頻度 |
|------|------|------|
| kakeibo-postgres | pg_dump → ファイル | 毎日 午前3時 |
| kakeibo-dev-postgres | 手動 or 不要 | 必要時 |
