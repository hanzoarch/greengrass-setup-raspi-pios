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

1. **前提条件の確認**
   - AWS管理者権限
   - Amazon Q Developerアクセス
   - Raspberry Pi OS (2025/10/01 64bit版)

2. **セットアップ実行**
   ```bash
   curl -s "https://your-bucket.s3.region.amazonaws.com/path/raspberry-pi-setup.sh" | bash
   ```

3. **動作確認**
   ```bash
   sudo systemctl status greengrass
   ```

詳細な手順は [docs/setup-guide.md](docs/setup-guide.md) を参照してください。

## ライセンス

MIT License

## 貢献

Issue報告やPull Requestを歓迎します。