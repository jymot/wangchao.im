---
title: ApkTool反编译报错
date: 2016-01-20 19:59:19
categories: Android
tags: ApkTool
---
今天需要使用ApkTool反编译APK，因为好久没用了，所以就去github上面下载最新的版本[ApkTool]
然后替换对应的jar和bash脚本

<!--more-->

更新成功后，开始反编译APK，结果报出下面的异常
```java
    Exception in thread "main" brut.androlib.err.UndefinedResObject: resource spec: 0x01010490
```
开始一直在研究这个异常是为什么，后来发现上面有一个提示，显示的是framework的目录里面的1.apk，这个编译
异常就是因为这个文件，我们只需要把这个目录的1.apk删除即可，当我们在进行反编译时候会在生成这个apk。
OS X里面存放的目录为/Users/username/Library/apktool/framework/1.apk
[ApkTool]: https://github.com/iBotPeaches/Apktool
