---
title: Mac 安装 oh-my-zsh
created: 2023-05-12T01:11:06+08:00
tags:
  - 工具
  - 软件
updated: 2024-05-30T23:06:27+08:00
---

- Linux 用户看：[[Linux 安装 oh-my-zsh]]

## 安装 zsh

- 切换到系统自带的 Zsh：`chsh -s /bin/zsh`

## 安装 oh-my-zsh

- 官网：<https://ohmyz.sh>
- 若安装时遇到网络问题：[[GitHub 加速访问]]

## 安装插件

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

1. 安装 [Powerlevel10k](https://github.com/romkatv/powerlevel10k#getting-started) 主题
2. 下载 [配色方案](https://github.com/altercation/solarized)
3. 打开 Terminal，Settings > Profiles > ⚙︎⌄ > Import > osx-terminal…ors-solarized/xterm 256 color
4. 每次应用配色方案后修改字体为 MesloLGS NF Regular
5. 能在 iTerm2 生效
  a. 执行 p10k configure 可以触发字体安装
  b. 自带有 Solarized Dark 配色
6. 2024-05-30：默认主题完全够用
