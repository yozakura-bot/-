#!/bin/bash
# 百鬼異世界（Hyakki Isekai）バックエンドデプロイスクリプト

# エラーが発生した場合にスクリプトを停止
set -e

echo "===== 百鬼異世界バックエンドデプロイを開始します ====="
echo "$(date)"

# 作業ディレクトリに移動
cd "$(dirname "$0")"

# 環境変数ファイルの存在確認
if [ ! -f .env.production ]; then
    echo "エラー: .env.production ファイルが見つかりません。"
    exit 1
fi

# 依存関係のインストール
echo "依存関係をインストールしています..."
npm install

# アプリケーションのビルド
echo "アプリケーションをビルドしています..."
npm run build

# PM2がインストールされているか確認
if ! command -v pm2 &> /dev/null; then
    echo "PM2をインストールしています..."
    npm install -g pm2
fi

# アプリケーションが既に実行中かチェック
if pm2 list | grep -q "hyakki-isekai"; then
    echo "既存のアプリケーションを再起動しています..."
    pm2 restart hyakki-isekai
else
    echo "アプリケーションを起動しています..."
    pm2 start server/index.js --name "hyakki-isekai" --env production
    
    # 起動時に自動的に開始するように設定
    echo "PM2の起動設定を保存しています..."
    pm2 save
fi

# Nginxが存在するか確認
if command -v nginx &> /dev/null; then
    echo "Nginx設定をテストしています..."
    sudo nginx -t
    
    if [ $? -eq 0 ]; then
        echo "Nginxを再起動しています..."
        sudo systemctl restart nginx
    else
        echo "警告: Nginx設定にエラーがあります。手動で確認してください。"
    fi
else
    echo "警告: Nginxがインストールされていません。リバースプロキシが必要な場合はインストールしてください。"
fi

echo "===== デプロイが完了しました ====="
echo "アプリケーションの状態:"
pm2 status hyakki-isekai

echo ""
echo "次のコマンドでログを確認できます: pm2 logs hyakki-isekai"
echo ""