---
title: Linux 安装 oh-my-zsh
createdAt: 2023-05-11T00:00:00+08:00
tags:
- Linux
- zsh
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

## 插件

- git clone 到 .oh-my-zsh/custom/plugins
  - <https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md>
  - <https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh>
- autojump
  - Ubuntu：sudo apt install autojump
  - Centos：yum install aotojump-zsh
- 修改 ~/.zshrc 文件的内容
  - `plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting)`
