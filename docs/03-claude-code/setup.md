# Claude Code 設定

## 確認コマンドと実際の値

```bash
$ ls ~/.claude/
backups  cache  debug  downloads  file-history  history.jsonl  ide  paste-cache
plans  plugins  projects  session-env  settings.json  shell-snapshots  skills
stats-cache.json  tasks  telemetry  todos
```

## バニラ状態との差分

### 1. グローバル設定（~/.claude/settings.json）

```json
{
  "model": "claude-opus-4-6",
  "enableAllProjectMcpServers": true,
  "statusLine": {
    "type": "command",
    "command": ".claude/statusline.sh"
  },
  "skipDangerousModePermissionPrompt": true
}
```

| 設定 | バニラ値 | カスタム値 | 効果 |
|------|---------|-----------|------|
| `model` | claude-sonnet-4-x | claude-opus-4-6 | デフォルトモデルをOpus（最高品質）に変更 |
| `enableAllProjectMcpServers` | false | true | プロジェクト固有MCPサーバーを自動有効化 |
| `statusLine` | なし | コマンド指定 | ターミナルステータスラインを独自スクリプトで表示 |
| `skipDangerousModePermissionPrompt` | false | true | --dangerousモード起動時の確認をスキップ |

### 2. カスタムスキル（~/.claude/skills/）

31個のカスタムスキルを搭載。主なカテゴリ:

| カテゴリ | スキル例 | 用途 |
|---------|---------|------|
| shogun-xxx | shogun-kb-builder, shogun-adr-creator 等 | マルチエージェント制御・ドキュメント生成 |
| kakeibo-xxx | kakeibo-db-verify | 家計簿アプリ専用操作 |
| m4a-minutes-creator | — | 音声→議事録変換 |

スキル一覧:
```
kakeibo-db-verify.md         shogun-nablarch-architecture-explorer
m4a-minutes-creator          shogun-nablarch-doc-generator
shogun-adr-creator           shogun-nablarch-handler-queue-designer
shogun-community-research-report  shogun-nablarch-knowledge-builder
shogun-concurrent-branch-guard    shogun-nablarch-quality-gate-setup
shogun-doc-reorganizer        shogun-onnx-embedding-migrator
shogun-doc-translator-ja      shogun-project-registration
shogun-engineer-training-plan-generator  shogun-project-scaffold
shogun-fintan-content-scraper shogun-project-status-analyzer
shogun-framework-knowledge-builder  shogun-rag-system-planner
shogun-framework-mcp-server-planner shogun-spring-mockvc-test-pattern
shogun-kb-builder             shogun-tech-article-simplifier
shogun-mcp-api-doc-generator  shogun-tech-comparison-report
shogun-mcp-integration-test-doc-generator shogun-tutorial-article-generator
shogun-mcp-prompt-generator   shogun-yaml-resource-provider-generator
shogun-mcp-server-scaffold
```

### 3. プロジェクト固有設定（例: org-shogun/.claude/settings.json）

プロジェクト単位でhooks・permissionsを設定:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/stop_hook_inbox.sh",
            "timeout": 10
          }
        ]
      }
    ]
  },
  "permissions": {
    "deny": [
      "Bash(rm -rf /)",
      "Bash(rm -rf /*)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(sudo *)",
      "Bash(kill *)"
      // ...その他破壊的操作を列挙
    ]
  }
}
```

**Stop hookの役割**: Claude Code が停止する際に `stop_hook_inbox.sh` を実行し、
メールボックスに未読メッセージがないかチェックする（マルチエージェント通信基盤）。

### 4. プラグイン（~/.claude/plugins/）

インストール済みプラグイン:

| プラグイン | バージョン | 用途 |
|-----------|-----------|------|
| nabledge-6@nabledge | 0.2 | Nablarch 6 フレームワーク知識ベース |

### 5. ステータスライン設定

`~/.claude/settings.json` の `statusLine.command` で指定したシェルスクリプト
(`.claude/statusline.sh`) がターミナル下部に情報を表示。

マルチエージェント環境での状態表示（エージェントID、現在タスク等）に使用。

## 再現手順

```bash
# 1. Claude Code インストール（npm経由）
npm install -g @anthropic-ai/claude-code

# 2. グローバル設定
cat > ~/.claude/settings.json << 'EOF'
{
  "model": "claude-opus-4-6",
  "enableAllProjectMcpServers": true,
  "skipDangerousModePermissionPrompt": true
}
EOF

# 3. スキルはリポジトリからコピー
# （スキルファイルはプロジェクトの .claude/skills/ からリンクまたはコピー）

# 4. プラグインはClaude Code内から /plugins install で追加
```

## 注意事項

- `skipDangerousModePermissionPrompt: true` は自動化環境向け設定。通常の単独使用では不要
- カスタムスキルは組織固有の業務ロジックを含む場合があるため、公開時は内容を確認すること
