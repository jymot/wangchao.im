---
title: MySQL 远程连接相关配置 [Server]
date: 2018-12-14 11:0 [Server]7:15
categories: Server
tags: [Server, MySQL]
---

关于 MySQL 远程登录相关配置，简单总结一下：

1. 首先可以创建一个特殊用户用于登录指定`host`,比如执行如下语句
```mysql
// replace with your 'user', 'password' and 'host'
CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';
// host 可以包含通配符，比如允许192.168.x.x网段，可以配置为192.168.%.%
```

2. 为刚刚的用户设定权限
```mysql
// 该用户有所有数据库的权限
GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost' WITH GRANT OPTION;
// 刷新权限
FLUSH PRIVILEGES;
```
