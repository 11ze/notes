---
title: 本库自动提交到 GitHub
created: 2023-05-13T14:19:26+08:00
tags:
  - 搭建
updated: 2024-04-15T12:56:00+08:00
---

- 在文档仓库根目录添加文件：[auto_push.sh](https://github.com/11ze/knowledge-garden/blob/main/auto_push.sh)
- 配置 crontab 每天自动执行文档仓库的 auto_push.sh
  - [[Crontab 执行提示没有权限]]
- 我的文档仓库已配置 GitHub Action，自动提交后会触发发布仓库的 Github Action 自动部署网站
  - content 仓库 -> quartz repository 的 v4 分支 -> 生成网站内容到 quartz 仓库的 master 分支 -> Cloudflare 检测到 master 更新，自动部署 Pages
