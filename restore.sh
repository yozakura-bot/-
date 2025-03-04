#!/bin/bash

# リストアスクリプト
# このスクリプトはバックアップからデータを復元します

# エラー時に停止
set -e

# バックアップディレクトリ
BACKUP_DIR="/var/backups/hyakki-api"

# 利用可能なバックアップを表示
echo "利用可能なバックアップ:"
ls -lh $BACKUP_DIR | grep "hyakki-api-"

# バックアップファイルの選択
echo ""
echo "復元するバックアップファイル名を入力してください（例: hyakki-api-20250101-120000.tar.gz）:"
read BACKUP_FILE

# 入力されたファイルが存在するか確認
if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "エラー: 指定されたバックアップファイルが見つかりません。"
    exit 1
fi

# アプリケーションディレクトリ
APP_DIR=$(pwd)

echo "===== リストアを開始します ====="
echo "日時: $(date)"
echo "バックアップファイル: $BACKUP_DIR/$BACKUP_FILE"
echo ""

# PM2プロセスを停止
echo "アプリケーションを停止しています..."
pm2 stop hyakki-api

# 現在のデータベースとアップロードファイルをバックアップ
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
TEMP_BACKUP="$BACKUP_DIR/pre-restore-$TIMESTAMP.tar.gz"
echo "現在のデータを一時バックアップしています: $TEMP_BACKUP"
tar -czf $TEMP_BACKUP -C $APP_DIR prisma/prod.db uploads/

# バックアップから復元
echo "バックアップから復元しています..."
tar -xzf "$BACKUP_DIR/$BACKUP_FILE" -C $APP_DIR

# 所有者とパーミッションを修正
echo "所有者とパーミッションを修正しています..."
chown -R $(whoami):$(whoami) $APP_DIR/prisma $APP_DIR/uploads

# PM2プロセスを再起動
echo "アプリケーションを再起動しています..."
pm2 restart hyakki-api

# PM2プロセスのステータスを確認
echo "PM2プロセスのステータスを確認しています..."
pm2 status

echo ""
echo "===== リストアが完了しました ====="
echo "一時バックアップ: $TEMP_BACKUP"
echo "問題が発生した場合は、一時バックアップから復元できます。"