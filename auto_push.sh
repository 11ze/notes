#!/bin/bash

# 说明：
#   请在 crontab 中配置定时任务，例如每 8 小时执行一次
#     * */8 * * * cd "dirname" && ./auto_push.sh
#   执行日志请在脚本同目录下查看 auto_push.log

# 代理，可修改或删除
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890

timestamp=$(date "+%Y-%m-%d %H:%M:%S")

echo "==== $timestamp ====" >> auto_push.log

echo "$ git pull:" >> auto_push.log
git pull >> auto_push.log 2>&1

# echo "$ git add ." >> auto_push.log
git add . >> auto_push.log 2>&1

# echo "$ git commit" >> auto_push.log
git commit -m "docs: aotu commit" >> auto_push.log 2>&1

# echo "$ git push" >> auto_push.log
git push >> auto_push.log 2>&1

echo "Git operations completed." >> auto_push.log
