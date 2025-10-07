# Greengrass リソース削除ガイド

## 概要

このガイドでは、Greengrassセットアップで作成されたすべてのAWSリソースを安全に削除する方法を説明します。

## 削除スクリプト実行

### 基本実行

```bash
./scripts/cleanup-greengrass-resources.sh
```

### カスタムパラメータ指定

```bash
./scripts/cleanup-greengrass-resources.sh [USER_NAME] [POLICY_NAME] [ROLE_NAME] [BUCKET_PREFIX]
```

**パラメータ:**
- `USER_NAME`: IAMユーザー名（デフォルト: greengrass-device-user）
- `POLICY_NAME`: IAMポリシー名（デフォルト: GreengrassDevicePolicy）
- `ROLE_NAME`: サービスロール名（デフォルト: GreengrassV2TokenExchangeRole）
- `BUCKET_PREFIX`: S3バケットプレフィックス（デフォルト: greengrass-setup）

## 削除されるリソース

### 1. S3リソース
- バケット: `greengrass-setup-*`プレフィックス
- オブジェクト: バケット内のすべてのファイル

### 2. IoT Coreリソース
- **Things**: `RaspberryPi-*`、`Greengrass*`プレフィックス
- **証明書**: Thing にアタッチされたすべての証明書
- **ポリシー**: `Greengrass*`プレフィックス
- **Thing Groups**: `Greengrass*`プレフィックス
- **Role Aliases**: `Greengrass*`プレフィックス

### 3. Greengrassリソース
- **Core Devices**: `RaspberryPi-*`、`Greengrass*`プレフィックス

### 4. IAMリソース
- **ユーザー**: 指定されたIAMユーザー
- **アクセスキー**: ユーザーに関連付けられたすべてのキー
- **ロール**: 指定されたサービスロール
- **ポリシー**: ユーザーとロールに関連付けられたポリシー

## 削除プロセス

スクリプトは以下の順序でリソースを削除します：

1. **S3バケット削除**
   - オブジェクト削除 → バケット削除

2. **IoT Things削除**
   - ポリシーデタッチ → 証明書デタッチ → 証明書無効化 → 証明書削除 → Thing削除

3. **Thing Groups削除**

4. **IoTポリシー削除**

5. **Role Aliases削除**

6. **Greengrassコアデバイス削除**

7. **IAMユーザー削除**
   - ポリシーデタッチ → アクセスキー削除 → ユーザー削除

8. **IAMロール削除**
   - ポリシーデタッチ → インラインポリシー削除 → ロール削除

9. **IAMポリシー削除**

## 注意事項

- **不可逆操作**: 削除されたリソースは復元できません
- **権限確認**: 削除実行前に適切なAWS権限があることを確認してください
- **リージョン**: スクリプトは環境変数`AWS_DEFAULT_REGION`のリージョンで実行されます
- **エラー処理**: 存在しないリソースのエラーは無視されます

## 実行例

```bash
# デフォルト設定で削除
./scripts/cleanup-greengrass-resources.sh

# カスタム設定で削除
./scripts/cleanup-greengrass-resources.sh my-greengrass-user MyGreengrassPolicy MyGreengrassRole my-bucket-prefix
```

## 削除確認

削除完了後、以下のコマンドでリソースが削除されたことを確認できます：

```bash
# IAMユーザー確認
aws iam get-user --user-name greengrass-device-user

# IoT Things確認
aws iot list-things --region us-east-1

# S3バケット確認
aws s3 ls | grep greengrass-setup
```

リソースが見つからないエラーが表示されれば、正常に削除されています。