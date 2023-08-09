---
title: iCloud 同步卡住
createdAt: 2023-05-08T00:00:00+08:00
tags:
- Mac
- iCloud
---

## 解决方案

1. ~/.zshrc

    ```bash
    # ~/.zshrc
    alias killicloud='killall bird && killall cloudd'
    ```

2. 终端执行命令 kill iCloud 进程

    ```bash
    killicloud
    ```

3. 点击访达侧边栏的 iCloud ，观察同步进度，若还是卡住，继续 kill iCloud 进程直到正常

   - ![iCloud-sync-failed.png](https://cdn.jsdelivr.net/gh/11ze/static/images/iCloud-sync-failed.png)
   - ![iCloud-sync-stuck.png](https://cdn.jsdelivr.net/gh/11ze/static/images/iCloud-sync-stuck.png)

4. 每小时执行一次确保 iCloud 同步

    ```bash
    $ crontab -e
    0 * * * * killall bird && killall cloudd # 每小时 kill 一次 iCloud 进程
    ```

## 参考

- [一日一技 | Mac 上 iCloud 云盘同步卡住了？可以试试这样做](https://sspai.com/post/72882)
