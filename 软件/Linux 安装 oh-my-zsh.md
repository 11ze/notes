---
title: Linux 安装 oh-my-zsh
created: 2023-05-12T01:11:06+08:00
tags:
  - Linux
  - zsh
updated: 2023-12-27T10:47:54+08:00
---

## 安装 Zsh

- <https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH>

  ```shell
  sudo apt install zsh

  # 查看所有可用 shell
  chsh -l

  # 将终端默认 shell 切换到 zsh，后面要输入实际看到的 zsh 路径
  chsh -s /bin/zsh

  # 新开一个终端确认是否切换成功
  echo $SHELL
  ```

## 安装 Oh-my-zsh

- <https://ohmyz.sh/#install>
- 若安装时遇到网络问题则 [[GitHub 加速访问]]

## 插件

- git clone 到 .oh-my-zsh/custom/plugins
  - <https://github.com/zsh-users/zsh-syntax-highlighting.git>
  - <https://github.com/zsh-users/zsh-autosuggestions.git>
- autojump
  - Ubuntu：sudo apt install autojump
  - Centos：yum install autojump-zsh
- 修改 ~/.zshrc 文件的内容
  - `plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting)`
