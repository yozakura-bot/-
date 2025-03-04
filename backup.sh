#!/bin/bash

# バックアップスクリプト
# このスクリプトはデータベースとアップロードされたファイルをバックアップします

# エラー時に停止
set -e

# バックアップディレクトリ
BACKUP_DIR="/var/backups/hyakki-api"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="$BACKUP_DIR/hyakki-api-$TIMESTAMP.tar.gz"

# バックアップディレクトリが存在しない場合は作成
mkdir -p $BACKUP_DIR

# アプリケーションディレクトリ
APP_DIR=$(pwd)

echo "===== バックアップを開始します ====="
echo "日時: $(date)"
echo "バックアップファイル: $BACKUP_FILE"
echo ""

# PM2プロセスのステータスを確認
echo "PM2プロセスのステータスを確認しています..."
pm2 status

# データベースとアップロードされたファイルをバックアップ
echo "データベースとアップロードされたファイルをバックアップしています..."
tar -czf $BACKUP_FILE -C $APP_DIR prisma/prod.db uploads/

# バックアップファイルのサイズを確認
BACKUP_SIZE=$(du -h $BACKUP_FILE | cut -f1)
echo "バックアップサイズ: $BACKUP_SIZE"

# 古いバックアップを削除（30日以上前のもの）
echo "古いバックアップを削除しています..."
find $BACKUP_DIR -name "hyakki-api-*.tar.gz" -type f -mtime +30 -delete

# バックアップの一覧を表示
echo "バックアップの一覧:"
ls -lh $BACKUP_DIR | grep "hyakki-api-"

echo ""
echo "===== バックアップが完了しました ====="
echo "バックアップを復元するには:"
echo "1. tar -xzf $BACKUP_FILE -C /path/to/restore"
echo "2. アプリケーションを再起動: pm2 restart hyakki-api"