#!/bin/bash

# モニタリングスクリプト
# このスクリプトはサーバーの状態を監視し、レポートを生成します

# 出力ファイル
OUTPUT_FILE="server_status_$(date +"%Y%m%d").txt"

echo "===== サーバーステータスレポート =====" > $OUTPUT_FILE
echo "日時: $(date)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# システム情報
echo "--- システム情報 ---" >> $OUTPUT_FILE
echo "ホスト名: $(hostname)" >> $OUTPUT_FILE
echo "カーネル: $(uname -r)" >> $OUTPUT_FILE
echo "稼働時間: $(uptime -p)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# CPU使用率
echo "--- CPU使用率 ---" >> $OUTPUT_FILE
top -bn1 | grep "Cpu(s)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# メモリ使用率
echo "--- メモリ使用率 ---" >> $OUTPUT_FILE
free -h >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# ディスク使用率
echo "--- ディスク使用率 ---" >> $OUTPUT_FILE
df -h >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# PM2プロセス
echo "--- PM2プロセス ---" >> $OUTPUT_FILE
pm2 status >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Nginxステータス
echo "--- Nginxステータス ---" >> $OUTPUT_FILE
systemctl status nginx | grep Active >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Redisステータス
echo "--- Redisステータス ---" >> $OUTPUT_FILE
systemctl status redis-server | grep Active >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# アプリケーションログ（最新10行）
echo "--- アプリケーションログ（最新10行） ---" >> $OUTPUT_FILE
tail -n 10 logs/combined.log >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# エラーログ（最新10行）
echo "--- エラーログ（最新10行） ---" >> $OUTPUT_FILE
tail -n 10 logs/error.log >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "レポートが生成されました: $OUTPUT_FILE"

# メール通知（オプション）
# mail -s "サーバーステータスレポート $(date +"%Y-%m-%d")" admin@yukkurinet.com < $OUTPUT_FILE