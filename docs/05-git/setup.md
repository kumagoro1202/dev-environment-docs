# Git / GitHub 設定

## 確認コマンドと実際の値

```bash
$ cat ~/.gitconfig
[user]
    email = <redacted>
    name = kumanoGoro
[credential]
    helper = !gh auth git-credential

$ gh auth status
github.com
  ✓ Logged in to github.com account kumagoro1202 (active)
  ✓ Logged in to github.com account kumanoGoro (inactive)
```

## バニラ状態との差分

### 1. グローバル Git 設定（~/.gitconfig）

**バニラ状態**: user.name/email 未設定、credential helper なし

**カスタマイズ後**:
- user.name: kumanoGoro（グローバルデフォルト）
- credential helper: `gh auth git-credential`（GitHub CLI 経由で認証）

```bash
# 設定方法
git config --global user.name "your-username"
git config --global user.email "your-email@example.com"
git config --global credential.helper '!gh auth git-credential'
```

### 2. GitHub CLI（gh）のマルチアカウント設定

**バニラ状態**: gh なし

**カスタマイズ後**: 2アカウントを切り替えて使用

| アカウント | 用途 | 状態 |
|-----------|------|------|
| kumagoro1202 | メインアカウント（ほとんどのプロジェクト） | デフォルト（active）|
| kumanoGoro | 特定プロジェクト専用 | 非アクティブ |

**アカウント切り替え方法**:
```bash
# kumagoro1202 に切り替え
gh auth switch -u kumagoro1202

# kumanoGoro に切り替え
gh auth switch -u kumanoGoro

# 現在のアカウント確認
gh auth status
```

**プロジェクト別アカウントルール**:

| プロジェクト | 使用アカウント | 備考 |
|-------------|--------------|------|
| shift-scheduler-claude | kumanoGoro | プロジェクト専用アカウント |
| その他全プロジェクト | kumagoro1202 | メインアカウント |

> ⚠️ **重要**: 並行して異なるアカウントのプロジェクトを作業しない。
> コミット先アカウントの混在を防ぐため、作業開始前に `gh auth status` でアカウントを確認すること。

### 3. gh CLI インストール方法

```bash
# Ubuntu への gh インストール
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
  sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh -y

# 認証
gh auth login
```

### 4. SSH 設定

SSH 鍵を設定している場合の参考構成（~/.ssh/config）:

```
Host github-main
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa_main  ← 実際のファイル名に置換

Host github-sub
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa_sub   ← 実際のファイル名に置換
```

## 注意事項

- credential helper は `gh auth git-credential` を使うと、gh CLI のトークンを使い回せる
- SSH鍵のパスは記録するが、鍵の内容（公開鍵・秘密鍵）は絶対に記録しない
