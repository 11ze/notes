---
title: 配置 Google Analytics
createdAt: 2023-05-13T18:35:42+08:00
tags:
- 搭建
- Google
---

## 配置方法

1. 到 [Google Analytics（分析）](https://marketingplatform.google.com/about/analytics/) 创建一个媒体资源并获取 ID
   1. ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/google-analytics-1.png)
2. 打开发布仓库根目录下的 `config.toml` 文件
3. 写入：`googleAnalytics = "G-XXX"`
4. 打开发布仓库的 `layouts/partials/header.html` 文件
5. 在末尾写入：`{{ template "_internal/google_analytics.html" . }}`

## 参考文章

- [Google Analytics | Hugo](https://gohugo.io/templates/internal/#google-analytics)
