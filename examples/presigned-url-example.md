# Presigned URL 生成例

## AWS CLI を使用したPresigned URL生成

### 基本的な生成方法

```bash
# S3オブジェクトのPresigned URL生成（30分有効）
aws s3 presign s3://your-bucket-name/path/to/raspberry-pi-setup.sh \
    --expires-in 1800 \
    --region your-region
```

### 生成されるURL例

```
https://your-bucket-name.s3.your-region.amazonaws.com/path/to/raspberry-pi-setup.sh?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA...%2F20251007%2Fyour-region%2Fs3%2Faws4_request&X-Amz-Date=20251007T143249Z&X-Amz-Expires=1800&X-Amz-SignedHeaders=host&X-Amz-Signature=4d93254ab...
```

## Amazon Q Developer での生成依頼例

```
S3にアップロードしたファイルのPresigned URLを生成してください：
- バケット名: your-bucket-name
- ファイルパス: greengrass-setup/raspberry-pi-setup.sh
- 有効期限: 30分
- リージョン: your-region
```

## 使用方法

### ダウンロードして実行
```bash
# ファイルをダウンロード
curl -o setup.sh "https://your-bucket-name.s3.your-region.amazonaws.com/..."

# 実行権限付与
chmod +x setup.sh

# 実行
./setup.sh
```

### 直接実行（推奨）
```bash
# ダウンロードと同時に実行
curl -s "https://your-bucket-name.s3.your-region.amazonaws.com/..." | bash
```

## セキュリティ考慮事項

- **有効期限**: 必要最小限の期間を設定
- **アクセス制御**: 必要な人のみにURL共有
- **ログ監視**: S3アクセスログで使用状況を監視
- **URL管理**: 使用後は無効化を検討

## トラブルシューティング

### URL期限切れ
```bash
# 新しいURLを生成（30分有効）
aws s3 presign s3://your-bucket-name/path/to/file --expires-in 1800
```

### アクセス権限エラー
- S3バケットポリシーの確認
- IAMユーザーの権限確認
- リージョンの一致確認