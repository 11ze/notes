---
title: Egg.js手动热更新
tags:
  - 热更新
  - Egg.js
  - Node.js
created: 2023-08-19T11:12:06+08:00
updated: 2024-08-05T23:00:01+08:00
---

package.json

```json
{
  "scripts": {
    "start": "egg-scripts start --daemon --title=egg-server",
    "stop": "egg-scripts stop --daemon --title=egg-server",
    "start-tmp": "egg-scripts start --daemon --title=egg-tmp-server --port=7002",
    "stop-tmp": "egg-scripts stop --daemon --title=egg-tmp-server --port=7002"
  }
}
```

1. 正常启动时 `npm run build && npm run start`，在 Nginx 里反代到 7001 端口
2. 需要热更新时，`npm run start-tmp`，在 Nginx 里反代到 7002 端口（`service nginx reload`）
3. 重启 7001 端口上的服务，在 Nginx 里反代回 7001 端口
4. `npm run start-tmp` 关闭 7002 端口的服务
