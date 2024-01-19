---
title: Java 小问题
tags:
  - Java
created: 2024-01-19T12:21:44+08:00
updated: 2024-01-19T12:21:44+08:00
---
## 卸载任一 JDK 后 IDEA 报错

- 错误信息如：
  - nice: /Library/Java/JavaVirtualMachines/zulu-18.jdk/Contents/Home/bin/java: No such file or directory
- 修复：
  - 退出 IDEA
  - 修改 ~/Library/Application\ Support/JetBrains/IntelliJIdea2023.3/options/jdk.table.xml，移除被卸载的 JDK
