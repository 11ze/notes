---
title: iCloud 同步卡住
publishDate: 2023-05-08
lastmod: 2023-05-08
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

2. kill iCloud 进程

```bash
# kill iCloud 进程
$ killicloud
```

3. 点击访达侧边栏的 iCloud ，观察同步进度，若还是卡住，继续 kill iCloud 进程直到正常
  - ![image.png](https://raw.githubusercontent.com/11ze/static/main/images/iCloud-sync-failed.png)
  - ![image.png](https://raw.githubusercontent.com/11ze/static/main/images/iCloud-sync-stuck.png)

每小时 kill 一次确保 iCloud 一直进行同步

```bash
$ crontab -e
0 * * * * killall bird && killall cloudd # 每小时 kill 一次 iCloud 进程
```

## 参考

- [一日一技 | Mac 上 iCloud 云盘同步卡住了？可以试试这样做](https://sspai.com/post/72882)
