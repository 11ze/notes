---
title: iCloud 不同步指定文件
publishDate: 2023-05-12
lastmod: 2023-05-12
tags:
- iCloud
---

## 说明

iCloud 不同步带有 .nosync 后缀的文件和文件夹，适用于 git 仓库

## 使用场景

### 在 iCloud 中同步本地 Git 仓库

```bash
cd repo
mv .git .git.nosync
ln -s .git.nosync .git
```
