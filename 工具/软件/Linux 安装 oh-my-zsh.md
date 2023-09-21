---
title: Linux 安装 oh-my-zsh
created: 2023-05-12T01:11:06+08:00
tags:
  - Linux
  - zsh
updated: 2023-09-21T16:08:56+08:00
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
- 若安装时遇到网络问题
  - 可以手动下载 ohmyzsh 仓库文件重命名为 ~/.oh-my-zsh
  - 删除 install 脚本里的 setup_ohmyzsh() 和执行方法
  - 删除 `if [ -d "$ZSH" ]; then` 块
  - 最后手动执行 sh -c install.sh

## 插件

- git clone 到 .oh-my-zsh/custom/plugins
  - <https://github.com/zsh-users/zsh-syntax-highlighting.git>
  - <https://github.com/zsh-users/zsh-autosuggestions.git>
- autojump
  - Ubuntu：sudo apt install autojump
  - Centos：yum install autojump-zsh
- 修改 ~/.zshrc 文件的内容
  - `plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting)`
