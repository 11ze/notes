---

title: Redis 客户端如何与服务端交换命令和数据？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-24T21:40:54+08:00

---

- 客户端和服务端交互内容

  - 命令
  - 键
  - 单个值
  - 集合值
  - OK 回复
  - 整数回复
  - 错误信息

- RESP 2 协议

  - 两个基本规范

    - 1. 实现 5 种编码格式类型，在每种编码类型的开头使用一个专门的字符区分
    - 2. 按照单个命令或单个数据的粒度进行编码，在每个编码结果后面增加一个换行符 \r\n 表示编码结束

  - 1. 简单字符串类型 RESP Simple Strings

    - +OK\r\n

  - 2. 长字符串类型 RESP Bulk String

    - 图
      - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-44-1.png)

    - $9 testvalue\r\n
    - Redis SDS 结构

      - len = 14; alloc; buf ("Redis\0Cluster\0")
      - \0 解析成正常的 0 字符

    - 最大 512MB

  - 3. 整数类型 RESP Integer

    - :3\r\n

  - 4. 错误类型 RESP Errors

    - -ERR unknown command `PUT`, with args beginning with: `testkey`, `testvalue`

  - 5. 数组编码类型 RESP Arrays

    - *2\r\n$3\r\nGET\r\n$7\r\ntestkey\r\n
    - 2：数组元素个数，命令 GET 和键 testkey

  - 不足

    - 1. 只能区分字符串和整数，其他类型需要客户端进行额外的转换操作
    - 2. 使用数组类别编码表示所有的集合类型，客户端需要根据发送的命令操作把返回结果转换成相应的集合类型数据结构

  - RESP 2 协议的 5 种编码类型和相应的开头字符
    - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-44-2.png)

- RESP 3 协议（6.0）

  - 增加对多种数据类型的支持，包括空值、浮点数、布尔值、有序的字典集合等

    - 也是通过不同的开头字符进行区分
    - 客户端不用再通过额外的字符串比对来实现数据转换操作

- 小工具

  - telnet 实例IP 实例端口

    - 然后在 telnet 中给实例发送命令，就能看到 RESP 协议编码后的返回结果
    - 也可以在 telnet 中向 Redis 实例发送用 RESP 协议编写的命令操作
