# トラブルシューティング

## よくある問題と解決方法

### 1. Java関連エラー

#### 問題: `java: command not found`
```bash
# 解決方法
sudo apt update
sudo apt install default-jdk
export JAVA_HOME=/usr/lib/jvm/default-java
```

#### 問題: Java バージョンが古い
```bash
# 確認
java -version

# 最新版インストール
sudo apt install openjdk-17-jdk
sudo update-alternatives --config java
```

### 2. AWS認証エラー

#### 問題: `Unable to locate credentials`
- Amazon Q Developerで認証情報が正しく埋め込まれているか確認
- スクリプト内の認証情報設定部分を確認

#### 問題: `Access Denied`
- IAMユーザーの権限確認
- ポリシーが正しくアタッチされているか確認
- リージョンが一致しているか確認

### 3. Greengrass インストールエラー

#### 問題: `GreengrassV2TokenExchangeRole not found`
```bash
# 解決方法: Amazon Q Developerに依頼
# "GreengrassV2TokenExchangeRoleを作成してください"
```

#### 問題: `Permission denied` エラー
```bash
# ディレクトリ権限修正
sudo chown -R ggc_user:ggc_group /greengrass/v2/
sudo chmod -R 755 /greengrass/v2/
```

### 4. サービス起動エラー

#### 問題: `greengrass.service not found`
```bash
# サービス状態確認
sudo systemctl status greengrass

# 手動でサービス作成が必要な場合
sudo systemctl daemon-reload
sudo systemctl enable greengrass
sudo systemctl start greengrass
```

#### 問題: サービスが `failed` 状態
```bash
# ログ確認
sudo journalctl -u greengrass --no-pager -n 50

# Greengrassログ確認
sudo tail -f /greengrass/v2/logs/greengrass.log

# サービス再起動
sudo systemctl restart greengrass
```

### 5. ネットワーク関連エラー

#### 問題: ダウンロードエラー
```bash
# 接続確認
ping -c 3 8.8.8.8

# DNS確認
nslookup d2s8p88vqu9w66.cloudfront.net

# プロキシ設定確認（必要に応じて）
echo $http_proxy
echo $https_proxy
```

#### 問題: IoT Core接続エラー
```bash
# IoTエンドポイント確認
aws iot describe-endpoint --endpoint-type iot:Data-ATS

# 証明書確認
sudo ls -la /greengrass/v2/work/aws.greengrass.nucleus/
```

### 6. システムリソース不足

#### 問題: メモリ不足
```bash
# メモリ使用量確認
free -h

# スワップ有効化
sudo dphys-swapfile swapoff
sudo dphys-swapfile swapon
```

#### 問題: ディスク容量不足
```bash
# ディスク使用量確認
df -h

# 不要ファイル削除
sudo apt autoremove
sudo apt autoclean
```

## デバッグ用コマンド

### システム情報収集
```bash
# OS情報
cat /etc/os-release

# ハードウェア情報
cat /proc/cpuinfo | grep "model name" | head -1
cat /proc/meminfo | grep MemTotal

# Java環境
java -version
echo $JAVA_HOME

# AWS CLI設定
aws --version
aws configure list
```

### Greengrass状態確認
```bash
# サービス状態
sudo systemctl status greengrass

# プロセス確認
ps aux | grep greengrass

# ポート確認
sudo netstat -tlnp | grep java

# コンポーネント一覧
sudo /greengrass/v2/bin/greengrass-cli component list

# デプロイメント状態
sudo /greengrass/v2/bin/greengrass-cli deployment list
```

### ログ確認
```bash
# セットアップログ
tail -f ~/greengrass-setup.log

# Greengrassメインログ
sudo tail -f /greengrass/v2/logs/greengrass.log

# システムログ
sudo journalctl -u greengrass -f

# 全ログファイル一覧
sudo find /greengrass/v2/logs/ -name "*.log" -type f
```

## 完全リセット手順

問題が解決しない場合の完全リセット：

```bash
# 1. Greengrassサービス停止
sudo systemctl stop greengrass
sudo systemctl disable greengrass

# 2. ファイル削除
sudo rm -rf /greengrass/v2/*
rm -rf ~/greengrass/

# 3. ユーザー削除
sudo userdel ggc_user
sudo groupdel ggc_group

# 4. AWS リソース削除（必要に応じて）
# Thing削除: aws iot delete-thing --thing-name [Thing名]
# 証明書削除: aws iot delete-certificate --certificate-id [証明書ID]

# 5. 再セットアップ
# セットアップスクリプトを再実行
```

## サポート情報

### 公式ドキュメント
- [AWS IoT Greengrass トラブルシューティング](https://docs.aws.amazon.com/greengrass/v2/developerguide/troubleshooting.html)
- [Raspberry Pi OS ドキュメント](https://www.raspberrypi.org/documentation/)

### コミュニティサポート
- [AWS re:Post](https://repost.aws/)
- [Raspberry Pi フォーラム](https://www.raspberrypi.org/forums/)

### ログ提出時の情報

問題報告時は以下の情報を含めてください：

1. **環境情報**
   - Raspberry Pi モデル
   - OS バージョン (`cat /etc/os-release`)
   - 実行したコマンド

2. **エラー情報**
   - エラーメッセージ
   - セットアップログ (`~/greengrass-setup.log`)
   - Greengrassログ (`/greengrass/v2/logs/greengrass.log`)

3. **システム状態**
   - サービス状態 (`sudo systemctl status greengrass`)
   - リソース使用量 (`free -h`, `df -h`)