# AWS IoT Greengrass Raspberry Pi Setup

Amazon Q Developerを活用してRaspberry Pi上でAWS IoT Greengrassを自動セットアップするためのスクリプトと手順書です。

## 対応環境

- **Raspberry Pi OS**: 2025/10/01リリース 64bit版
- **Raspberry Pi**: 5 (テスト済み)
- **AWS IoT Greengrass**: v2 (最新版)

> **注意**: Raspberry Pi 4Bでの動作は未検証です。

## フォルダ構成

```
├── docs/                   # ドキュメント
│   ├── setup-guide.md     # セットアップ手順書
│   ├── q-developer-workflow.md  # Q Developerワークフロー
│   └── troubleshooting.md # トラブルシューティング
├── scripts/               # セットアップスクリプト
│   ├── raspberry-pi-setup.sh    # メインセットアップ
│   ├── create-iam-resources.sh  # IAMリソース作成
│   └── debug-greengrass.sh      # デバッグ用
├── policies/              # IAMポリシー定義
│   ├── greengrass-user-policy.json     # IAMユーザーポリシー
│   ├── greengrass-service-role.json    # サービスロール信頼ポリシー
│   └── greengrass-role-policy.json     # ロールポリシー
└── examples/              # 設定例・サンプル
    ├── presigned-url-example.md        # URL生成例
    └── component-example.py            # サンプルコンポーネント
```

## クイックスタート

### 前提条件

1. **AWS CLI設定済み環境**
   ```bash
   aws configure
   # Access Key ID、Secret Access Key、リージョンを設定
   ```

2. **必要な権限・環境**
   - AWS管理者権限
   - Amazon Q Developerアクセス
   - Raspberry Pi OS (2025/10/01 64bit版)

### セットアップ手順

1. **IAMリソース作成**
   ```bash
   ./scripts/create-iam-resources.sh
   ```

2. **認証情報をスクリプトに設定**
   ```bash
   # 出力された認証情報をraspberry-pi-setup.shに設定
   nano scripts/raspberry-pi-setup.sh
   ```

3. **Raspberry Piで実行**
   ```bash
   # スクリプトを転送して実行
   ./raspberry-pi-setup.sh
   ```

4. **動作確認**
   ```bash
   sudo systemctl status greengrass
   ```

詳細な手順は [docs/setup-guide.md](docs/setup-guide.md) を参照してください。

## リソース削除

テスト完了後、作成したAWSリソースをすべて削除：

```bash
./scripts/cleanup-greengrass-resources.sh
```

**パラメータ（オプション）:**
```bash
./scripts/cleanup-greengrass-resources.sh [USER_NAME] [POLICY_NAME] [ROLE_NAME] [BUCKET_PREFIX]
```

## ライセンス

MIT License

## 貢献

Issue報告やPull Requestを歓迎します。