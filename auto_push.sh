#!/bin/bash

# 说明：
# 请在 crontab 中配置定时任务，例如每天 23 点执行一次
#   0 23 * * * cd "dirname" && ./auto_push.sh
# 请在脚本同目录下查看执行日志 auto_push.log
# 使用此脚本需要使用 git 格式的远程库链接，且已经配置好 ssh key
#   git remote set-url origin git@github...
# 可能遇到的问题：https://itprohelper.com/how-to-fix-cron-operation-not-permitted-error-in-macos/

# 代理，可修改或删除
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890

timestamp=$(date "+%Y-%m-%d %H:%M:%S")

echo "==== $timestamp ====" >> auto_push.log

echo "$ git pull:" >> auto_push.log
git pull >> auto_push.log 2>&1

# echo "$ git add ." >> auto_push.log
git add . >> auto_push.log 2>&1

# echo "$ git commit" >> auto_push.log
git commit -m "docs: auto push to GitHub" >> auto_push.log 2>&1

# echo "$ git push" >> auto_push.log
git push >> auto_push.log 2>&1

echo "Git operations completed." >> auto_push.log
