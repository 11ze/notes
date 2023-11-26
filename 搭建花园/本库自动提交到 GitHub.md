---
title: 本库自动提交到 GitHub
created: 2023-05-13T14:19:26+08:00
tags:
  - 搭建
updated: 2023-08-22T23:19:56+08:00
---

- 在文档仓库根目录添加文件：[auto_push.sh](https://github.com/11ze/knowledge-garden/blob/main/auto_push.sh)
- 配置 crontab 每天自动执行文档仓库的 auto_push.sh
  - [[Crontab 执行提示没有权限]]
- 由于文档仓库已配置 GitHub Action，自动提交后会触发发布仓库的 Github Action 自动部署网站
  - content submodule -> v4 of quartz repository -> master of quartz repository
