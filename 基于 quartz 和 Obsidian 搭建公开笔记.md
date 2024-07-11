---
title: 基于 quartz 和 Obsidian 搭建公开笔记
created: 2023-05-12T19:46:22+08:00
updated: 2024-07-11T23:00:06+08:00
tags:
  - 笔记
  - 第二大脑
---

## 同步方案

### 可选方案

- Obsidian Sync：官方，付费
- Remotely Sync：Obsidian 的第三方插件，可以自动和手动同步，免费
- iCloud：实时同步，免费

### 我使用的同步方案 iCloud

1. iPhone 安装 Obsidian
2. 进入 Obsidian 创建一个打开 iCloud 同步功能的 Vault
   1. ![sync-create-new-vault](https://cdn.jsdelivr.net/gh/11ze/static/images/sync-create-new-vault.png)
3. 此时 iCloud 中会生成 Vault 目录
   1. ![sync-created-vault](https://cdn.jsdelivr.net/gh/11ze/static/images/sync-created-vault.png)
4. MacBook 安装 Obsidian，打开目录
5. 完成

## 发布方案

- Fork [quartz](https://github.com/jackyzha0/quartz) 仓库
- 笔记位置：content/
- content 内容的生成方式三选一
  - 把笔记仓库作为发布仓库的 submodule。
  - 在 GitHub Action 里 git clone 笔记仓库。
  - 在发布仓库的 content/ 文件夹写文章，不推荐。

## 部署

### 基于 Cloudflare Pages 部署，2024-04-05

- [官方文档](https://developers.cloudflare.com/pages/framework-guides/deploy-anything/)
- 把域名转到 Cloudflare
- 在设置里配置自定义域名
- 仓库每次提交都会触发自动部署

### Vercel + Cloudflare（旧）

- [How to Use a Cloudflare Domain with Vercel](https://vercel.com/guides/using-cloudflare-with-vercel)
- ![custom-domain-vercel.png](https://cdn.jsdelivr.net/gh/11ze/static/images/custom-domain-vercel.png)
- ![custom-domains-cloudflare.png](https://cdn.jsdelivr.net/gh/11ze/static/images/custom-domains-cloudflare.png)
- ![custom-domains-cloudflare-ssl.png](https://cdn.jsdelivr.net/gh/11ze/static/images/custom-domains-cloudflare-ssl.png)
- 对于 quartz4，需要在 content 目录下放置 vercel.json，在点击 Wikilink 时自动添加 .html

    ```json
    {
      "routes": [
        { "handle": "filesystem" },
        { "src": "/(.*)", "dest": "/$1.html" }
      ]
    }
    ```

## 添加评论区

- 适用于 Quartz v4
- 到 [giscus](https://giscus.app/zh-CN) 生成评论区代码
- 创建组件 quartz/components/pages/Giscus.tsx

    ```JavaScript
    import { QuartzComponentConstructor } from "../types"

    function Content() {
      // 评论区代码
      return <script src="https://giscus.app/client.js"
        data-repo="11ze/notes"
        data-repo-id="xx"
        data-category="General"
        data-category-id="xx"
        data-mapping="title"
        data-strict="0"
        data-reactions-enabled="1"
        data-emit-metadata="0"
        data-input-position="bottom"
        data-theme="preferred_color_scheme"
        data-lang="zh-CN"
        crossorigin="anonymous"
        async>
      </script>
    }

    export default (() => Content) satisfies QuartzComponentConstructor
    ```

- 在 quartz/components/pages/index.ts 中导出
- quartz.layout.ts

  ```TypeScript
  export const defaultContentPageLayout: PageLayout = {
    right: [
      Component.Giscus(),
    ],
  }
  ```

## 配置图床

- 在 GitHub 创建图床仓库
- 到个人 Settings - Developer settings 创建 Personal access token 给 PicGo 用
- 安装 [PicGo](https://picgo.github.io/PicGo-Doc/zh/)
- ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/picgo-github-config.png)
- 在仓库名后拼接 `\@分支名` 可以指定要使用的仓库分支，如 `https://cdn.jsdelivr.net/gh/11ze/notes\@main/xx`
- 参考链接
- [使用 PicGo + Github + JSD 搭建免费图床](https://asuka4every.top/build-your-own-img-host/)
- [jsDelivr](https://www.jsdelivr.com/)

## 自动提交到 GitHub

- 在文档仓库根目录添加文件：[auto_push.sh](https://github.com/11ze/notes/blob/main/scripts/auto_push.sh)
- 配置 crontab 每天自动执行文档仓库的 auto_push.sh
  - [[Crontab 执行任务提示没有权限]]
- 我的文档仓库已配置 GitHub Action，自动提交后会触发发布仓库的 Github Action 自动部署网站
  - content 仓库 -> quartz repository 的 v4 分支 -> 生成网站内容到 quartz 仓库的 master 分支 -> Cloudflare 检测到 master 更新，自动部署 Pages

## 问题

### 发布笔记 404

- 原因一：笔记的元属性填写的日期的时区不对，GitHub Action 默认用 0 时区
  - 解决一：改用 ISO8601 的日期格式
  - 解决二：在 ci 里指定时区，未尝试

### [[解决 iCloud 同步卡住问题]]
