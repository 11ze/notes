---
title: Rate Limit
createdAt: 2023-05-05T00:00:00+08:00
tags:
- 开发
- 设计
- 编程
---

## 功能

限制接口请求数

## 缓存数据格式

```JavaScript
key: {
  current_count: number; // 也可以不要该字段，每次请求都算一次队列长度
  started_at: date;
  request_time_queue: date[];
  time_range: number; // 时间窗口大小
  count_limit: number;
}
```

## 实现流程

1. 请求进来
2. 拼接出 key
3. 查找 key 对应的缓存
4. 取出队头，跟当前时间比较
    a. 若超出时间窗口，则移除，继续取下一个
5. 查看当前累积请求数量
6. 跟 limit 比较，若大于等于，拒绝请求
7. 若小于
    a. 将当前时间加入队列
    b. 当前请求数量 + 1
