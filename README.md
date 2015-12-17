将mongo的query语句转化成es的
=============

单纯的分析mongo中查询关键词, 并转化

> elastic version 1.7

### 目标
不是做一个完全的兼容转化, 选取mongo查询语法和es查询功能的一个共有子集, 对应起来

### 映射关系

- $eq, $ne
- $gt, $gte, $lt, $lte
- $in, $nin
- $regex
- $exists
- $size
- $and
- $not

### 不支持
- $or
