---
title: Android Splash页面
date: 2015-07-27 19:34:40
categories: Android
tags: [Android]
---
在**App**开发中，我们会发现启动**App**的时候，应用会先黑屏或者白屏后才进入到我们的第一个页面，这是因为当我们打开**App**时，我们的**App**可能还没初始化完成，系统为了响应我们的操作，首先会启动一个`WindowType`为`TYPE_APPLICATION_STARTING`的`Window`，等**App**初始化完成后在移除这个`Window`，所以我们看到的黑屏和白屏也就是这个`Window`了。

但是为什么有的是黑的有的是白的呢，因为这个`Window`默认会显示一个空的`DecorView(Window顶层视图)`，这个`DecorView`会应用`Splash`页面所在`Activity`的`Theme`，如果没有指定，那么就会用`Application`的`Theme`。

所以我们可以自定义`Splash`页面的`Theme`来解决黑/白屏的问题，比如我们自定义的`Theme`如下：
```xml
<style name="SplashTheme" parent="xxx">
    <item name="android:windowFullscreen">true</item>
    <item name="android:windowIsTranslucent">true</item>
</style>
```
设置后，会发现启动我们的**App**虽然没有之前的问题了，但是会先延迟一会在进入`Splash`页面，这是因为我们把`Window`设置为透明的了，所以用户就会感觉我们的`App`启动缓慢。

如果对这样的设置不满意，我们可以给这个`Window`自定义一个背景，比如先自定义一个`layer-list`命名为`open_splash.xml`，注意这个`layer-list`内容最好和`Splash`页面相同，这样用户就会无感知了，如下：
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_page_color" />

    <item>
        <bitmap
            android:gravity="bottom"
            android:src="@drawable/splash_bottom" />
    </item>
</layer-list>
```
然后修改我们的`Theme`，如下：
```xml
<style name="SplashTheme" parent="xxx">
    <item name="android:windowFullscreen">true</item>
    <item name="android:windowBackground">@drawable/open_splash</item>
</style>
```
此时在启动，我们就可以流畅的看到**App**的启动了。

