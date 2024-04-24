#!/bin/bash

# 说明：

# 请在 crontab 中配置定时任务，如每天 23 点执行一次
# 0 23 * * * cd "dirname" && ./auto_push.sh

# 可能遇到的问题：https://itprohelper.com/how-to-fix-cron-operation-not-permitted-error-in-macos/

timestamp=$(date "+%Y-%m-%d %H:%M:%S")

echo $timestamp >> auto_push.log

git pull >> auto_push.log 2>&1
git add . >> auto_push.log 2>&1
git commit -m "docs: auto update" >> auto_push.log 2>&1
git push >> auto_push.log 2>&1

echo "" >> auto_push.log
