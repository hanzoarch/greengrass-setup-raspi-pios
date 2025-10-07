# AWS IoT Greengrass セットアップ手順書

## 概要

Amazon Q Developerを活用してRaspberry Pi OS (2025/10/01 64bit版) 上でAWS IoT Greengrassを自動セットアップする手順です。

## 前提条件

- **Raspberry Pi 5** (テスト済み)
- **Raspberry Pi OS** (2025/10/01リリース 64bit版)

> **注意**: 本手順はRaspberry Pi 5でのみテストされています。Raspberry Pi 4Bでの動作は未検証です。
- **インターネット接続** 必須
- **Amazon Q Developer** アクセス権限
- **AWS管理者権限** を持つアカウント

## セットアップ手順

### ステップ1: Amazon Q DeveloperでAWS環境準備

#### 1-1. IAMリソース作成依頼

Amazon Q Developerに以下を依頼：

```
AWS IoT Greengrass用のIAMユーザーとサービスロールを作成してください。
- IAMユーザー名: greengrass-device-user
- 必要な権限: IoT Core, Greengrass, 最小限のIAM権限
- サービスロール: GreengrassV2TokenExchangeRole
- リージョン: [your-region]

参考ポリシー: policies/greengrass-user-policy.json
```

**Q Developerが実行する内容:**
- IAMユーザー作成
- アクセスキー生成
- Greengrassサービスロール作成
- 必要なポリシー設定

**取得する情報:**
- Access Key ID
- Secret Access Key
- リージョン

### ステップ2: Amazon Q Developerでスクリプト準備・S3アップロード

#### 2-1. セットアップスクリプト作成依頼

Amazon Q Developerに以下を依頼：

```
Raspberry Pi用のGreengrassセットアップスクリプトを作成し、
ステップ1で取得した認証情報を埋め込んでS3にアップロードしてください。
- ベーススクリプト: scripts/raspberry-pi-setup.sh
- 認証情報: [ステップ1で取得したキー]
- S3バケット: [your-bucket-name]
- 対象OS: Raspberry Pi OS (2025/10/01 64bit版)
```

**Q Developerが実行する内容:**
- 認証情報を埋め込んだセットアップスクリプト作成
- S3バケットへのアップロード
- 必要に応じて追加リソースもアップロード

### ステップ3: Amazon Q DeveloperでPresigned URL生成

#### 3-1. 共有URL生成依頼

Amazon Q Developerに以下を依頼：

```
S3にアップロードしたGreengrassセットアップスクリプトの
Presigned URLを生成してください。
- 有効期限: 24時間
- 対象ファイル: raspberry-pi-setup.sh
- 参考例: examples/presigned-url-example.md
```

**Q Developerが提供する情報:**
- メインセットアップスクリプトのPresigned URL
- デバッグスクリプトのPresigned URL（必要に応じて）
- URL有効期限

### ステップ4: Raspberry Piでスクリプト実行

#### 4-1. ワンコマンド実行

ラズパイのターミナルで以下を実行：

```bash
curl -s "[Q Developerが生成したPresigned URL]" | bash
```

#### 4-2. 実行監視

- **実行時間**: 約15-25分
- **ログ確認**: `tail -f ~/greengrass-setup.log`
- **進捗確認**: ターミナル出力を監視

## 自動実行される内容

1. **システム準備**
   - パッケージ更新 (`apt update && apt upgrade`)
   - Java、AWS CLI インストール
   - ユーザー・グループ設定

2. **AWS接続**
   - 認証情報設定（埋め込み済み）
   - 接続テスト

3. **Greengrass インストール**
   - ソフトウェアダウンロード
   - ユーザー・ディレクトリ作成
   - 権限設定

4. **デバイス登録**
   - IoT Thing作成
   - 証明書生成
   - ポリシー適用

5. **サービス起動**
   - systemdサービス登録
   - Greengrassサービス開始

6. **サンプルデプロイ**
   - Hello Worldコンポーネント配置

## 動作確認

### 成功確認コマンド

```bash
# サービス状態
sudo systemctl status greengrass

# コンポーネント一覧
sudo /greengrass/v2/bin/greengrass-cli component list

# ログ確認
sudo tail -f /greengrass/v2/logs/greengrass.log
```

### 成功基準

- [ ] greengrassサービスが `active (running)`
- [ ] エラーログなし
- [ ] AWS IoTコンソールでThingが表示
- [ ] Hello Worldコンポーネントが動作

## 作成されるAWSリソース

### IoT Core
- **Thing**: `RaspberryPi-[タイムスタンプ]`
- **Thing Group**: `GreengrassDevices`
- **証明書**: デバイス認証用
- **ポリシー**: `GreengrassV2IoTThingPolicy`

### IAM
- **ユーザー**: `greengrass-device-user`
- **ロール**: `GreengrassV2TokenExchangeRole`
- **ポリシー**: IoT・Greengrass・IAM権限

## セキュリティ考慮事項

- **最小権限**: IAMユーザーは必要最小限の権限のみ
- **一意命名**: Thing名にタイムスタンプで重複回避
- **証明書管理**: デバイス固有の証明書で認証
- **ログ管理**: 詳細ログで監査証跡確保

## トラブルシューティング

問題が発生した場合は [troubleshooting.md](troubleshooting.md) を参照してください。

## 参考資料

- [AWS IoT Greengrass 公式ドキュメント](https://docs.aws.amazon.com/greengrass/)
- [Raspberry Pi OS ダウンロード](https://www.raspberrypi.org/software/operating-systems/)
- [Amazon Q Developer](https://aws.amazon.com/q/developer/)