---
title: iCloud 同步卡住
created: 2023-05-12T01:11:06+08:00
tags:
  - Mac
  - iCloud
updated: 2024-01-23T12:34:01+08:00
---

## 解决方案

1. 终端执行命令 kill iCloud 进程

    ```bash
    killall bird && killall cloudd
    ```

2. 点击访达侧边栏的 iCloud ，观察同步进度，若还是卡住，继续 kill iCloud 进程直到正常

   - ![iCloud-sync-failed.png](https://cdn.jsdelivr.net/gh/11ze/static/images/iCloud-sync-failed.png)
   - ![iCloud-sync-stuck.png](https://cdn.jsdelivr.net/gh/11ze/static/images/iCloud-sync-stuck.png)

3. 每 10 分钟执行一次确保 iCloud 正常同步

    ```bash
    $ crontab -e
    */10 * * * * killall bird && killall cloudd # kill iCloud 进程
    ```

## 参考

- [一日一技 | Mac 上 iCloud 云盘同步卡住了？可以试试这样做](https://sspai.com/post/72882)
