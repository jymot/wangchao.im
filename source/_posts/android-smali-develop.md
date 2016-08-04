---
title: Android逆向开发之Smali
date: 2016-08-04 12:17:19
categories: Android
tags: Smali
---

### 了解
最近在研究一些关于Android二次开发的事情，也就是反编译APK后，然后注入一些我们需要的代码（比如广告），然后在重新签名生成新的APK包。我们都知道可以通过[APKTool反编译APK]，反编译成功后的目录结构如下：

<!--more-->

![Smithsonian Image](/images/android-reverse-develop-smali/mulu.png)
我们看到一些目录结构，其中Smali目录对应的就是我们反编译出来的代码，里面的所有文件都是以__.smali__为后缀的，所以我们如果想注入代码，就需要像这些文件里注入Smali代码。
为了了解Smali，我们可以新建一个工程，然后反编译生成的APK，对比一下对应的类文件，就像下面这样：
java类
```java
package com.test;

import android.app.Activity;
import android.os.Bundle;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
	    super.onCreate(savedInstanceState);
	    setContentView(R.layout.activity_main);
	}
}
```
反编译后的MainActivity.smali文件如下：
```smali
.class public Lcom/test/MainActivity;
.super Landroid/app/Activity;
.source "MainActivity.java"

# direct methods
.method public constructor <init>()V
   .locals 0

   .prologue
   .line 14
   invoke-direct {p0}, Landroid/app/Activity;-><init>()V

   return-void
.end method

# virtual methods
.method protected onCreate(Landroid/os/Bundle;)V
   .locals 1
   .parameter "savedInstanceState"

   .prologue
   .line 18
   invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

   .line 19
   const/high16 v0, 0x7f03

   invoke-virtual {p0, v0}, Lcom/test/MainActivity;->setContentView(I)V

   .line 20
   return-void
.end method
```
对比一下，可以比较清楚的看出来，smali代码其实就是对java代码一个翻译，只是没有java看起来那么简单，smali把很多应该复杂的东西还原成复杂的状态了，简单解释下这段代码：
 * 前三行指明了类名，父类名，和源文件名。
 *  类名以“L”开头相信熟悉Jni的童鞋都比较清楚。
 * “#”是smali中的注释。
 * “.method”和“.end method”类似于Java中的大括号，包含了方法的实现代码段。
 * 方法的括号后面指明了返回类型，这同样类似与Jni的调用。
 * “.locals”指明了这个方法用到的寄存器数量，当然寄存器可以重复利用，从“v0”起算。
 * “.prologue”指定了代码开始处。
 * “.line”表明这是在java源码中的第几行，其实这个值无所谓是多少，可以任意修改，主要用于调试。
 * “invoke-direct”这是对方法的调用，可以看到这里调用了是Android.app.Activity的init方法，这在java里是隐式调用的。
 * “return-void”表明了返回类型，这和java不一样，即使没有返回值，也需要这样写。
 * 接下来是onCreate方法，“.parameter”指明了参数名，但是一般没有用，需要注意的是p0代表的是this，p1开始代表函数参数，静态函数没有this，所以从p0开始就代表参数。
 * 在实现里先是调用了父类的方法，然后再调用setContentView，注意这里给了一个传参。整形的传参，这个值是先赋给寄存器v0，然后再调用的使用传递进去的。smali中都是这么使用，所有的值必须通过寄存器来中转。这点和汇编很像。

对比了Java代码和Smali代码，可以很清楚的看到，原本只有几行的代码到了Smali，内容被大大扩充了。Smali还原了Java隐藏的东西，同时显式地指定了很多细节。这还只是个最基本的onCreate函数，如果有内部类，还会分文件显示。

### 测试
接下来我们就可以注入代码了，比如我们要注入一个Toast，如下：
```java
Toast.makeText(this, "Hello, Smali", Toast.LENGTH_LONG).show();
```
```smali
.line xx
   const-string v0, "Hello, Smali"

   const/4 v1, 0x1

   invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

   move-result-object v0

   invoke-virtual {v0}, Landroid/widget/Toast;->show()V
```
下面的smali就是对应上面Toast的翻译，所以我们把下面这几行代码注入带onCreate中即可，需要注意的是，行号是不能重复的所以将xx替换为任意不重复的行数，还有就是.locals，因为上面的代码用到了v1，所以我们的.locals寄存器数量至少为2，修改成功后，我们就可以重新编译APK并对其进行签名，然后就可以看到在启动测试程序的工程中出现了我们刚才加入的Toast，注入成功了。

### 相关文章
[Android Smali语言学习]

[Android Smali语言学习]: http://blog.csdn.net/wdaming1986/article/details/8299996
[APKTool反编译APK]: http://wangchao.im/2016/01/20/android-secondary-build/