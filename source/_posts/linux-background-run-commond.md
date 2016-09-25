---
title: Linux后台运行与停止进程
date: 2016-01-10 11:05:47
categories: Linux
tags: [nohup, Linux]
---
有时候我们在Terminal中其服务时候，需要让其在关闭Terminal的情况下也可以运行，那么我们这里用到的是nohup命令，执行命令如下:
``` linux
    nohup <commond> &
```
<!--more-->

比如我们运行hexo，那么我们只需要执行如下命令即可：
``` linux
    nohup hexo s &
```

有时候，我们需要停止后台运行，可以想到的是用kill：
``` linux
    kill PID
```
那么问题来了，怎么查看后台运行进程的PID，这里我们用ps命令：
``` linux
    ps -aux
    #a:显示所有程序 u:以用户为主的格式来显示 x:显示所有程序，不以终端机来区分
```
执行后会出现所有的进程，这个是不容易找到我们需要停止进程的PID的，所以我们要查找指定的，比如我们要查找hexo命令的进程，那么执行如下：
``` linux
    ps -aux | grep hexo
```
这样就会找到对应的进程，然后我们只需要查看其PID然后执行kill即可
