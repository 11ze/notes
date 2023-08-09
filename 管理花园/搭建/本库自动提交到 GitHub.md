---
title: 本库自动提交到 GitHub
createdAt: 2023-05-13T14:19:34+08:00
tags:
- 搭建
---

- 配置 crontab 每天自动执行 [auto_push.sh](https://github.com/11ze/knowledge-garden/blob/main/auto_push.sh)
  - 可能遇到的问题：[[Crontab 执行提示没有权限]]
- 由于已配置 GitHub Action，自动提交后会触发 Action 自动部署网站
