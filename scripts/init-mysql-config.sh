#!/bin/bash

# 設定ファイルのパス
CONFIG_FILE="~/.my.cnf"

# 設定を書き込む内容
CONFIG_CONTENT="
[mysqld]
slow_query_log = 1
slow_query_log_file = \"/var/log/mysql/slow-query.log\"
long_query_time = 0
max_connections = 2000
wait_timeout = 120
interactive_timeout = 600
"

# 設定内容をファイルに追加（ファイルがなければ新たに作成）
echo "$CONFIG_CONTENT" > "$CONFIG_FILE"

