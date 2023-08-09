---

title: 04｜AOF 日志：宕机了，Redis 如何避免数据丢失？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-18T21:13:32+08:00

---

- Redis 作为缓存使用

  - 从数据库读取数据恢复
  - 当需要恢复时数据库压力大、Redis 响应慢

- 写后日志：先执行命令把数据写入内存，再记录日志

  - 不会阻塞当前的写操作
  - 记录的命令没有错误
  - 没来得及记录时，宕机会丢失数据
  - 在主线程写，写盘压力大可能导致后续操作无法执行

- 日志格式示例

  - Redis 命令 set testkey testvalue
  - AOF 文件（Append Only File）
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-04-1.png)


  - \*3：命令有三个部分
  - $3：命令、键或值一共有多少字节
  - 每个 $n 下一行跟着命令、键或值

- 三种写回策略

  - Always：同步写回
  - Everysec：每秒写回

    - 优先使用，在可靠性和性能取了一个平衡

  - No：操作系统控制的写回

- 重写机制

  - 如多个操作同一个键值的命令合并为一个命令
  - 避免重写日志过大
  - 直接根据数据库里数据的最新状态，生成这些数据的插入命令，作为新日志
  - 一个拷贝

    - 由后台子进程 bgrewiteaof 完成，避免阻塞主线程

      - fork 创建 bgrewriteaof 子进程时，阻塞主线程，如果实例内存大，执行时间还会更长
      - 共享主线程内存，主线程执行新写或修改操作时会申请新的内存空间保存新的数据，如果操作的是 bigkey，可能因为申请大空间而面临阻塞风险

  - 两处日志

    - 正在使用的 AOF 日志 + 新的重写日志
    - 避免竞争文件系统的锁

  - 减小日志大小
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-04-2.png)

  - AOF 非阻塞重写过程
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-04-3.png)


- 适用于读操作比较多的场景
