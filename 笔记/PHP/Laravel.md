---
title: Laravel
tags:
  - PHP
  - Laravel
created: 2023-11-20T15:28:44+08:00
updated: 2023-11-20T15:28:44+08:00
---
## 获取反代 IP

- Nginx

```Nginx
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Host $http_host;
```

- 设置中间件里的可信任列表

```PHP
# app/Http/Middleware/TrustProxies.php
protected $proxies = '*';
```

- 获取

```PHP
$request->ip();
```
