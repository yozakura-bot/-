#!/bin/bash
# 百鬼異世界（Hyakki Isekai）サーバーセットアップスクリプト

# エラーが発生した場合にスクリプトを停止
set -e

echo "===== 百鬼異世界サーバーセットアップを開始します ====="
echo "$(date)"

# rootユーザーで実行されているか確認
if [ "$(id -u)" -ne 0 ]; then
    echo "このスクリプトはroot権限で実行する必要があります。"
    echo "sudo ./setup-server.sh を実行してください。"
    exit 1
fi

# システムの更新
echo "システムを更新しています..."
apt-get update
apt-get upgrade -y

# 必要なパッケージのインストール
echo "必要なパッケージをインストールしています..."
apt-get install -y curl wget git build-essential nginx certbot python3-certbot-nginx ufw

# Node.js 18.xのインストール
echo "Node.js 18.xをインストールしています..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
    
    # バージョン確認
    node -v
    npm -v
else
    echo "Node.jsは既にインストールされています。"
    node -v
fi

# PM2のインストール
echo "PM2をインストールしています..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
else
    echo "PM2は既にインストールされています。"
fi

# ファイアウォールの設定
echo "ファイアウォールを設定しています..."
ufw allow ssh
ufw allow http
ufw allow https

# ファイアウォールが無効の場合は有効化
if ! ufw status | grep -q "Status: active"; then
    echo "ファイアウォールを有効化しています..."
    echo "y" | ufw enable
fi

ufw status

# Nginxの設定
echo "Nginxを設定しています..."
if [ ! -f /etc/nginx/sites-available/api.yukkurinet.com ]; then
    # 設定ファイルをコピー
    cp nginx-config.conf /etc/nginx/sites-available/api.yukkurinet.com
    
    # シンボリックリンクを作成
    ln -sf /etc/nginx/sites-available/api.yukkurinet.com /etc/nginx/sites-enabled/
    
    # デフォルト設定を無効化（オプション）
    rm -f /etc/nginx/sites-enabled/default
    
    # DHパラメータの生成（より強力な暗号化のため）
    if [ ! -f /etc/nginx/dhparam.pem ]; then
        echo "DHパラメータを生成しています（時間がかかる場合があります）..."
        openssl dhparam -out /etc/nginx/dhparam.pem 2048
    fi
    
    # Nginx設定のテスト
    nginx -t
    
    # Nginxを再起動
    systemctl restart nginx
else
    echo "Nginx設定ファイルは既に存在します。"
fi

# SSL証明書の取得
echo "SSL証明書を取得しています..."
if [ ! -d /etc/letsencrypt/live/api.yukkurinet.com ]; then
    certbot --nginx -d api.yukkurinet.com --non-interactive --agree-tos --email your-email@example.com
else
    echo "SSL証明書は既に存在します。"
    certbot certificates
fi

# SSL更新スクリプトの設定
echo "SSL更新スクリプトを設定しています..."
cp renew-ssl.sh /usr/local/bin/
chmod +x /usr/local/bin/renew-ssl.sh

# cronジョブの設定
if ! crontab -l | grep -q "renew-ssl.sh"; then
    echo "SSL更新用のcronジョブを設定しています..."
    (crontab -l 2>/dev/null; echo "0 0 1 * * /usr/local/bin/renew-ssl.sh") | crontab -
fi

echo "===== サーバーセットアップが完了しました ====="
echo "次のステップ:"
echo "1. .env.productionファイルを編集して環境変数を設定してください。"
echo "2. アプリケーションをデプロイするには ./deploy.sh を実行してください。"
echo ""