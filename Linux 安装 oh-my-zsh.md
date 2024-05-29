---
title: Linux 安装 oh-my-zsh
created: 2023-05-12T01:11:06+08:00
tags:
  - Linux
  - zsh
updated: 2024-05-29T23:00:01+08:00
---
## 安装 Zsh

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

- 安装：<https://ohmyz.sh/#install>
- 若安装时遇到网络问题：[[GitHub 加速访问]]

## 插件

- git clone 到 .oh-my-zsh/custom/plugins
  - <https://github.com/zsh-users/zsh-syntax-highlighting.git>
  - <https://github.com/zsh-users/zsh-autosuggestions.git>
- autojump
  - Ubuntu：sudo apt install autojump
  - Centos：yum install autojump-zsh
- 到 ~/.zshrc 文件启用插件
  - `plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting)`
