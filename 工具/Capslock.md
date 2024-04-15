---
title: Capslock
created: 2023-05-12T01:11:06+08:00
tags:
  - 软件
  - 工具
  - Mac
updated: 2024-04-15T14:25:00+08:00
---

## 功能

- 加强 Caps 键功能

## 安装

- [Github](https://github.com/Vonng/Capslock)
- 到系统设置 - 键盘 - 键盘快捷键 - Modifier Keys 里选择键盘

## 设置单击 Caps 切换输入法

- 打开配置文件 `~/.config/karabiner/karabiner.json`
- 搜 `"key_code": "spacebar"`
- 将 `to_if_alone` 值改成 `caps_lock`
