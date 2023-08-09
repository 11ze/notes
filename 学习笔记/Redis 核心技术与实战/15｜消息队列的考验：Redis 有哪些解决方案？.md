---

title: 15｜消息队列的考验：Redis 有哪些解决方案？
tags:
- Redis
- mindmap-plugin: basic
createdAt: 2023-05-22T21:19:48+08:00

---

- 消息队列的三大需求：消息保序、重复消息处理、消息可靠性保证
- List

  - 支持阻塞获取数据
  - 不支持消费组

- Stream

  - Redis 5.0 之后专门为消息队列设计的数据类型
  - 不同消费组的消费者可以消费同一个消息
  - 同一消费组的消费者不消费同一消息
  - 自动生成全局唯一 ID

- 两者比较
  - ![image.png](https://cdn.jsdelivr.net/gh/11ze/static/images/redis-15-1.png)

- 不能丢数据的场景应该采用专业的队列中间件：Kafka + Zookeeper、RabbitMQ
