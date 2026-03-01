# 開発ツール設定

## 確認コマンドと実際の値

```bash
$ node --version
v20.20.0

$ npm --version
10.8.2

$ python3 --version
Python 3.12.3

$ pip3 --version
pip 26.0.1 from /home/kuma/.local/lib/python3.12/site-packages/pip (python 3.12)

$ docker --version
Docker version 29.1.4, build 0e6fee6

$ docker compose version
Docker Compose version v5.0.1
```

## バニラ状態との差分

### 1. Node.js（nvm 経由）

**バニラ状態**: Node.js なし

**カスタマイズ後**: nvm でバージョン管理、v20.20.0 (LTS) を使用

```bash
# nvm インストール
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc

# Node.js LTS インストール
nvm install --lts
nvm use --lts
nvm alias default node

# 確認
node --version   # v20.20.0
npm --version    # 10.8.2
```

**バニラとの差分**:
- nvm がインストールされている（`~/.nvm/`）
- Node.js v20 LTS が有効
- npm がグローバルに使える

### 2. Python（システム同梱 + pip 最新化）

**バニラ状態**: Python 3.12.3（Ubuntu 24.04 標準）、pip は古い

**カスタマイズ後**:
- Python 3.12.3（変更なし）
- pip 26.0.1（最新化済み）

```bash
# pip 最新化
pip3 install --upgrade pip
```

### 3. Docker Engine（Docker Desktop なし）

**バニラ状態**: Docker なし

**カスタマイズ後**: Docker Engine 29.1.4 + Compose v5.0.1

WSL2 では Docker Desktop の代わりに Docker Engine をネイティブインストール:

```bash
# Docker Engine インストール（公式手順）
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 現在ユーザーをdockerグループに追加（sudo不要化）
sudo usermod -aG docker $USER

# 自動起動設定（systemd有効化後）
sudo systemctl enable docker
sudo systemctl start docker
```

**Docker Desktop vs Docker Engine 比較**:

| 項目 | Docker Desktop | Docker Engine（採用） |
|------|---------------|----------------------|
| GUI | あり | なし |
| WSL2統合 | 自動 | 手動設定 |
| ライセンス | 商用有料（一定規模以上） | 無料（OSSライセンス） |
| リソース効率 | やや重い | 軽量 |
| 用途 | 個人・小規模開発 | サーバー・自動化環境 |

### 4. Java（未インストール）

**バニラ状態**: なし
**カスタマイズ後**: なし（プロジェクト内のDockerコンテナ内でのみ使用）

## 未インストールのツール（参考）

| ツール | 理由 |
|--------|------|
| pyenv | Python複数バージョン管理不要（3.12のみ使用）|
| sdkman | Java管理不要（Docker内使用） |
| Java（直接） | Docker内で管理 |

## 注意事項

- Node.js は nvm 経由のため、新しいシェルセッションで `nvm use` が必要な場合がある
- Docker はシステム起動時に自動起動する（systemd enabled）
