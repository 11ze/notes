---
title: Oh My Zsh
createdAt: 2023-05-11T00:00:00+08:00
tags:
- 工具
- 软件
---

Linux 用户请看：[[Linux 安装 oh-my-zsh]]

## 安装

1. 切换到系统自带的 Zsh：`chsh -s /bin/zsh`
2. [Oh My Zsh](https://ohmyz.sh/)

## 系统终端的配色方案

1. [Powerlevel10k](https://github.com/romkatv/powerlevel10k#getting-started)
2. 下载

     ```bash
     cd ~/Downloads
     git clone git://github.com/altercation/solarized.git
     ```

3. 打开终端，按「⌘ + ,」打开终端偏好设置，点击「描述文件 > ⚙︎⌄ > 导入」，选择「osx-terminal…ors-solarized/xterm 256 color」

## 插件

  ```bash
  brew install autojump
  brew install zsh-syntax-highlighting
  brew install zsh-autosuggestions

  # 添加以下内容到 .zshrc 文件末尾（上面三条命令运行结束会有提示）

  # zsh plugins
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  [ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
  HIST_STAMPS="mm/dd/yyyy"
  ```
