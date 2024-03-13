---
title: 不常见问题
tags:
  - docker
created: 2023-08-25T19:33:15+08:00
updated: 2023-08-31T19:52:15+08:00
---

## 修改宿主机 hosts

1. 编辑 /etc/hosts
2. 执行 sudo killall -HUP mDNSResponder 刷新缓存
3. 可能需要重启 service docker restart

   1. 如果刷新缓存报错则执行 /etc/init.d/network restart 使修改生效
   2. 重启 service docker restart
   3. 不重启则外网访问 Docker 部署的 Nginx 等服务失败，宿主机 `$ curl http://localhost` 可以成功

## crontab

1. 指定用户执行：crontab -u www-data -e
2. 到容器里执行 /usr/sbin/crond -b 启动服务
3. 可以把配置文件，比如 www-data 命名的文件映射到容器的 /etc/crontabs/ 下
