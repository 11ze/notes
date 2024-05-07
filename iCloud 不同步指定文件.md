---
title: iCloud 不同步指定文件
created: 2023-05-12T14:28:08+08:00
tags:
  - iCloud
  - Mac
updated: 2024-05-07T16:24:01+08:00
---

## 说明

iCloud 不会同步带有 .nosync 后缀的文件和文件夹

## 使用场景

### 在 iCloud 中忽略 .git 且 git 命令可以正常使用

```bash
cd repo
mv .git .git.nosync
ln -s .git.nosync .git
```
