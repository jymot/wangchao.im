---
title: linux CentOS6.5 GLIBCXX和GLIBC编译错误
date: 2016-01-10 10:43:40
categories: Linux
tags: [GLIBCXX, Linux]
---
今天在编译hexo的时候，报错如下：
``` linux
    /usr/lib64/libstdc++.so.6: version `GLIBCXX_3.4.18' not found (required by clang)
```
这个是关于C++的库libstdc++版本过低造成的，但是我记得我已经安装到了3.4.19，所以先看下库信息，

<!--more-->

执行如下命令：
``` linux
    strings /usr/lib64/libstdc++.so.6 | grep GLIBC
```
得到如下结果：
``` linux
    GLIBCXX_3.4
    GLIBCXX_3.4.1
    GLIBCXX_3.4.2
    GLIBCXX_3.4.3
    GLIBCXX_3.4.4
    GLIBCXX_3.4.5
    GLIBCXX_3.4.6
    GLIBCXX_3.4.7
    GLIBCXX_3.4.8
    GLIBCXX_3.4.9
    GLIBCXX_3.4.10
    GLIBCXX_3.4.11
    GLIBCXX_3.4.12
    GLIBCXX_3.4.13
    GLIBCXX_3.4.14
    GLIBCXX_3.4.15
    GLIBCXX_3.4.16
    GLIBCXX_3.4.17
    GLIBC_2.3
    GLIBC_2.2.5
    GLIBC_2.3.2
    GLIBCXX_FORCE_NEW
    GLIBCXX_DEBUG_MESSAGE_LENGTH
```
发现缺少版本，然后执行如下命令：
``` linux
    ll  /usr/lib64/libstdc++.so.6  
```
结果如下：
``` linux
    lrwxrwxrwx 1 root root 30 1月  10 10:22 /usr/lib64/libstdc++.so.6 -> /usr/lib64/libstdc++.so.6.0.19
```
发现我们已经有了6.0.19版本，现在我们要找它被装到哪里了，执行如下：
``` linux
    find / -name libstdc++.so.6*  
```
运行结果如下：
``` linux
    /usr/lib64/libstdc++.so.6.0.13
    /usr/lib64/libstdc++.so.6
    /usr/lib64/libstdc++.so.6.0.19
    /usr/lib64/libstdc++.so.6.0.17
    /usr/share/gdb/auto-load/usr/lib/libstdc++.so.6.0.13-gdb.py
    /usr/share/gdb/auto-load/usr/lib/libstdc++.so.6.0.13-gdb.pyo
    /usr/share/gdb/auto-load/usr/lib/libstdc++.so.6.0.13-gdb.pyc
    /usr/share/gdb/auto-load/usr/lib64/libstdc++.so.6.0.13-gdb.py
    /usr/share/gdb/auto-load/usr/lib64/libstdc++.so.6.0.13-gdb.pyo
    /usr/share/gdb/auto-load/usr/lib64/libstdc++.so.6.0.13-gdb.pyc
    /usr/local/lib64/libstdc++.so.6.0.19-gdb.py
    /usr/local/lib64/libstdc++.so.6
    /usr/local/lib64/libstdc++.so.6.0.19
    /root/src/usr/lib/x86_64-linux-gnu/libstdc++.so.6
    /root/src/usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.17
    /root/src/gcc-4.8.5/x86_64-unknown-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6
    /root/src/gcc-4.8.5/x86_64-unknown-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.19
    /root/src/gcc-4.8.5/stage1-x86_64-unknown-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6
    /root/src/gcc-4.8.5/stage1-x86_64-unknown-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.19
    /root/src/gcc-4.8.5/prev-x86_64-unknown-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6
    /root/src/gcc-4.8.5/prev-x86_64-unknown-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6.0.19
```
我们看到 /usr/local/lib64/libstdc++.so.6.0.19 ，所以gcc安装时候把libstdc++.so.6.0.19安装到了/usr/local/lib64目录下，所以我们现在只需要把libstdc++.so.6链接指向libstdc++.so.6.0.19即可，执行如下：
``` linux
    cp /usr/local/lib64/libstdc++.so.6.0.19 /usr/lib64 
    rm -rf /usr/lib64/libstdc++.so.6 
    ln -s /usr/lib64/libstdc++.so.6.0.19 /usr/lib64/libstdc++.so.6
```
然后我们在看下库信息：
``` linux
    GLIBCXX_3.4
    GLIBCXX_3.4.1
    GLIBCXX_3.4.2
    GLIBCXX_3.4.3
    GLIBCXX_3.4.4
    GLIBCXX_3.4.5
    GLIBCXX_3.4.6
    GLIBCXX_3.4.7
    GLIBCXX_3.4.8
    GLIBCXX_3.4.9
    GLIBCXX_3.4.10
    GLIBCXX_3.4.11
    GLIBCXX_3.4.12
    GLIBCXX_3.4.13
    GLIBCXX_3.4.14
    GLIBCXX_3.4.15
    GLIBCXX_3.4.16
    GLIBCXX_3.4.17
    GLIBCXX_3.4.18
    GLIBCXX_3.4.19
    GLIBC_2.3
    GLIBC_2.2.5
    GLIBC_2.3.2
    GLIBCXX_FORCE_NEW
    GLIBCXX_DEBUG_MESSAGE_LENGTH
```
此时我们已经支持到了3.4.19