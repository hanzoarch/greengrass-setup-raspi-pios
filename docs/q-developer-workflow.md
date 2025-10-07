# Amazon Q Developer ワークフロー

## 概要

Amazon Q Developerを活用してAWS IoT Greengrassセットアップを自動化するワークフローです。

## ワークフロー図

```
👤 人間 → 🤖 Q Developer → ☁️ AWS → 🍓 Raspberry Pi
```

## 詳細ステップ

### ステップ1: IAM環境準備

**👤 人間の依頼例:**
```
AWS IoT Greengrass用のIAMユーザーとサービスロールを作成してください。

要件:
- IAMユーザー名: greengrass-device-user
- 必要な権限: IoT Core, Greengrass, 最小限のIAM権限
- サービスロール: GreengrassV2TokenExchangeRole
- リージョン: ap-northeast-1
- 参考ポリシー: policies/greengrass-user-policy.json

セキュリティ要件:
- 最小権限の原則に従う
- 一時的な使用を想定
```

**🤖 Q Developer の実行内容:**
1. `scripts/create-iam-resources.sh` を参考にIAMリソース作成
2. `policies/` フォルダ内のJSONファイルを使用
3. アクセスキーとシークレットキーを生成
4. 作成されたリソースの確認

**📋 取得する情報:**
- Access Key ID
- Secret Access Key
- リージョン
- 作成されたリソースのARN

---

### ステップ2: セットアップスクリプト準備

**👤 人間の依頼例:**
```
Raspberry Pi用のGreengrassセットアップスクリプトを作成してください。

要件:
- ベーススクリプト: scripts/raspberry-pi-setup.sh
- 対象OS: Raspberry Pi OS (2025/10/01 64bit版)
- 認証情報埋め込み: [ステップ1で取得した情報]
- S3バケット: [your-bucket-name]
- 完全自動化（手動入力なし）

カスタマイズ:
- 認証情報をスクリプト内に安全に埋め込み
- エラーハンドリングの強化
- ログ出力の詳細化
```

**🤖 Q Developer の実行内容:**
1. `scripts/raspberry-pi-setup.sh` をベースに認証情報を埋め込み
2. 対象OS向けの最適化
3. S3バケットへのアップロード
4. 必要に応じて `scripts/debug-greengrass.sh` もアップロード

---

### ステップ3: 配布URL生成

**👤 人間の依頼例:**
```
S3にアップロードしたスクリプトのPresigned URLを生成してください。

要件:
- 対象ファイル: raspberry-pi-setup.sh
- 有効期限: 24時間
- 参考例: examples/presigned-url-example.md
- デバッグ用スクリプトのURLも生成

セキュリティ:
- 最小限の有効期限
- アクセスログの有効化
```

**🤖 Q Developer の実行内容:**
1. `examples/presigned-url-example.md` を参考にURL生成
2. メインスクリプトとデバッグスクリプトのURL作成
3. 有効期限とセキュリティ設定の確認

**📋 提供される情報:**
- メインセットアップスクリプトURL
- デバッグスクリプトURL
- URL有効期限
- 使用方法の説明

---

### ステップ4: 実行とサポート

**👤 人間の作業:**
```bash
# Raspberry Piで実行
curl -s "[Q Developerが生成したURL]" | bash
```

**🤖 Q Developer のサポート:**
- 実行方法の詳細説明
- エラー発生時のデバッグ支援
- `docs/troubleshooting.md` を参考にした問題解決
- 必要に応じて追加スクリプトの提供

## Q Developer活用のメリット

### 🚀 効率化
- **自動化**: 手動でのAWS CLI操作が不要
- **テンプレート活用**: 既存スクリプトの再利用
- **エラー回避**: 設定ミスの防止

### 🔒 セキュリティ
- **最小権限**: 必要最小限のIAMポリシー適用
- **一時的配布**: Presigned URLで期限管理
- **認証情報管理**: 安全な埋め込み方式

### 🛠️ 保守性
- **再現可能**: 同じ手順で何度でも実行可能
- **ドキュメント化**: 手順の自動記録
- **バージョン管理**: Githubでの管理

## 対話例テンプレート

### IAMリソース作成依頼
```
以下の要件でAWS IoT Greengrass用のIAMリソースを作成してください：

【基本情報】
- プロジェクト: IoT Greengrass セットアップ
- 対象デバイス: Raspberry Pi 4B
- 用途: 開発・テスト環境

【IAMユーザー】
- 名前: greengrass-device-user
- パス: /greengrass/
- ポリシー: policies/greengrass-user-policy.json を参照

【サービスロール】
- 名前: GreengrassV2TokenExchangeRole
- 信頼ポリシー: policies/greengrass-service-role.json
- 権限ポリシー: policies/greengrass-role-policy.json

【セキュリティ要件】
- 最小権限の原則
- 一時的使用想定
- アクセスキーの安全な管理

実行後、認証情報を安全に提供してください。
```

### スクリプト作成依頼
```
Raspberry Pi用のGreengrassセットアップスクリプトを作成してください：

【環境情報】
- OS: Raspberry Pi OS (2025/10/01 64bit版)
- ハードウェア: Raspberry Pi 4B (4GB RAM以上)
- ベーススクリプト: scripts/raspberry-pi-setup.sh

【認証情報】
- Access Key ID: [前ステップで取得]
- Secret Access Key: [前ステップで取得]
- リージョン: ap-northeast-1

【配布方法】
- S3バケット: [your-bucket-name]
- パス: greengrass-setup/
- Presigned URL生成

【カスタマイズ要件】
- 認証情報の安全な埋め込み
- エラーハンドリング強化
- 詳細ログ出力
- 完全自動化（手動入力なし）

スクリプト作成後、S3アップロードとPresigned URL生成をお願いします。
```

## 成功基準

### ✅ ステップ1完了基準
- [ ] IAMユーザー作成完了
- [ ] 適切なポリシーアタッチ
- [ ] サービスロール作成完了
- [ ] アクセスキー取得

### ✅ ステップ2完了基準
- [ ] 認証情報埋め込み完了
- [ ] S3アップロード成功
- [ ] スクリプト動作確認

### ✅ ステップ3完了基準
- [ ] Presigned URL生成
- [ ] URL有効性確認
- [ ] 実行手順明確化

### ✅ ステップ4完了基準
- [ ] Raspberry Piでの実行成功
- [ ] Greengrassサービス起動
- [ ] AWS IoTコンソールでデバイス確認

この ワークフローにより、AWS IoT Greengrassのセットアップが大幅に簡素化され、人的エラーも最小限に抑えられます。