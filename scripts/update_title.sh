#!/bin/bash

# 每个 md 文件的元属性都有一个 title，这个脚本用于更新 title，值为没有路径和后缀的文件名

logFile="scripts/update_title.log"

cd ..

# 执行 find 命令并遍历结果，忽略 .trash 目录、README.md、index.md
find . -not -path "./.trash/*" -not -path "./README.md" -not -path "./index.md" -name "*.md" | while read -r filePath; do
    # 使用 basename 命令获取文件名
    filename=$(basename "$filePath")

    # 使用 awk 命令获取最后一个/后面的内容，然后去除.md扩展名
    lastPart=$(echo "$filename" | awk -F'/' '{print $NF}' | sed 's/\.md$//')

    # 检查文件中是否存在 title 元属性
    if grep -q "title:" "$filePath"; then
        # 获取文件中的 title 元属性值
        title=$(grep "title:" "$filePath" | sed 's/title: //')

        # 比较 title 元属性值和文件名
        if [ "$title" != "$lastPart" ]; then
            # 替换 title 元属性值为文件名
            sed -i '' "s/title: $title/title: $lastPart/" "$filePath"
            echo "更新 title：[$title] -> [$lastPart] | $filePath" >> $logFile
        fi
    else
        # 如果文件中不存在 title 元属性，则插入一个
        sed -i '' "2s/^/title: $lastPart\n/" "$filePath"
        echo "添加 title：$filePath" >> $logFile
    fi
done
