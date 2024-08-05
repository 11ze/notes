---
title: Linux安装oh-my-zsh
created: 2023-05-12T01:11:06+08:00
tags:
  - 软件
  - Linux
  - zsh
updated: 2024-08-05T23:00:01+08:00
---

- Mac 用户看：[[Mac安装oh-my-zsh]]

## 安装 zsh

- <https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH>

  ```shell
  # 查看系统已有 shell
  chsh -l

  # 如果没有 zsh
  sudo apt install zsh

  # 将终端默认 shell 切换到 zsh（输入 chsh -l 看到的路径）
  chsh -s /bin/zsh

  # 新开一个终端确认是否切换成功
  echo $SHELL
  ```

## 安装 oh-my-zsh

- 官网：<https://ohmyz.sh>
- 若安装时遇到网络问题：[[GitHub加速访问]]

## 安装插件

- git clone 到 .oh-my-zsh/custom/plugins
  - <https://github.com/zsh-users/zsh-syntax-highlighting.git>
  - <https://github.com/zsh-users/zsh-autosuggestions.git>
- autojump
  - Ubuntu：sudo apt install autojump
  - Centos：yum install autojump-zsh
- 到 ~/.zshrc 文件启用插件
  - `plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting)`
