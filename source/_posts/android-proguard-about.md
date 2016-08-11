---
title: Android混淆指令
date: 2016-07-29 08:32:32
categories: Android
tags: [Android, Proguard]
---
在Android打包过程中，混淆dex是不可或缺的，下面简单介绍几个应用在混淆文件中的指令。

<!--more-->

 * -optimizationpasses
 代码混淆的压缩比例,值在0-7之间
 * -dontusemixedcaseclassnames
 混淆后类名都为小写
 * -dontskipnonpubliclibraryclasses
 指定不去忽略非公共的库的类
 * -dontskipnonpubliclibraryclassmembers
 指定不去忽略非公共的库的类的成员
 * -dontpreverify
 不做预校验的操作
 * -verbose
 记录原类名和混淆后的类名
 * -printmapping
 生成原类名和混淆后的类名的映射文件
 * -optimizations
 混淆时采用的算法
 * -keepattributes
 保持属性，如：-keepattributes *Annotation* 不混淆注解，-keepattributes Signature 不混淆泛型，-keepattributes SourceFile,LineNumberTable 抛出异常时保留代码行号等
 * -keep
 不混淆的类或接口，如：-keep class A 不混淆A类类名
 * -keepclasseswithmembers
 保留类名和成员名，如：-keepclasseswithmembers class A 不混淆A类类名以及成员
 * -keepnames
 -keepnames class * implements java.io.Serializable {*;}
 指定想要保留的类名和类成员，如果shrinking时候没有删除这个类。比如，保留所有实现Serializable接口的类的类名。不使用的类仍然会被删除。只适用于混淆。
 
关于混淆的内容还有很多，先写到这，后面会陆续更新。