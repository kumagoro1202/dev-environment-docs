# WSL2 基盤設定

## 確認コマンドと実際の値

```bash
$ lsb_release -a
Distributor ID: Ubuntu
Description:    Ubuntu 24.04.3 LTS
Release:        24.04
Codename:       noble

$ uname -r
6.6.87.2-microsoft-standard-WSL2
```

## バニラ状態との差分

### 1. systemd 有効化（/etc/wsl.conf）

**バニラ状態**: systemd 無効（init プロセスなし）

**カスタマイズ後** (`/etc/wsl.conf`):
```ini
[boot]
systemd=true
```

**効果**:
- `systemctl` コマンドが使える
- Docker Engine の自動起動が可能になる（`systemctl enable docker`）
- cron などのシステムサービスが正常動作する

**設定方法**:
```bash
sudo tee /etc/wsl.conf << 'EOF'
[boot]
systemd=true
EOF
# WSLを再起動して有効化
wsl --shutdown  # Windows側で実行
```

### 2. WSL2 グローバル設定（.wslconfig）

**バニラ状態**: デフォルト設定（NAT ネットワーク、メモリ自動管理なし）

**カスタマイズ後** (`C:\Users\<username>\.wslconfig`):
```ini
[wsl2]
networkingMode=mirrored

[experimental]
autoMemoryReclaim=gradual
```

**設定の意味**:

| 設定 | 値 | 効果 |
|------|-----|------|
| `networkingMode` | `mirrored` | WindowsとWSL2がIPを共有。ローカルホストでの双方向アクセスが簡単になる |
| `autoMemoryReclaim` | `gradual` | WSL2が使わなくなったメモリをWindowsに段階的に返却。メモリ効率向上 |

**設定方法**:
```
# Windows PowerShellで実行
notepad $env:USERPROFILE\.wslconfig

# 以下を記載して保存
[wsl2]
networkingMode=mirrored

[experimental]
autoMemoryReclaim=gradual

# WSLを再起動
wsl --shutdown
```

## 再現手順（クリーン環境からの設定手順）

1. WSL2をインストール（Microsoft公式手順）
2. Ubuntu 24.04をインストール
3. 初回起動後、上記の`/etc/wsl.conf`を設定
4. Windows側で`.wslconfig`を設定
5. WSLを再起動: `wsl --shutdown`

## 注意事項

- `networkingMode=mirrored`は Windows 11 Build 22631以降で利用可能
- `autoMemoryReclaim`はWSL2 2.0以降の機能
- systemd有効化後、一部の古いスクリプトが動作しない場合がある
