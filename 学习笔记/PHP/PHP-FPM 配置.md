---
title: PHP-FPM 配置
createdAt: 2023-05-11T00:00:00+08:00
tags:
- PHP
- php-fpm
---

以下内容适用于 IO 密集型应用

一个 PHP-FPM 进程大约占 30M 内存

- 进程数量
  - 计算公式：进程数 = 内存大小（M） * 0.6 / 30
  - 举例：`8G * 1024 * 0.6 / 30 = 163.84`
- `max_requests`
  - 每个进程重启前可以处理的请求数
  - 由 `pm.max_children` 的值和每秒的实际请求数量决定

参考文章

- [FastCGI 进程管理器（FPM）](https://www.php.net/manual/zh/install.fpm.php)
- [PHP-FPM tuning: Using ‘pm static’ for Max Performance](https://www.sitepoint.com/php-fpm-tuning-using-pm-static-max-performance/)（[译文](https://learnku.com/php/t/14952/php-fpm-tuning-use-pm-static-to-maximize-your-server-load-capability)）
- [PHP-FPM 配置](https://www.go365.tech/blog/4)
- [PHP-FPM 进程数设置多少合适](https://zhuanlan.zhihu.com/p/94627701)
