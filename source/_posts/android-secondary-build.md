---
title: Android二次开发打包
date: 2016-01-20 21:51:02
categories: Android
tags: [Android, Android安全]
---
关于Android二次打包，有的是为了更换证书，有的是为了修改资源，有的是为了注入广告，不管处于什么样的目的，都希望用于正当渠道。废话不多说，直接进入正题。

<!--more-->

#### 1.准备工作
我们需要下载[ApkTool]工具（关于该工具的下载和安装在官网都有详细的步骤，在这里就不多说了），然后确保keytool和jarsigner命令是可用的。

#### 2.反编译
我们使用ApkTool进行反编译APK，执行如下命令：
```bash
    apktool d -o app app.apk
```
就会将反编译结果放到app目录下，然后就可以修改反编译后的app目录中的内容，比如图片或代码。
如果需要修改代码，需要修改对应的Smali文件，关于Smali可以参见[Android逆向开发之Smali]

#### 3.编译
接下来执行如下命令，将修改后的目录重新打包为APK
```bash
    apktool b -o app_fix.apk app
```
这样我们就生成了新的修改后的app_fix.apk

#### 4.生成keystore
使用keytool命令生成keystore，具体如下：
```bash
    keytool -genkeypair -alias test -keyalg RSA -validity 20000 -keystore test.keystore
```
然后会提示我们录入密钥口令，还有输入一些信息，根据提示填写即可，执行结束后就会生成一个别名为`test`的`test.keystore`

#### 5.签名
用我们刚才生成的`test.keystore`给`app_fix.apk`签名，执行如下：
```bash
    jarsigner -verbose -keystore test.keystore -signedjar app_signed.apk app_fix.apk test
```
执行后需要录入keystore的口令，最后就会生成签名后的APK`app_signed.apk`

[Android逆向开发之Smali]: http://wangchao.im/2016/08/04/android-smali-develop/
[ApkTool]: https://github.com/iBotPeaches/Apktool
