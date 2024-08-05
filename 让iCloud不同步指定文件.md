---
title: 让iCloud不同步指定文件
created: 2023-05-12T14:28:08+08:00
tags:
  - iCloud
  - Mac
updated: 2024-08-05T23:00:01+08:00
---

## 说明

- iCloud 不会同步带有 .nosync 后缀的文件和文件夹

## 使用场景

### 在 iCloud 中不同步 .git 文件夹，git 命令可以正常使用

```bash
mv .git .git.nosync
ln -s .git.nosync .git
```
