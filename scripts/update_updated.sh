#!/bin/bash

# 说明：

# 请在 crontab 中配置定时任务，如每分钟执行一次
# * * * * * cd "dirname" && ./modify_updated.sh

cd ..

logFile="scripts/update_updated.log"

current_time=$(date +"%Y-%m-%dT%H:%M:%S+08:00")

# 获取 git status 的输出
gitStatus=$(git status)

# 如果暂存区有 md 文件发生了更改，获取并打印所有更改的 md 文件的路径
if echo "$gitStatus" | grep -q ".md"; then

  # 循环打印每个文件名，可以另外处理每个文件名
  echo "$gitStatus" | grep -A1000 "Changes not staged for commit:" | grep ".md" | while read -r line; do
  filePath=$(echo "$line")

  filename=$(echo "$filePath" | awk -F': ' '{print $2}') # modified: xxx.md
  if [ -z "$filename" ]; then
    filename=$(echo "$filePath" )
  fi

  # 移除首位空格
  filename=$(echo "$filename" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  echo "filename: $filename"

  # 检查每个文件的前 10 行是否包含 "updated:" 字段
  if head -10 "$filename" | grep -q "updated:"; then
      # 使用 sed 命令将 "updated:" 之后的内容替换为当前时间
      echo "updated: $current_time $filename" >> $logFile
      sed -i -e "1,10s/\(updated: \).*/\1$current_time/" "$filename"

      # 删除 sed 命令生成的备份文件
      if [ -f "$filename-e" ]; then
        rm "$filename-e"
        git add "$filename"
      fi

  fi

  done
fi
