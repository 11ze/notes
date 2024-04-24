---
title: GitHub 常见错误
created: 2023-05-12T01:11:06+08:00
tags:
  - Git
  - GitHub
updated: 2024-04-24T14:42:00+08:00
---

## Connection Closed by x.x.x.x Port 22

添加以下代码到 `~/.ssh/config`

```bash
Host github.com
  HostName ssh.github.com
  User $username
  Port 443
```
