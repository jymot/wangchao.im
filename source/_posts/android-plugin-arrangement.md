---
title: Android插件化相关知识点
date: 2016-05-04 08:36:43
categories: Android
tags: [Android, Android Plugin]
---

关于Android插件化开发涉及到的一些知识点汇总：
### 基础
1.[Java 类加载器]
2.[反射原理]
3.[代理模式及Java实现动态代理]
<!--more-->
### 入门
1.[Android插件化入门]
2.[插件化开发—动态加载技术加载已安装和未安装的apk]
3.[Android动态加载技术三个关键问题详解]
### 进阶
1.[携程Android App插件化和动态加载实践]
2.[动态加载APK原理分享]
3.[Android插件化的一种实现]
4.[蘑菇街 App 的组件化之路]
5.[DynamicLoadApk 源码解析]
6.[Android apk动态加载机制的研究]
7.[美团Android DEX自动拆包及动态加载简介]
8.[Android apk资源加载和activity生命周期管理]
9.[APK动态加载框架（DL）解析]
### 系列
1.[Kaedea---Android动态加载技术 简单易懂的介绍]
2.[Kaedea---Android动态加载基础 ClassLoader的工作机制]
3.[Kaedea---Android动态加载补充 加载SD卡的SO库]
4.[Kaedea---Android动态加载入门 简单加载模式]
5.[Kaedea---Android动态加载进阶 代理Activity模式]
6.[Kaedea---Android动态加载黑科技 动态创建Activity模式]
7.[尼古拉斯---插件开发基础篇：动态加载技术解读]
8.[尼古拉斯---插件开发开篇：类加载器分析]
9.[尼古拉斯---插件开发中篇：资源加载问题(换肤原理解析)]
10.[尼古拉斯---插件开发终极篇：动态加载Activity(免安装运行程序)]
11.[Weishu---Android插件化原理解析——概要]
12.[Weishu---Android插件化原理解析——Hook机制之动态代理]
13.[Weishu---Android插件化原理解析——Hook机制之Binder Hook]
14.[Weishu---Android 插件化原理解析——Hook机制之AMS&PMS]
15.[Weishu---Android 插件化原理解析——Activity生命周期管理]
16.[Weishu---Android 插件化原理解析——插件加载机制]
17.[Weishu---Android插件化原理解析——广播的管理]
### 类库
1.[Small]
2.[Android-Plugin-Framework]
3.[DynamicAPK]
4.[DroidPlugin]
5.[android-pluginmgr]
6.[dynamic-load-apk]
7.[AndroidDynamicLoader]
8.[ACDD]
### 参考视频
1.[android插件化及动态部署]
阿里技术沙龙第十六期《android插件化及动态部署》视频

ps: 本文转自[Android博客周刊]，阅读完这些博客后，我也会对每篇博客做一个总结
[Java 类加载器]: https://www.ibm.com/developerworks/cn/java/j-lo-classloader/
[反射原理]: https://github.com/JustinSDK/JavaSE6Tutorial/blob/master/docs/CH16.md
[代理模式及Java实现动态代理]: http://www.jianshu.com/p/6f6bb2f0ece9
[Android插件化入门]: http://104.236.134.90/2016/02/02/Android%E6%8F%92%E4%BB%B6%E5%8C%96%E5%9F%BA%E7%A1%80/
[插件化开发—动态加载技术加载已安装和未安装的apk]: http://blog.csdn.net/u010687392/article/details/47121729?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io
[Android动态加载技术三个关键问题详解]: https://blog.tingyun.com/web/article/detail/166
[携程Android App插件化和动态加载实践]: http://mp.weixin.qq.com/s?__biz=MzAwMTcwNTE0NA==&mid=400217391&idx=1&sn=86181541ce0164156dfab135ed99bb5c&scene=0&key=b410d3164f5f798e61a5d4afb759fa38371c8b119384c6163a30c28163b4d4d5f59399f2400800ec842f1d0e0ffb84af&ascene=0&uin=MjExMjQ&pass_ticket=Nt5Jaa28jjFxcQO9o%2BvQiXX%2B0iXG5DlZlHNW97Fk1Ew%3D
[动态加载APK原理分享]: http://blog.csdn.net/hkxxx/article/details/42194387
[Android插件化的一种实现]: http://www.cnblogs.com/coding-way/p/4669591.html
[蘑菇街 App 的组件化之路]: http://mogu.io/117-117
[DynamicLoadApk 源码解析]: http://www.codekk.com/open-source-project-analysis/detail/Android/FFish/DynamicLoadApk%20%E6%BA%90%E7%A0%81%E8%A7%A3%E6%9E%90?hmsr=toutiao.io&utm_medium=toutiao.io&utm_source=toutiao.io
[Android apk动态加载机制的研究]: http://blog.csdn.net/singwhatiwanna/article/details/22597587
[美团Android DEX自动拆包及动态加载简介]: http://tech.meituan.com/mt-android-auto-split-dex.html
[Android apk资源加载和activity生命周期管理]: http://blog.csdn.net/singwhatiwanna/article/details/23387079
[APK动态加载框架（DL）解析]: http://blog.csdn.net/singwhatiwanna/article/details/39937639
[Kaedea---Android动态加载技术 简单易懂的介绍]: https://segmentfault.com/a/1190000004062866
[Kaedea---Android动态加载基础 ClassLoader的工作机制]: https://segmentfault.com/a/1190000004062880
[Kaedea---Android动态加载补充 加载SD卡的SO库]: https://segmentfault.com/a/1190000004062899
[Kaedea---Android动态加载入门 简单加载模式]: https://segmentfault.com/a/1190000004062952
[Kaedea---Android动态加载进阶 代理Activity模式]: https://segmentfault.com/a/1190000004062972
[Kaedea---Android动态加载黑科技 动态创建Activity模式]: https://segmentfault.com/a/1190000004077469
[尼古拉斯---插件开发基础篇：动态加载技术解读]: http://blog.csdn.net/jiangwei0910410003/article/details/17679823
[尼古拉斯---插件开发开篇：类加载器分析]: http://blog.csdn.net/jiangwei0910410003/article/details/41384667
[尼古拉斯---插件开发中篇：资源加载问题(换肤原理解析)]: http://blog.csdn.net/jiangwei0910410003/article/details/47679843
[尼古拉斯---插件开发终极篇：动态加载Activity(免安装运行程序)]: http://blog.csdn.net/jiangwei0910410003/article/details/48104455
[Weishu---Android插件化原理解析——概要]: http://weishu.me/2016/01/28/understand-plugin-framework-overview/
[Weishu---Android插件化原理解析——Hook机制之动态代理]: http://weishu.me/2016/01/28/understand-plugin-framework-proxy-hook/
[Weishu---Android插件化原理解析——Hook机制之Binder Hook]: http://weishu.me/2016/02/16/understand-plugin-framework-binder-hook/
[Weishu---Android 插件化原理解析——Hook机制之AMS&PMS]: http://weishu.me/2016/03/07/understand-plugin-framework-ams-pms-hook/
[Weishu---Android 插件化原理解析——Activity生命周期管理]: http://weishu.me/2016/03/21/understand-plugin-framework-activity-management/
[Weishu---Android 插件化原理解析——插件加载机制]: http://weishu.me/2016/04/05/understand-plugin-framework-classloader/
[Weishu---Android插件化原理解析——广播的管理]: http://weishu.me/2016/04/12/understand-plugin-framework-receiver/
[Small]: https://github.com/wequick/Small
[Android-Plugin-Framework]: https://github.com/limpoxe/Android-Plugin-Framework
[DynamicAPK]: https://github.com/CtripMobile/DynamicAPK
[DroidPlugin]: https://github.com/DroidPluginTeam/DroidPlugin
[android-pluginmgr]: https://github.com/houkx/android-pluginmgr
[dynamic-load-apk]: https://github.com/singwhatiwanna/dynamic-load-apk
[AndroidDynamicLoader]: https://github.com/mmin18/AndroidDynamicLoader
[ACDD]: https://github.com/bunnyblue/ACDD/blob/master/README-Zh.md
[android插件化及动态部署]: http://v.youku.com/v_show/id_XNTMzMjYzMzM2.html
[Android博客周刊]: http://www.androidblog.cn/index.php/Index/detail/id/16
