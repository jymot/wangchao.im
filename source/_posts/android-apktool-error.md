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
OS X里面存放的目录为/Users/username/Library/apktool/framework/1.apk。

### 编译异常
执行如下命令反编译APK
```
apktool d test.apk
```
反编译成功后，我们可能会执行如下命令进行二次编译
```
apktool b -o test_unsigned.apk test
```
此时很容易产生如下异常：
```
I: Building resources...
Exception in thread "main" brut.androlib.AndrolibException: brut.common.BrutException: could not exec command: [aapt, p, -F, /tmp/APKTOOL3630495287059303807.tmp, -I, /home/awesomename/apktool/framework/1.apk, -S, /home/awesomename/out/./res, -M, /home/awesomename/out/./AndroidManifest.xml]
    at brut.androlib.res.AndrolibResources.aaptPackage(Unknown Source)
    at brut.androlib.Androlib.buildResourcesFull(Unknown Source)
    at brut.androlib.Androlib.buildResources(Unknown Source)
    at brut.androlib.Androlib.build(Unknown Source)
    at brut.androlib.Androlib.build(Unknown Source)
    at brut.apktool.Main.cmdBuild(Unknown Source)
    at brut.apktool.Main.main(Unknown Source)
Caused by: brut.common.BrutException: could not exec command: [aapt, p, -F, /tmp/APKTOOL3630495287059303807.tmp, -I, /home/windows/apktool/framework/1.apk, -S, /home/windows/out/./res, -M, /home/windows/out/./AndroidManifest.xml]
    at brut.util.OS.exec(Unknown Source)
    ... 7 more
Caused by: java.io.IOException: Cannot run program "aapt": error=2, No such file or directory
    at java.lang.ProcessBuilder.start(ProcessBuilder.java:1041)
    at java.lang.Runtime.exec(Runtime.java:617)
    at java.lang.Runtime.exec(Runtime.java:485)
    ... 8 more
Caused by: java.io.IOException: error=2, No such file or directory
    at java.lang.UNIXProcess.forkAndExec(Native Method)
    at java.lang.UNIXProcess.<init>(UNIXProcess.java:135)
    at java.lang.ProcessImpl.start(ProcessImpl.java:130)
    at java.lang.ProcessBuilder.start(ProcessBuilder.java:1022)
    ... 10 more
```
这个异常是在build resources 的时候报出的，所以我们在反编译APK如果不改变APK的资源的话，那么我们执行反编译命令时可以像下面的命令一样加入参数，不对Resource进行编译，这样就解决了上述异常
```
apktool d -f -r test.apk
```
-r也就是说不解码资源。
关于二次打包具体流程可以参见我的另外一篇[文章]。

[文章]: http://wangchao.im/2016/01/20/android-secondary-build/
[ApkTool]: https://github.com/iBotPeaches/Apktool
