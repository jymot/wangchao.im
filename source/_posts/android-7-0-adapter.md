---
title: Android 7.0 适配
date: 2016-11-10 20:25:28
categories: Android
tags: [Android]
---
Android 7.0 也出一阵子了，在这里分享一些关于 Android 7.0 适配的心得体会。

首先你要知道 Android 7.0 强制执行了`StrictMode API 政策`，目录被限制了访问。所以在我们日常开发中建议开启`StrictMode`。

在 Android 7.0 手机上，当我们调用相机照相，或者传递 `file://` Uri 到其它 App 时，我们会遇到`FileUriExposedException`异常，这是因为强制执行`StrictMode`后，禁止向其它 App 公开 `file://` Uri，也就是说当一个包含 `file://` Uri 的的 `Intent` 离开当前 App 时候就会出现`FileUriExposedException`异常。

在 Android 7.0 上我们对应的解决方案就是使用`FileProvider`，获取一个`content://` Uri 来完成我们的操作（当然低于7.0的版本，我们还用原来的方法即可）。

### FileProvider
[官方API](https://developer.android.com/reference/android/support/v4/content/FileProvider.html)

首先创建自己的 `FileProvider`，为什么要创建自己的`FileProvider`，当我们的工程引入第三方库时，难免会引入已经注册`android.support.v4.content.FileProvider`的库，那么我们`AndroidManifest.xml`就是合并失败，为了避免我们可以定义自己的`FileProvider`,如下：
```java
package com.xxx.test.TestFileProvider;

...

public class TestProvider extends FileProvider {
    public static final String AUTHORITY = "com.xxx.test.fileprovider";

    public static Uri compatUriFromFile(Context context, File file){
        return compatUriFromFile(context, file, null);
    }

    public static Uri compatUriFromFile(Context context, File file, Intent intent) {
        if (!needUseProvider()){
            return Uri.fromFile(file);
        }

        if (intent != null){
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }

        return getUriForFile(context, AUTHORITY, file);
    }

    public static boolean needUseProvider(){
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.N;
    }
}
```
然后在`AndroidManifest.xml`中注册我们的`FileProvider`，如下：
```xml
<provider
    android:name="com.xxx.test.TestProvider"
    android:authorities="com.xxx.test.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths"/>
</provider>
```
注意`exported:要求必须为false，若为true则会报安全异常`，`grantUriPermissions:true，表示授予 URI 临时访问权限`。
 
接下来在`res`目录中创建`xml`目录，并在里面创建`file_paths.xml`文件。该文件中指定可以访问目录，如下：
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="my_images" path="Android/data/com.xxx.test/files/Pictures" />
</paths>
```
我们主要看里面的节点，可以为`files-path`，`cache-path`，`external-path`，`external-files-path`和`external-cache-path`。

 * `files-path` 代表的根目录为：`Context.getFilesDir()`
 * `cache-path` 代表的根目录为：`Context.getCacheDir()`
 * `external-path` 代表的根目录为：`Environment.getExternalStorageDirectory()`
 * `external-files-path` 代表的根目录为：`Context#getExternalFilesDir(String)`
 * `external-cache-path` 代表的根目录为：`Context.getExternalCacheDir()`
 
节点的`path`属性代表相对目录，如果该属性设置为`""`，那么代表可以访问根目录的所有文件，如果像上面那样配置，那么则可以访问`/storage/emulated/0/Android/data/com.xxx.test/files/Pictures`目录。

配置完之后，我们就可以使用我们创建的`FileProvider`了，只需要将之前的`Uri.fromFile()`替换成`TestProvider.compatUriFromFile()`即可，比如调起照相机：
```java
Intent photoIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
File file = null;
try {
    // 创建文件
    file = createImageFile();
} catch (IOException e) {
    e.printStackTrace();
}
if (file != null){
    photoIntent.putExtra(MediaStore.EXTRA_OUTPUT, TestProvider.compatUriFromFile(this, file, photoIntent));
    startActivityForResult(photoIntent, CAPTURE_CUSTOM_FILE_REQUEST_CODE);
}
```

### 其他
#### 低电耗模式
在低电耗模式下，当用户设备未插接电源、处于静止状态且屏幕关闭时，该模式会推迟 CPU 和网络活动，从而延长电池寿命。
Android7.0通过在设备未插接电源且屏幕关闭状态下、但不一定要处于静止状态（例如用户外出时把手持式设备装在口袋里）时应用部分 CPU 和网络限制，进一步增强了低电耗模式。（也就是说，Android7.0会在手机屏幕关闭的状态下，限时应用对CPU以及网络的使用。）

具体规则如下：
 1. 当设备处于充电状态且屏幕已关闭一定时间后，设备会进入低电耗模式并应用第一部分限制： 关闭应用网络访问、推迟作业和同步。
 2. 如果进入低电耗模式后设备处于静止状态达到一定时间，系统则会对 PowerManager.WakeLock、AlarmManager、GPS 和 Wi-Fi 扫描应用余下的低电耗模式限制。 无论是应用部分还是全部低电耗模式限制，系统都会唤醒设备以提供简短的维护时间窗口，在此窗口期间，应用程序可以访问网络并执行任何被推迟的作业/同步。
 
#### 后台优化
[官方文档](https://developer.android.com/preview/features/background-optimization.html)
Android 7.0中删除了三项隐式广播，以帮助优化内存使用和电量消耗。

 1. 在 Android 7.0上 应用不会收到 `CONNECTIVITY_ACTION` 广播，即使你在manifest清单文件中设置了请求接受这些事件的通知。 但在前台运行的应用如果使用BroadcastReceiver请求接收通知，则仍可以在主线程中侦听`CONNECTIVITY_CHANGE`；
 2. 在 Android 7.0上应用无法发送或接收 `ACTION_NEW_PICTURE` 或 `ACTION_NEW_VIDEO` 类型的广播。
 
Android 框架提供多个解决方案来缓解对这些隐式广播的需求。 例如，`JobScheduler API`提供了一个稳健可靠的机制来安排满足指定条件（例如连入无限流量网络）时所执行的网络操作。 您甚至可以使用 `JobScheduler API` 来适应内容提供程序变化。

移动设备会经历频繁的连接变更，例如在 Wi-Fi 和移动数据之间切换时。 目前，可以通过在应用清单中注册一个接收器来侦听隐式 `CONNECTIVITY_ACTION` 广播，让应用能够监控这些变更。 由于很多应用会注册接收此广播，因此单次网络切换即会导致所有应用被唤醒并同时处理此广播。