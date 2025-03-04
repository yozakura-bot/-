#!/bin/bash
# 百鬼異世界（Hyakki Isekai）SSL証明書更新スクリプト

# エラーが発生した場合にスクリプトを停止
set -e

# ログファイルの設定
LOG_FILE="/var/log/ssl-renewal.log"
DOMAIN="api.yukkurinet.com"

echo "===== SSL証明書の更新を開始します ====="
echo "$(date)"
echo "===== SSL証明書の更新を開始します - $(date)" >> $LOG_FILE

# Certbotがインストールされているか確認
if ! command -v certbot &> /dev/null; then
    echo "エラー: Certbotがインストールされていません。"
    echo "エラー: Certbotがインストールされていません - $(date)" >> $LOG_FILE
    echo "sudo apt-get update && sudo apt-get install certbot を実行してインストールしてください。"
    exit 1
fi

# Nginxが実行中の場合は一時的に停止
if command -v nginx &> /dev/null && systemctl is-active --quiet nginx; then
    echo "Nginxを一時的に停止しています..."
    echo "Nginxを一時的に停止しています - $(date)" >> $LOG_FILE
    sudo systemctl stop nginx
fi

# 証明書の更新
echo "証明書を更新しています..."
echo "証明書を更新しています - $(date)" >> $LOG_FILE

# 証明書の更新を試みる
certbot renew --quiet

# 更新の結果を確認
if [ $? -eq 0 ]; then
    echo "証明書の更新に成功しました。"
    echo "証明書の更新に成功しました - $(date)" >> $LOG_FILE
else
    echo "証明書の更新中にエラーが発生しました。"
    echo "証明書の更新中にエラーが発生しました - $(date)" >> $LOG_FILE
fi

# 証明書の有効期限を確認
echo "証明書の状態:"
echo "証明書の状態 - $(date)" >> $LOG_FILE
certbot certificates | grep "Expiry Date" | tee -a $LOG_FILE

# Nginxを再起動
if command -v nginx &> /dev/null; then
    echo "Nginxを再起動しています..."
    echo "Nginxを再起動しています - $(date)" >> $LOG_FILE
    sudo systemctl start nginx
    
    # Nginx設定をテスト
    nginx -t >> $LOG_FILE 2>&1
    if [ $? -eq 0 ]; then
        echo "Nginx設定は正常です。"
        echo "Nginx設定は正常です - $(date)" >> $LOG_FILE
    else
        echo "警告: Nginx設定にエラーがあります。"
        echo "警告: Nginx設定にエラーがあります - $(date)" >> $LOG_FILE
    fi
fi

# アプリケーションを再起動
if command -v pm2 &> /dev/null; then
    echo "アプリケーションを再起動しています..."
    echo "アプリケーションを再起動しています - $(date)" >> $LOG_FILE
    pm2 restart hyakki-isekai
    
    # アプリケーションの状態を確認
    pm2 status hyakki-isekai >> $LOG_FILE
fi

echo "===== SSL証明書の更新が完了しました ====="
echo "===== SSL証明書の更新が完了しました - $(date)" >> $LOG_FILE
echo ""