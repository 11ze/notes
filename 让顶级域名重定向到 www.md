---
title: 让顶级域名重定向到 www
tags:
  - 域名
  - Cloudflare
created: 2024-05-04T00:15:14+08:00
updated: 2024-05-07T16:24:01+08:00
---

## 重定向到 www 的好处

- 顶级域名的 Cookies 会发送到所有二级域名，二级域名则不会发送到其他二级域名，这在需要分开管理 Cookies 时很有用。
- 加上重定向后可以在任意地方使用简洁的域名。
- 添加重定向后对于搜索引擎来说是同一个站点。

## Cloudflare 设置方法

- ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/20240503234218.png)
- 如果网址打不开，试试添加 DNS 解析到 192.0.2.1

## 参考文章

- [Single Redirects — Example rules · Cloudflare Rules docs](https://developers.cloudflare.com/rules/url-forwarding/single-redirects/examples/#redirect-all-requests-to-a-different-hostname)
- [网站域名带www和不带有什么区别？ - luch的博客](https://www.quanzhan.co/archives/159)
- [域名www，要还是不要，这是个问题-51CTO.COM](https://www.51cto.com/article/610753.html)
