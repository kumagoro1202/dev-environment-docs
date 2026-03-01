# シェル環境設定

## 確認コマンドと実際の値

```bash
$ echo $SHELL
/bin/bash

$ bash --version
GNU bash, version 5.2.21(1)-release (x86_64-pc-linux-gnu)
```

## バニラ状態との差分

### 1. ~/.bashrc への追記

バニラ状態のbashrcに以下が追加されている。

#### NVM（Node Version Manager）

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"          # nvm本体
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # 補完
```

#### カスタムエイリアス（tmux セッション）

```bash
# マルチエージェント作業用セッションへの接続ショートカット
alias css='tmux attach-session -t shogun'
alias csm='tmux attach-session -t multiagent'
```

#### Claude Code CLI PATH

```bash
export PATH="$HOME/.local/bin:$PATH"
```

#### rg エイリアス（Claude Code 内蔵 ripgrep）

```bash
alias rg='/home/kuma/.local/share/claude/versions/2.1.63 --ripgrep'
```

### 2. 組み込みエイリアス（バニラ標準）

以下はバニラ Ubuntu の bashrc に含まれるデフォルトエイリアス:

```bash
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
```

## 再現手順

```bash
# 1. NVM インストール
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# ↑ このコマンドが .bashrc に NVM 設定を自動追記する

# 2. エイリアス追加（~/.bashrc に追記）
cat >> ~/.bashrc << 'EOF'

# マルチエージェント作業用セッションへの接続ショートカット
alias css='tmux attach-session -t shogun'
alias csm='tmux attach-session -t multiagent'

# Claude Code CLI PATH
export PATH="$HOME/.local/bin:$PATH"
EOF

# 3. 反映
source ~/.bashrc
```

## 注意事項

- `rg` エイリアスは Claude Code インストール時に自動設定される。Claude Code のバージョンが変わるとパスが変わる
- `css`/`csm` エイリアスはマルチエージェント環境固有の設定
