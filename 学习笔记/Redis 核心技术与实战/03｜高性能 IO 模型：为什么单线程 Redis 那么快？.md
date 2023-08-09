---

title: 03｜高性能 IO 模型：为什么单线程 Redis 那么快？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-18T21:11:47+08:00

---

- Redis 的网络 IO 和键值对读写由一个线程完成

  - 当客户端和 Reids 的网络连接断开时，Redis 不会等待客户端恢复连接

- Redis 的其他功能，比如持久化、异步删除、集群数据同步等，由额外的线程执行
- 单线程设计机制

  - 多线程编程模式：共享资源的并发访问控制问题
  - 在内存中完成大部分操作 + 高效的数据结构

- 多路复用机制（select/epoll 机制）

  - 该机制允许内核中同时存在多个监听套接字和已连接套接字
  - 内核监听这些套接字上的连接请求或数据请求，一旦有请求到达，就交给 Redis 处理
  - 基于事件的回调机制

    -   事件队列

- 基于多路服用的 Redis 高性能 IO 模型
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-03-1.png)
