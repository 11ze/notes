---
title: Mac应用已损坏
tags:
  - Mac
created: 2023-05-26T15:58:43+08:00
updated: 2024-08-05T23:00:01+08:00
---

- 安装后打开提示已损坏时执行命令：`sudo xattr -d com.apple.quarantine "/Applications/{appName}.app"`
- 可能还需要到系统设置 - 隐私与安全下方允许运行应用