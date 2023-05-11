---
title: "Capslock"
date created: 2023-05-11
date modified: 2023-05-11
tags:
- tool
- 软件
- 工具
- Mac
---

## 功能

加强 Caps 键功能

## 安装

[Github](https://github.com/Vonng/Capslock)

## 单击 Caps 切换输入法

  - 打开配置文件 `~/.config/karabiner/karabiner.json`
  - 做如下修改：
    - 找到 `caps_lock` 的 `to_if_alone`
    - 将 `key_code` 改成 `caps_lock`
    - 找到 `spacebar = language switch`
    - 删除所在 `{}` 代码块
  - 目的：维持单点 Caps 切换输入法
