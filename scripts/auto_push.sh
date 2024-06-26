#!/bin/bash

# 在 crontab 中配置定时任务，如每天 23 点执行一次
# 0 23 * * * cd "$dirname" && ./auto_push.sh

# 可能遇到的问题：https://itprohelper.com/how-to-fix-cron-operation-not-permitted-error-in-macos/

if [ -f "update_updated.sh" ]; then
   ./update_updated.sh
fi

if [ -f "update_title.sh" ]; then
   ./update_title.sh
fi

cd ..

logFile="scripts/auto_push.log"
currentTime=$(date +"%Y-%m-%dT%H:%M:%S+08:00")

echo $currentTime >> $logFile

git pull >> $logFile 2>&1
git add . >> $logFile 2>&1
git commit -m "docs: auto push" >> $logFile 2>&1
git push >> $logFile 2>&1

echo "" >> $logFile
