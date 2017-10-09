---
title: Android 常用命令
date: 2017-10-09 21:21:03
categories: [Android]
tags: [Android]
---

## 基本命令
### 1.`adb shell dumpsys activity top`
查看当前应用 Activity 相关信息

### 2.`abd shell dumpsys package [packageName]`
查看指定包名应用的详细信息(也就是 AndroidManifest.xml 中的内容)

### 3.`adb shell dumpsys meminfo [pname/pid]`
查看指定进程名或者是进程 id 的内存信息

### 4.`adb shell dumpsys dbinfo [packageName]`
查看指定包名应用的数据库存储信息(包括存储的sql语句)

### 5.`adb install`
安装应用包 apk 文件

### 6.`adb uninstall`
卸载应用

### 7.`adb pull`
将设备中的文件放到到本地
```bash
adb pull /sdcard/tmp.txt .
```

### 8.`adb push`
将本地文件放到设备中
```bash
adb push .tmp.txt /sdcard
```

### 9.`adb shell screencap`
截屏操作
```bash
# 截屏到指定文件
adb shell screencap –p /sdcard/tmp.png
```

### 10.`adb shell screenrecord`
录屏操作
```bash
# 录屏并且保存到指定文件
adb shell screenrecord /sdcard/tmp.mp4
```

### 11.`adb shell input text`
向手机当前app的输入框中输入文本
```bash
adb shell input text 'HelloWorld'
```

### 12.`adb forward`
设备的端口转发
```bash
# adb forwrad [(远程端)协议:端口号] [(设备端)协议:端口号]
adb forward tcp:23946 tcp:23946
adb forward tcp:8700 jwdp:1786
```

### 13.`adb jdwp`
查看设备中可以被调试的应用的进程号

### 14.`adb logcat`
查看当前日志信息
```bash
# adb logcat -s [tag]
# adb logcat | findstr pname/pid/keyword
adb logcat | findstr im.wangchao.test
```

## 执行 adb shell 后的命令
### 15.`run-as [packageName]`
可以在非 root 设备中查看指定 debug 模式的包名应用沙盒数据

### 16.`ps`
查看设备的进程信息，或者是指定进程的线程信息

### 17.`pm clear [packageName]`
清空指定包名应用的数据

### 18.`pm install`
安装设备中的 apk 文件，功能和 adb install 一样

### 19.`pm uninstall`
卸载设备中的应用，功能和 adb uninstall  一样

### 20.`am start -n [包 (package) 名]/[包名].[活动 (activity) 名称]`
启动一个应用

### 21.`am startservice -n [包 (package) 名]/[包名].[服务 (service) 名]`
启动一个服务

### 22.`am broadcast -a [广播action]`
发送一个广播

### 23.`netcfg`
查看设备的 ip 地址

### 24.`netstat`
查看设备的端口号信息

### 25.`app_process [运行代码目录] [运行主类]`
运行 Java 代码
```bash
exec /system/bin/app_process /data/im.wangchao.Main
```

### 26.`dalvikvm –cp [ dex 文件] [运行主类]`
运行一个 dex 文件
```bash
dalvikvm –cp /data/demo.dex im.wangchao.Main
```

### 27.`top [-n/-m/-d/-s/-t]`
查看应用的 cpu 消耗信息
```
-m : 最多显示多少个进程

-n : 刷新次数

-d : 刷新间隔时间（默认 5 秒）

-s : 按哪列排序

-t : 显示线程信息而不是进程
```

### 28.`getprop [属性值名称]`
查看系统属性值

## 操作 apk
### 29.`aapt`
查看 apk 中的信息以及编辑 apk 程序包
```bash
aapt dump xmltree [ apk 包] [需要查看的资源文件 xml ]
```

### 30.`dexdump [dex文件路径]`
查看一个 dex 文件的相信信息

### 31.`查看进程`
```bash
# 查看当前进程的内存加载情况
cat /proc/[pid]/maps
# 查看进程的状态信息
cat /proc/[pid]/status
# 查看当前应用使用的端口号信息
cat / proc / [pid] / net / tcp / tcp6 / udp / udp6
```

