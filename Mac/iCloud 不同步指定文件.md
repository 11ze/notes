---
title: iCloud 不同步指定文件
created: 2023-05-12T14:28:08+08:00
tags:
  - iCloud
updated: 2023-08-22T23:19:56+08:00
---

## 说明

iCloud 不同步带有 .nosync 后缀的文件和文件夹

## 使用场景

### 在 iCloud 中忽略 .git 且 Git 命令可以正常使用

```bash
cd repo
mv .git .git.nosync
ln -s .git.nosync .git
```
