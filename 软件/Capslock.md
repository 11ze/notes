---
title: Capslock
created: 2023-05-12T01:11:06+08:00
tags:
  - 软件
  - 工具
  - Mac
updated: 2024-01-09T18:09:00+08:00
---

## 功能

- 加强 Caps 键功能

## 安装

- [Github](https://github.com/Vonng/Capslock)
- 到系统设置 - 键盘 - 键盘快捷键 - Modifier Keys 里选择键盘
## 单击 Caps 切换输入法

- 打开配置文件 `~/.config/karabiner/karabiner.json`
- 做如下修改：
  - 找到 `caps_lock` 的 `to_if_alone`
  - 将 `key_code` 改成 `caps_lock`
  - 找到 `spacebar = language switch`
  - 删除所在 `{}` 代码块
