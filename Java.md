---
title: Java
tags:
  - Java
  - 资料
created: 2024-01-21T22:23:22+08:00
updated: 2024-05-30T23:00:00+08:00
---

## 资料

- [安装 JDK 教程](https://javabetter.cn/overview/jdk-install-config.html)
- [官网下载](https://www.oracle.com/java/technologies/downloads/)
- [路线图](https://roadmap.sh/java)
- [语法基础](https://javabetter.cn/basic-extra-meal/48-keywords.html)

## 问题

### 卸载任一 JDK 后 IDEA 报错

- 错误信息如：
  - nice: /Library/Java/JavaVirtualMachines/zulu-18.jdk/Contents/Home/bin/java: No such file or directory
- 修复：
  - 退出 IDEA
  - 修改 ~/Library/Application\ Support/JetBrains/IntelliJIdea2023.3/options/jdk.table.xml，移除被卸载的 JDK
