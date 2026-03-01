# Claude Max vs AWS Bedrock 差異比較

自宅環境（Claude Code Max プラン）と業務環境（Claude Code with AWS Bedrock）の違いをまとめる。

> 参照: https://code.claude.com/docs/en/amazon-bedrock

## 概要比較

| 項目 | 自宅: Claude Max | 業務: AWS Bedrock |
|------|----------------|-----------------|
| **認証方式** | Anthropic アカウント / APIキー | AWS 認証情報 (IAM / SSO / Bedrock APIキー) |
| **料金体系** | 月額固定（Maxプラン）| 従量課金（APIコール単位）|
| **モデル選択** | 自由（Opus/Sonnet/Haiku）| 固定推奨（バージョンピン必須）|
| **/login / /logout** | 使用可能 | **無効**（AWS認証で代替）|
| **セキュリティ** | 個人レベル | 企業レベル（IAM, 監査ログ）|
| **コンプライアンス** | なし | あり（AWS準拠）|
| **Guardrails** | なし | Amazon Bedrock Guardrails 対応 |
| **セットアップ複雑度** | 低（APIキーのみ）| 高（IAM設定、リージョン指定等）|

## 認証方式の違い

### 自宅（Max プラン）
```bash
# Anthropic APIキーで認証
export ANTHROPIC_API_KEY=<your-api-key>
```

### 業務（Bedrock）
複数の認証方式が選択可能:

```bash
# Option A: AWS CLIプロファイル
aws configure
export AWS_PROFILE=myprofile

# Option B: 環境変数（アクセスキー）
export AWS_ACCESS_KEY_ID=<key>
export AWS_SECRET_ACCESS_KEY=<secret>
export AWS_SESSION_TOKEN=<token>

# Option C: SSO（企業向け）
aws sso login --profile=myprofile
export AWS_PROFILE=myprofile

# Option D: Bedrock APIキー（シンプル）
export AWS_BEARER_TOKEN_BEDROCK=<bedrock-api-key>

# Bedrock有効化
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
```

## モデルの違い

### 自宅（Max）
- `/model` コマンドで自由にモデル変更可能
- claude-opus-4-6, claude-sonnet-4-6, claude-haiku-4-5 など

### 業務（Bedrock）
- モデルIDのピン留めが**強く推奨**（エイリアスは危険）:

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-6-v1'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

> ⚠️ Bedrockでエイリアスを使うと、Anthropicが新しいモデルをリリースした際に
> 自分のBedrockアカウントで未承認のモデルへの切り替えが発生し、サービス停止リスクがある。

## IAM 設定（Bedrock固有）

業務環境では IAM ポリシーが必要:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ListInferenceProfiles"
      ],
      "Resource": [
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:foundation-model/*"
      ]
    }
  ]
}
```

## プロンプトキャッシング

| 項目 | Max | Bedrock |
|------|-----|---------|
| 利用可否 | デフォルト有効 | リージョンによって利用不可の場合あり |
| 無効化方法 | 設定不要 | `export DISABLE_PROMPT_CACHING=1` |

## セキュリティ機能の差異

### 業務（Bedrock）固有の機能

- **Amazon Bedrock Guardrails**: コンテンツフィルタリング設定可能
- **IAM**: 最小権限の原則でアクセス制御
- **CloudTrail**: APIコールの監査ログが残る
- **データ残留**: AWSリージョン内にデータを保持可能
- **VPC対応**: プライベートネットワーク内での利用可能

### 自宅（Max）固有の機能

- `/login` / `/logout` コマンド（Bedrockでは無効）
- シンプルなAPIキー管理

## 料金比較

| 項目 | Max プラン | Bedrock |
|------|----------|---------|
| 課金方式 | 月額固定 | 従量課金（入力/出力トークン単位）|
| 大量利用時 | コスト固定 | コスト増大 |
| 少量利用時 | 割高の場合も | 低コスト |
| 予算管理 | 簡単（固定）| AWS Cost Explorerで管理 |

## 設定移行チェックリスト（自宅 → 業務）

自宅環境から業務環境へ移行する際に確認すること:

- [ ] AWS Bedrockアカウントでモデルアクセスを有効化
- [ ] IAMポリシーを作成・適用
- [ ] `CLAUDE_CODE_USE_BEDROCK=1` を設定
- [ ] `AWS_REGION` を設定
- [ ] モデルIDをピン留め（エイリアス禁止）
- [ ] プロンプトキャッシングの利用可否を確認
- [ ] `/login` コマンドが使えないことを認識
- [ ] スキル・settings.jsonの内容を確認（機密情報がないか）

## まとめ

| 用途 | 推奨 |
|------|------|
| 個人開発・プロトタイピング | Claude Max |
| 企業・チーム開発・コンプライアンス要件あり | AWS Bedrock |
| 自動化・CI/CD組み込み | AWS Bedrock（IAM権限管理）|
