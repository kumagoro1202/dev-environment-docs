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

31個のカスタムスキルを搭載。主なカテゴリ
（マルチエージェント系スキルの内部プレフィックスは公開用に `<prefix>` と伏せ字表記）:

| カテゴリ | スキル例 | 用途 |
|---------|---------|------|
| `<prefix>`-xxx | `<prefix>`-kb-builder, `<prefix>`-adr-creator 等 | マルチエージェント制御・ドキュメント生成 |
| kakeibo-xxx | kakeibo-db-verify | 家計簿アプリ専用操作 |
| m4a-minutes-creator | — | 音声→議事録変換 |

スキル一覧（`<prefix>`-系は内部プレフィックスを省略して記載）:
```
kakeibo-db-verify.md         <prefix>-nablarch-architecture-explorer
m4a-minutes-creator          <prefix>-nablarch-doc-generator
<prefix>-adr-creator         <prefix>-nablarch-handler-queue-designer
<prefix>-community-research-report  <prefix>-nablarch-knowledge-builder
<prefix>-concurrent-branch-guard    <prefix>-nablarch-quality-gate-setup
<prefix>-doc-reorganizer     <prefix>-onnx-embedding-migrator
<prefix>-doc-translator-ja   <prefix>-project-registration
<prefix>-engineer-training-plan-generator  <prefix>-project-scaffold
<prefix>-fintan-content-scraper <prefix>-project-status-analyzer
<prefix>-framework-knowledge-builder  <prefix>-rag-system-planner
<prefix>-framework-mcp-server-planner <prefix>-spring-mockvc-test-pattern
<prefix>-kb-builder          <prefix>-tech-article-simplifier
<prefix>-mcp-api-doc-generator  <prefix>-tech-comparison-report
<prefix>-mcp-integration-test-doc-generator <prefix>-tutorial-article-generator
<prefix>-mcp-prompt-generator   <prefix>-yaml-resource-provider-generator
<prefix>-mcp-server-scaffold
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
