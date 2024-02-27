---
title: Oh My Zsh
created: 2023-05-12T01:11:06+08:00
tags:
  - 工具
  - 软件
updated: 2024-02-04T10:54:00+08:00
---

- Linux 用户看：[[Linux 安装 oh-my-zsh]]
- Mac 用户往下看

## 安装

1. 切换到系统自带的 Zsh：`chsh -s /bin/zsh`
2. [Oh My Zsh](https://ohmyz.sh/)

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

## 美化

1. 安装 [Powerlevel10k](https://github.com/romkatv/powerlevel10k#getting-started)
2. 下载配色方案

     ```bash
     cd ~/Downloads
     git clone https://github.com/altercation/solarized.git
     ```

3. 打开终端，按「⌘ + ,」打开终端偏好设置，点击「描述文件 > ⚙︎⌄ > 导入」，选择「osx-terminal…ors-solarized/xterm 256 color」
4. 能在 iTerm2 生效
  1. 如果安装了 p10k，执行一次 p10k configure 可以触发字体安装选项
