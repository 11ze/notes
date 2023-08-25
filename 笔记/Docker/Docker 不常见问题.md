---
title: 不常见问题
tags:
  - tag
created: 2023-08-25T19:33:15+08:00
updated: 2023-08-25T19:33:15+08:00
---

## 修改宿主机 hosts

1. 编辑 /etc/hosts
2. 执行 /etc/init.d/network restart 使修改生效
3. 重启 service docker restart
4. 不重启则外网访问 Docker 部署的 Nginx 等服务失败，宿主机 curl http://localhost 可以成功

## crontab

1. 到容器里执行 /usr/sbin/crond -b 启动服务
