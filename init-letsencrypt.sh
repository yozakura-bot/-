#!/bin/bash

# Let's Encrypt初期化スクリプト
# このスクリプトはSSL証明書を初期化します

# エラー時に停止
set -e

# ドメイン名とメールアドレス
domains=(api.yukkurinet.com)
email="admin@yukkurinet.com"  # 有効なメールアドレスに変更してください
staging=0  # 本番環境の場合は0、テスト環境の場合は1

# 必要なディレクトリを作成
mkdir -p ./certbot/conf/live/api.yukkurinet.com
mkdir -p ./nginx/ssl

# DHパラメータを生成（セキュリティ強化のため）
if [ ! -f ./nginx/ssl/dhparam.pem ]; then
  echo "DHパラメータを生成しています..."
  openssl dhparam -out ./nginx/ssl/dhparam.pem 2048
fi

# 自己署名証明書を作成（初期設定用）
if [ ! -f ./certbot/conf/live/api.yukkurinet.com/privkey.pem ]; then
  echo "自己署名証明書を作成しています..."
  openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
    -keyout ./certbot/conf/live/api.yukkurinet.com/privkey.pem \
    -out ./certbot/conf/live/api.yukkurinet.com/fullchain.pem \
    -subj "/CN=api.yukkurinet.com"
fi

# Dockerコンテナを起動
echo "Dockerコンテナを起動しています..."
docker-compose up -d nginx

# 証明書を取得
echo "Let's Encrypt証明書を取得しています..."
for domain in "${domains[@]}"; do
  docker-compose run --rm certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email $email \
    --agree-tos \
    --no-eff-email \
    ${staging:+"--staging"} \
    -d $domain
done

# Nginxを再起動して新しい証明書を適用
echo "Nginxを再起動しています..."
docker-compose restart nginx

echo "初期化が完了しました！"
echo "証明書は自動的に更新されます。"