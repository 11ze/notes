---
title: 设计 Rate Limit
created: 2023-05-12T01:11:06+08:00
tags:
  - 开发
  - 设计
  - 编程
updated: 2024-05-07T16:24:01+08:00
---

## 说明

限制接口请求数

## 缓存数据格式

```JavaScript
key: {
  current_count: number;
  started_at: date;
  request_time_queue: date[];
  time_range: number; // 时间窗口大小
  count_limit: number;
}
```

## 处理流程

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
