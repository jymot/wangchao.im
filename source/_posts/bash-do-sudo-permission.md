---
title: Shell脚本执行需要 root 权限的命令
date: 2017-06-20 17:07:02
categories: Shell
tags: [Shell]
---

直接上代码，命令如下：
```bash
echo "passwd"|sudo -S command
```
将`passwd`替换为你的`root`权限需要的密码，`command` 替换为需要执行的命令即可。

**example:**
比如 test.sh 脚本内容如下
```bash
#!/bin/bash
echo "123456"|sudo -S cp -rf  hosts.txt /etc/hosts
```
