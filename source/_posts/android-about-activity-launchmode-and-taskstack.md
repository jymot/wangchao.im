---
title: Android Activity启动模式与影响任务栈的故事
date: 2016-11-10 08:08:11
categories: [Android]
tags: [Android]
---
# 引言
Android开发中，Activity的使用是不可或缺的,在使用Activity的过程中通常会给特殊的Activity设置不同的启动模式,而这些启动模式也影响着Activity所在的任务栈,今天就先从Activity的启动模式说起,然后总结一些关于影响Activity任务栈的那些事。

## Activity启动模式
### 1.standard
Activity标准启动模式，也是默认启动模式。在这种模式下启动的Activity可以被多次实例化，也就是说在同一个任务栈中可以存在多个Activity的实例，每个实例都会处理一个Intent对象。

比如，我们有一个MainActivity，MainActivity的代码如下
```java
public class MainActivity extends AppCompatActivity {
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        findViewById(R.id.mTestBtn).setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, MainActivity.class);
                //intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });
        setTitle(getClass().getSimpleName());
        Log.e("wcwcwc", getClass().getSimpleName() + " onCreate Task ID : " + getTaskId());
    }
}
```
执行点击按钮跳转MainActivity，此时控制台的日志如下：
```
11-09 14:54:16.528 21613-21613/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 5634
11-09 14:54:18.198 21613-21613/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 5634
```
可以看出创建的多个MainActivity的实例，并且它们是在同一个任务栈中。

<!--more-->

### 2.singleTop
在singleTop模式下启动Activity，会判断当前任务栈的栈顶实例是否为当前Activity，如果是当前Activity，那么不会创建新实例并调用当前Activity的onNewIntent方法，如果不是当前Activity，那么和standard启动模式相同。需要注意的是，如果当前任务栈中存在Activity A的实例，但是不在栈顶，那么我们再次启动Activity A的时候，和standard启动模式相同一样会创建新的Activity A的实例。

我们先在AndrodiManifest.xml中把刚才的MainActivity的启动模式设置成singleTop，如下：
```xml
<activity
    android:name="im.wangchao.launchemode.MainActivity"
    android:launchMode="singleTop">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>

        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>
```
然后在MainActivity中重写onNewIntent方法，如下：
```java
@Override protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    Log.e("wcwcwc", getClass().getSimpleName() + " onNewIntent Task ID : " + getTaskId());
}
```
此时再次点击按钮，此时控制台的日志如下：
```
11-09 15:10:59.698 20015-20015/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 5636
11-09 15:11:48.568 20015-20015/im.wangchao.launchemode E/wcwcwc: MainActivity onNewIntent Task ID : 5636
```
因为此时MainActivity在栈顶并且MainActivity当前的启动模式为singleTop，我们点击按钮后，再次跳转MainActivity，并没有新创建MainActivity实例，而是调用了当前栈顶MainActivity实例的onNewIntent方法。

### 3.singleTask
在singleTask模式下启动Activity，系统会将启动该Activity的Intent添加FLAG_ACTIVITY_NEW_TASK标示，此时启动Activity时，系统会做出如下判断:

 1. **判断当前启动Activity所在的栈是否存在,若不存在那么创建该任务栈;**
 2. **判断该任务栈中是否存在本次启动的Activity实例,若不存在那么创建新的实例到任务栈中，若存在，那么不会创建新实例，并调用该实例的onNewIntent方法，而且会清掉当前任务栈中该实例上面的所有Activity实例，使其到栈顶。**

我们先把刚才的MainActivity的启动模式改为singleTask，然后创建FirstActivity和SecondActivity使用默认启动模式，FirstActivity和SecondActivity的代码类似，它们的onCreate方法如下：
```java
//FirstActivity
@Override protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
    findViewById(R.id.mTestBtn).setOnClickListener(new View.OnClickListener() {
        @Override public void onClick(View v) {
            Intent intent = new Intent(FirstActivity.this, SecondActivity.class);
            startActivity(intent);
        }
    });
    setTitle(getClass().getSimpleName());
    Log.e("wcwcwc", getClass().getSimpleName() + " onCreate Task ID : " + getTaskId());
}

//SecondActivity
@Override protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
    findViewById(R.id.mTestBtn).setOnClickListener(new View.OnClickListener() {
        @Override public void onClick(View v) {
            Intent intent = new Intent(SecondActivity.this, MainActivity.class);
            startActivity(intent);
        }
    });
    setTitle(getClass().getSimpleName());
    Log.e("wcwcwc", getClass().getSimpleName() + " onCreate Task ID : " + getTaskId());
}
```
此时我们依次点击三个页面的三个按钮，控制台打印如下：
```
11-09 16:24:18.518 21858-21858/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 5638
11-09 16:24:21.938 21858-21858/im.wangchao.launchemode E/wcwcwc: FirstActivity onCreate Task ID : 5638
11-09 16:24:25.588 21858-21858/im.wangchao.launchemode E/wcwcwc: SecondActivity onCreate Task ID : 5638
11-09 16:24:26.828 21858-21858/im.wangchao.launchemode E/wcwcwc: MainActivity onNewIntent Task ID : 5638
```
然后我们执行**adb shell dumpsys activity**查看当前任务栈中实例，结果如下：
```
Task id #5638
   TaskRecord{44bd045 #5638 A=im.wangchao.launchemode U=0 sz=1}
   Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
     Hist #0: ActivityRecord{526618e u0 im.wangchao.launchemode/.MainActivity t5638}
       Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
       ProcessRecord{7e804cb 21858:im.wangchao.launchemode/u0a705}
```
可以看到ID为5638的Task里面只有一个MainActivity，从上面的Log日志中可以看出，第二次调用MainActivity的时候，执行了onNewIntent，所以现在就证实了使用singleTask模式启动MainActivity时，如果当前栈中存在MainActivity，那么不会新创建MainActivity的实例，而是调用当前MainActivity实例的onNewIntent方法，并且清掉该实例在当前任务栈以上的所有Activity实例。接下来就需要验证FLAG_ACTIVITY_NEW_TASK为什么没起作用，上面的测试结果中所有的Activity的TaskID都是相同的，那是因为Activity的taskAffinity造成的。

taskAffinity是AndroidManifest.xml中<activity>的一个属性，这个属性表示该Activity所在的任务栈，简单理解，相同taskAffinity的Activity属于同一任务栈。如果Activity没有设置taskAffinity，那么该Activity的任务栈取决与启动它的Activity的任务栈。需要注意的是，如果Activity以FLAG_ACTIVITY_NEW_TASK标示启动时，它会被启动到哪个任务栈是由taskAffinity决定的，如果不设置taskAffinity，那么就是当前任务栈，所以上面的测试我们就知道为什么所有的Activity的TaskID都相同了，使用singleTask模式启动MainActivity时，判断MainActivity的启动任务栈，因为没有设置taskAffinity，所以为默认的根Activity任务栈，判断根任务栈已经存在，所以不创建新的任务栈，然后就是后面的在任务栈中判断MainActivity实例是否存在的问题了。（taskAffinity也可以设置为空字符串,和不设置是不同的）

下面我们做简单的修改，因为目前MainActivity为根Activity，我们修改taskAffinity看不出效果，所以我们把MainActivity启动模式改回默认standard模式，然后把FirstActivity的启动模式改为singleTask，并添加taskAffinity如下：
```xml
<activity
    android:name="im.wangchao.launchemode.MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>

        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>
<activity
    android:launchMode="singleTask"
    android:taskAffinity="im.wangchao.singleTask"
    android:name="im.wangchao.launchemode.FirstActivity"/>

<activity
    android:name="im.wangchao.launchemode.SecondActivity"/>
```
然后我们启动MainActivity后依次点击三个页面的按钮，日志如下：
```
11-09 16:58:36.448 21187-21187/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 5652
11-09 16:58:42.518 21187-21187/im.wangchao.launchemode E/wcwcwc: FirstActivity onCreate Task ID : 5653
11-09 16:58:43.768 21187-21187/im.wangchao.launchemode E/wcwcwc: SecondActivity onCreate Task ID : 5653
11-09 16:58:45.438 21187-21187/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 5653
```
可以看到，FirstActivity启动的TaskID和MainActivity第一次启动的TaskID不同，也就是说真正的新创建了一个任务栈，而且FirstActivity启动Activity的任务栈和FirstActivity所在任务栈相同(前面说过，默认状态下，Activity所在的任务栈取决于启动它的Activity的任务栈)，然后执行**adb shell dumpsys activity**查看任务栈信息如下：
```
Stack #1:
  Task id #5653
    TaskRecord{b361a84 #5653 A=im.wangchao.singleTask U=0 sz=3}
    Intent { flg=0x10000000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      Hist #2: ActivityRecord{b5ac259 u0 im.wangchao.launchemode/.MainActivity t5653}
        Intent { cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
        ProcessRecord{8885ea2 30132:im.wangchao.launchemode/u0a705}
      Hist #1: ActivityRecord{2d3021 u0 im.wangchao.launchemode/.SecondActivity t5653}
        Intent { cmp=im.wangchao.launchemode/.SecondActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
        ProcessRecord{8885ea2 30132:im.wangchao.launchemode/u0a705}
      Hist #0: ActivityRecord{1c42ca u0 im.wangchao.launchemode/.FirstActivity t5653}
        Intent { flg=0x10000000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
        ProcessRecord{8885ea2 30132:im.wangchao.launchemode/u0a705}
  Task id #5652
    TaskRecord{835b26d #5652 A=im.wangchao.launchemode U=0 sz=1}
    Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      Hist #0: ActivityRecord{880d00e u0 im.wangchao.launchemode/.MainActivity t5652}
        Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[722,1024][1062,1464] }
        ProcessRecord{8885ea2 30132:im.wangchao.launchemode/u0a705}
```
可以看到新的任务栈的名字为**im.wangchao.singleTask**。

### 4.singleInstance
使用该启动模式的Activity，总是在新的任务栈中开启，并且这个新的任务栈中有且只有这一个实例，也就是说被该实例启动的其它Activity会自动运行于另一个任务栈中。当再次启动该Activity的实例时，会重用已存在的任务栈和实例，并且会调用这个实例的onNewIntent()方法。和singleTask相同，同一时刻在系统中只会存在一个这样的Activity实例。

我们把FirstActivity的启动模式改为singleInstance，然后其它Activity保持不变，如下：
```xml
<activity
    android:launchMode="singleInstance"
    android:name="im.wangchao.launchemode.FirstActivity"/>
```
我们依次点击三个页面的按钮，日志如下：
```
11-09 17:17:47.608 13207-13207/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 5668
11-09 17:17:49.728 13207-13207/im.wangchao.launchemode E/wcwcwc: FirstActivity onCreate Task ID : 5669
11-09 17:17:50.608 13207-13207/im.wangchao.launchemode E/wcwcwc: SecondActivity onCreate Task ID : 5668
11-09 17:17:51.448 13207-13207/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 5668
11-09 17:17:53.188 13207-13207/im.wangchao.launchemode E/wcwcwc: FirstActivity onNewIntent Task ID : 5669
```
然后再使用**adb shell dumpsys activity**查看任务栈信息如下:
```
Task id #5669
  TaskRecord{23fd955 #5669 A=im.wangchao.launchemode U=0 sz=1}
  Intent { flg=0x10000000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #0: ActivityRecord{ad4332 u0 im.wangchao.launchemode/.FirstActivity t5669}
      Intent { flg=0x10000000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{a935c5b 13207:im.wangchao.launchemode/u0a705}
Task id #5668
  TaskRecord{6259f6a #5668 A=im.wangchao.launchemode U=0 sz=3}
  Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #2: ActivityRecord{f0a4d4a u0 im.wangchao.launchemode/.MainActivity t5668}
      Intent { cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{a935c5b 13207:im.wangchao.launchemode/u0a705}
    Hist #1: ActivityRecord{de68f24 u0 im.wangchao.launchemode/.SecondActivity t5668}
      Intent { flg=0x10400000 cmp=im.wangchao.launchemode/.SecondActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{a935c5b 13207:im.wangchao.launchemode/u0a705}
    Hist #0: ActivityRecord{d9c0946 u0 im.wangchao.launchemode/.MainActivity t5668}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{a935c5b 13207:im.wangchao.launchemode/u0a705}
```
可以看出FirstActivity自己在ID为5669的任务栈中，而且第二次启动FirstActivity时，调用了之前实例的onNewIntent方法，并且在FirstActivity上启动的Activity在其它任务栈中，本次测试中FirstActivity启动的SecondActivity的TaskID和根ActivityTaskID相同是因为没有给SecondActivity设置taskAffinity,所以使用的是根任务栈。

`总结一下，启动模式为standard或singleTop时，一般是在同一个任务中对Activity进行调度，而在启动模式为singleTask或singleInstance是，一般会对Task进行整体调度。`

## Intent Flag
以下文中`概览菜单`指Overview Screen，也叫最近屏幕、最近任务列表、最近应用等。

### FLAG_ACTIVITY_NEW_TASK
这个标记我们在上面Activity启动模式中已经提到过了,我们重新解释一下。如果Intent中包含该标记,那么系统会判断启动的目标Activity的taskAffinity对应的Task是否存在,如果不存在那么创建这个Task,然后在该Task中启动目标Activity。

### FLAG_ACTIVITY_CLEAR_TOP
如果增加这个Flag,在启动Activity的时候,如果栈中存在要启动的这个Activity,那么会清空包括之前的这个Activity在内其上的所有Activity。我们继续用之前的三个Activity,MainActivity跳转FirstActivity,FirstActivity跳转SecondActivity,SecondActivity跳转MainActivity并且添加`FLAG_ACTIVITY_CLEAR_TOP`标记,跳转日志如下:
```
11-18 09:35:25.223 28174-28174/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 5968
                                                                im.wangchao.launchemode.MainActivity@11ef2ca
11-18 09:35:28.393 28174-28174/im.wangchao.launchemode E/wcwcwc: FirstActivity onCreate Task ID : 5968
11-18 09:35:28.393 28174-28174/im.wangchao.launchemode E/wcwcwc: FirstActivity onStart Task ID : 5968
11-18 09:35:33.983 28174-28174/im.wangchao.launchemode E/wcwcwc: SecondActivity onCreate Task ID : 5968
11-18 09:35:35.643 28174-28174/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 5968
                                                                im.wangchao.launchemode.MainActivity@66cd8c1
```
然后查看一下此时任务栈的情况:
```
Task id #5968
      TaskRecord{397bf0c #5968 A=im.wangchao.launchemode U=0 sz=1}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
        Hist #0: ActivityRecord{31a3055 u0 im.wangchao.launchemode/.MainActivity t5968}
          Intent { flg=0x4000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
          ProcessRecord{17b1c6f 28174:im.wangchao.launchemode/u0a705}
```
由此可以证实之前的说明,添加该标记后会清空包括其在内的Activity,在实例新的MainActivity(上面打印了MainActivity两次为不同的对象)。

当然`FLAG_ACTIVITY_CLEAR_TOP`也可以和`FLAG_ACTIVITY_SINGLE_TOP`结合使用,效果类似Activity的SingleTask模式,我们把刚才的例子稍微坐下修改,SecondActivity在启动MainActivity的时候添加`FLAG_ACTIVITY_SINGLE_TOP`和`FLAG_ACTIVITY_CLEAR_TOP`标记,我们先来看下打印的日志:
```
11-18 09:40:01.393 458-458/im.wangchao.launchemode E/wcwcwc: MainActivity Task ID : 5969
                                                            im.wangchao.launchemode.MainActivity@a631c3b
11-18 09:40:04.733 458-458/im.wangchao.launchemode E/wcwcwc: FirstActivity Task ID : 5969
11-18 09:40:04.733 458-458/im.wangchao.launchemode E/wcwcwc: FirstActivity onStart Task ID : 5969
11-18 09:40:05.493 458-458/im.wangchao.launchemode E/wcwcwc: SecondActivity Task ID : 5969
11-18 09:40:06.673 458-458/im.wangchao.launchemode E/wcwcwc: MainActivity onNewIntent Task ID : 5969
```
然后看下此时任务栈情况:
```
Task id #5969
     TaskRecord{c2040ac #5969 A=im.wangchao.launchemode U=0 sz=1}
     Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
       Hist #0: ActivityRecord{cb6c78a u0 im.wangchao.launchemode/.MainActivity t5969}
         Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
         ProcessRecord{e782175 458:im.wangchao.launchemode/u0a705}
```

所以在启动MainActivity的时候,会清空FirstActivity和SecondActivity,然后调用MainActivity的onNewIntent方法。需要注意的是SecondActivity在启动MainActivity的时候Activity的启动模式为非standard时,我们不需要增加`FLAG_ACTIVITY_SINGLE_TOP`也可以达到一样的效果。

### FLAG_ACTIVITY_SINGLE_TOP
该标记表示如果在当前Activity中启动当前Activity时,也就是在栈顶启动栈顶的Activity时,我们增加这个标记,和Activity的SingTop启动模式类似。比如我们有个Activity A,A启动A然后添加`FLAG_ACTIVITY_SINGLE_TOP`后,不会创建新的A实例,而是调用A的onNewIntent方法。

### FLAG_ACTIVITY_NEW_DOCUMENT / FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET
Android5.0后,引入了`FLAG_ACTIVITY_NEW_DOCUMENT`标记替代了之前的`FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET`,在Intent加入该标记时,会在新的任务栈中启动目标Activity,默认情况下第二次执行该操作(加入该标记启动Activity)时会将之前的任务栈设置为前台,而不是新建任务栈,而且点击Back键时,该任务栈不会保留在概览菜单中。下面我们举例验证,比如我们在之前MainActivity启动FirstActivity的Intent上增加该Flag,启动之后Log日志和任务栈的信息如下:
```
11-24 13:52:19.128 24364-24364/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 6374
                                                                im.wangchao.launchemode.MainActivity@a631c3b
11-24 13:52:20.748 24364-24364/im.wangchao.launchemode E/wcwcwc: FirstActivity onCreate Task ID : 6375
                                                                im.wangchao.launchemode.FirstActivity@6a285a6
11-24 13:52:20.748 24364-24364/im.wangchao.launchemode E/wcwcwc: FirstActivity onStart Task ID : 6375
```
```
Stack #1:
   Task id #6375
     TaskRecord{36da5eb #6375 A=im.wangchao.launchemode U=0 sz=1}
     Intent { flg=0x10080000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
       Hist #0: ActivityRecord{f27b0f8 u0 im.wangchao.launchemode/.FirstActivity t6375}
         Intent { flg=0x10080000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
         ProcessRecord{65a81e1 24364:im.wangchao.launchemode/u0a705}
   Task id #6374
     TaskRecord{cff6f48 #6374 A=im.wangchao.launchemode U=0 sz=1}
     Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
       Hist #0: ActivityRecord{6c787dc u0 im.wangchao.launchemode/.MainActivity t6374}
         Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[34,1024][374,1464] }
         ProcessRecord{65a81e1 24364:im.wangchao.launchemode/u0a705}
```
如上,FirstActivity在一个id为6375的新的任务栈中,此时我们切换到MainActivity,再次跳转FirstActivity,此时的Log和任务栈情况如下:
```
11-24 13:53:16.028 24364-24364/im.wangchao.launchemode E/wcwcwc: FirstActivity onStart Task ID : 6375
```
```
Stack #1:
    Task id #6375
      TaskRecord{36da5eb #6375 A=im.wangchao.launchemode U=0 sz=1}
      Intent { flg=0x10080000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
        Hist #0: ActivityRecord{f27b0f8 u0 im.wangchao.launchemode/.FirstActivity t6375}
          Intent { flg=0x10080000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
          ProcessRecord{65a81e1 24364:im.wangchao.launchemode/u0a705}
    Task id #6374
      TaskRecord{cff6f48 #6374 A=im.wangchao.launchemode U=0 sz=1}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
        Hist #0: ActivityRecord{6c787dc u0 im.wangchao.launchemode/.MainActivity t6374}
          Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[34,1024][374,1464] }
          ProcessRecord{65a81e1 24364:im.wangchao.launchemode/u0a705}
```
所以我们不难看出,第二次跳转FirstActivity时并没有新建任务栈和Activity,而是将之前的任务栈设置为前台将其显示出来。到此为止,大概了解`FLAG_ACTIVITY_NEW_DOCUMENT`和目标Activity设置了`taskAffinity`的`FLAG_ACTIVITY_NEW_TASK`有些类似,只不过`FLAG_ACTIVITY_NEW_TASK`新建的任务栈是我们自己指定的,但是需要注意的是默认情况下,`FLAG_ACTIVITY_NEW_TASK`启动Activity后点击Back键时,启动的Activity的任务栈会保留在概览菜单中,而`FLAG_ACTIVITY_NEW_DOCUMENT`启动的Activity点击Back键后,并不会显示在概览菜单中。

对于上面的验证来说,多次启动FirstActivity并没有新建任务栈,但是有时候我们需要多次启动FirstActivity,使其在不同的任务栈中,那么就可以和`FLAG_ACTIVITY_MULTIPLE_TASK`组合使用了,所以我们在上面的例子的基础上,在MainActivity跳转FirstActivity时增加`FLAG_ACTIVITY_MULTIPLE_TASK`标记,此时的Log信息和任务栈情况如下:
```
#第一次启动FirstActivity
11-28 10:43:13.507 21982-21982/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 6642
                                                                im.wangchao.launchemode.MainActivity@a631c3b
11-28 10:44:47.707 21982-21982/im.wangchao.launchemode E/wcwcwc: FirstActivity onCreate Task ID : 6643
                                                                im.wangchao.launchemode.FirstActivity@6a285a6
```
```
#第一次启动FirstActivity
Task id #6643
  TaskRecord{c476828 #6643 A=im.wangchao.launchemode U=0 sz=1}
  Intent { flg=0x18080000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #0: ActivityRecord{72890d0 u0 im.wangchao.launchemode/.FirstActivity t6643}
      Intent { flg=0x18080000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{b1ddee6 21982:im.wangchao.launchemode/u0a705}
Task id #6642
  TaskRecord{313b941 #6642 A=im.wangchao.launchemode U=0 sz=1}
  Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #0: ActivityRecord{f121429 u0 im.wangchao.launchemode/.MainActivity t6642}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{b1ddee6 21982:im.wangchao.launchemode/u0a705}
```
```
#第二次启动FirstActivity
11-28 10:46:34.027 21982-21982/im.wangchao.launchemode E/wcwcwc: FirstActivity onCreate Task ID : 6644
                                                                im.wangchao.launchemode.FirstActivity@455cf06
11-28 10:46:34.027 21982-21982/im.wangchao.launchemode E/wcwcwc: FirstActivity onStart Task ID : 6644
```
```
#第二次启动FirstActivity
Task id #6644
  TaskRecord{9238cad #6644 A=im.wangchao.launchemode U=0 sz=1}
  Intent { flg=0x18080000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #0: ActivityRecord{74642f7 u0 im.wangchao.launchemode/.FirstActivity t6644}
      Intent { flg=0x18080000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{b1ddee6 21982:im.wangchao.launchemode/u0a705}
Task id #6642
  TaskRecord{313b941 #6642 A=im.wangchao.launchemode U=0 sz=1}
  Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[100,564][1339,1803] }
    Hist #0: ActivityRecord{f121429 u0 im.wangchao.launchemode/.MainActivity t6642}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[100,564][1339,1803] }
      ProcessRecord{b1ddee6 21982:im.wangchao.launchemode/u0a705}
Task id #6643
  TaskRecord{c476828 #6643 A=im.wangchao.launchemode U=0 sz=1}
  Intent { flg=0x18080000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #0: ActivityRecord{72890d0 u0 im.wangchao.launchemode/.FirstActivity t6643}
      Intent { flg=0x18080000 cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{b1ddee6 21982:im.wangchao.launchemode/u0a705}
```
通过上面的日志信息,我们不难看出,加了`FLAG_ACTIVITY_MULTIPLE_TASK`标记后,第二次启动FirstActivity的时候,创建了新的实例,并把该实例放到了新的任务栈中。

我们开始说到,用`FLAG_ACTIVITY_NEW_DOCUMENT`启动的任务栈,点击Back后,不会保存到概览菜单中。但是有时候,我们需要将启动的任务栈保留在概览菜单中,这就引入了`FLAG_ACTIVITY_RETAIN_IN_RECENTS`标记,我们只需在加入该标记,就可以实现点击Back后,将新的任务栈保留在概览菜单中。用上面例子来说,启动FirstActivity后点击Back键,FirstActivity以及其任务栈就会保留在概览菜单中了。

说到这里,我们也可以设置<activity/>的`documentLaunchMode`属性达到相同的效果,该属性有四个值,分别为:
 * intoExisting: 和只添加`FLAG_ACTIVITY_NEW_DOCUMENT`标志效果相同,会重用已存在的任务栈。
 * always: 类似于添加`FLAG_ACTIVITY_NEW_DOCUMENT`和`FLAG_ACTIVITY_MULTIPLE_TASK`标记,每次启动都会创建新的任务栈和新的Activity。
 * none: 不会新创建任务栈,该属性为默认值。
 * never: 不会新创建任务栈。和none不同的是，设置这个参数会覆盖Intent中的`FLAG_ACTIVITY_NEW_DOCUMENT`和`FLAG_ACTIVITY_MULTIPLE_TASK`,使其这些标志不起作用。
 
最后关于说一下注意事项,使用`FLAG_ACTIVITY_NEW_DOCUMENT`标记,Activity的launchMode必须为默认的standard。若<activity/>的`documentLaunchMode`属性设置`intoExisting`或`always`时,Activity的launchMode也必须为默认值standard。

### FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
这个标记理解起来比较简单,加入这个标记启动的Activity所在的任务栈(该任务栈的根Activity必须为启动的Activity)在点击Back键或者Home键后,将不会保存在概览菜单中,一般需要配合`FLAG_ACTIVITY_NEW_TASK`使用。举个简单的例子,Activity A和B,A启动B的时候加入了`FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS`和`FLAG_ACTIVITY_NEW_TASK`,并且给B设置了taskAffinity属性,让其在不同的任务栈,启动B后,我们点击Back或者Home键,在概览菜单中是找不到刚才启动B所在的任务栈的。

当然<activity/>中也有类似的属性,那就是`excludeFromRecents`,将该属性设置为true可以达到同样的效果。

### FLAG_ACTIVITY_PREVIOUS_IS_TOP
这个标记的意思就是将前一个Activity当作栈顶启动新的Activity,比如有三个Activity,A,B,C, A启动B,B在启动C的时候加入该标记,那么启动时,就会把A当作栈顶启动C,B只是一个中间跳转页面,注意B在加入该标记的时候需要将自己finish。
该标记一般和`FLAG_ACTIVITY_FORWARD_RESULT`一起使用。

### FLAG_ACTIVITY_FORWARD_RESULT
该标记简单的理解就是可以传递setResult方法设置的值。比如我们有三个Activity,A,B和C,A通过startActivityForResult启动B,B启动C的时候加入该标记并且最后finish掉自己,然后C调用setResult,这样A就可以接收到C回传的结果了。一般用这个标记,中间页面(比如上面例子的B页面)都为过滤页。

### FLAG_ACTIVITY_REORDER_TO_FRONT
这个标记会修改当前栈的情况。我们先用前面的例子,MainActivity启动FirstActivity,然后FirstActivity启动SecondActivity,此时日志和任务栈情况如下:
```
11-29 21:25:28.669 26858-26858/im.wangchao.launchemode E/wcwcwc: MainActivity onCreate Task ID : 6718
                                                                im.wangchao.launchemode.MainActivity@a631c3b
11-29 21:25:33.599 26858-26858/im.wangchao.launchemode E/wcwcwc: FirstActivity onCreate Task ID : 6718
                                                                im.wangchao.launchemode.FirstActivity@6a285a6
11-29 21:25:34.289 26858-26858/im.wangchao.launchemode E/wcwcwc: SecondActivity onCreate Task ID : 6718
```
```
Task id #6718
  TaskRecord{151b9a6 #6718 A=im.wangchao.launchemode U=0 sz=3}
  Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #2: ActivityRecord{9562bf0 u0 im.wangchao.launchemode/.SecondActivity t6718}
      Intent { cmp=im.wangchao.launchemode/.SecondActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{f1b1794 26858:im.wangchao.launchemode/u0a705}
    Hist #1: ActivityRecord{c5df9d8 u0 im.wangchao.launchemode/.FirstActivity t6718}
      Intent { cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{f1b1794 26858:im.wangchao.launchemode/u0a705}
    Hist #0: ActivityRecord{20870c9 u0 im.wangchao.launchemode/.MainActivity t6718}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{f1b1794 26858:im.wangchao.launchemode/u0a705}
```
然后我们在SecondActivity中启动MainActivity,并假如该标记,此时的日志和任务栈情况如下:
```
11-29 21:28:06.379 26858-26858/im.wangchao.launchemode E/wcwcwc: MainActivity onNewIntent Task ID : 6718
```
```
Task id #6718
  TaskRecord{151b9a6 #6718 A=im.wangchao.launchemode U=0 sz=3}
  Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #2: ActivityRecord{20870c9 u0 im.wangchao.launchemode/.MainActivity t6718}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10000000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{f1b1794 26858:im.wangchao.launchemode/u0a705}
    Hist #1: ActivityRecord{9562bf0 u0 im.wangchao.launchemode/.SecondActivity t6718}
      Intent { cmp=im.wangchao.launchemode/.SecondActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{f1b1794 26858:im.wangchao.launchemode/u0a705}
    Hist #0: ActivityRecord{c5df9d8 u0 im.wangchao.launchemode/.FirstActivity t6718}
      Intent { cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{f1b1794 26858:im.wangchao.launchemode/u0a705}
```
上面的信息,我们可以看出,原来的任务栈为MainActivity,FirstActivity和SecondActivity,然后SecondActivity启动MainActivity后,任务栈情况变为FirstActivity,SecondActivity和MainActivity,并且调用了MainActivity的onNewIntent方法。

### FLAG_ACTIVITY_TASK_ON_HOME
如果加入该标记,启动的Activity点击Back键后会回到手机的主页面,而不是启动这个页面的前一个Activity。也就是说比如A启动B加入该标记,在B页面点击Back键并非回到A页面,而是回到启动这个App的那个页面(比如主页面,Launcher页面)。

需要注意的是,该标记自己不生效,只有在新启的Activity为新的任务栈时才生效,所以经常和`FLAG_ACTIVITY_NEW_TASK`(须设置Activity的taskAffinity)或者`FLAG_ACTIVITY_NEW_DOCUMENT`等标记组合使用。

## Activity标签属性
### android:documentLaunchMode
上面已经简单说过,下面在重新说明下四个属性:
 * intoExisting: 和只添加`FLAG_ACTIVITY_NEW_DOCUMENT`标志效果相同,会重用已存在的任务栈。
 * always: 类似于添加`FLAG_ACTIVITY_NEW_DOCUMENT`和`FLAG_ACTIVITY_MULTIPLE_TASK`标记,每次启动都会创建新的任务栈和新的Activity。
 * none: 不会新创建任务栈,该属性为默认值。
 * never: 不会新创建任务栈。和none不同的是，设置这个参数会覆盖Intent中的`FLAG_ACTIVITY_NEW_DOCUMENT`和`FLAG_ACTIVITY_MULTIPLE_TASK`,使其这些标志不起作用。

### android:allowTaskReparenting
如果Activity的该属性设置为true,Activity 可以从其启动的任务移动到与其具有关联的任务（如果该任务出现在前台）。也就是说,我们有两个App,App A和App B,App A中有两个Activity分别是MainActivity和FirstActivity,App B中有一个Activity,将App A的FirstActivity的allowTaskReparenting设置为true,然后在App B的Activity中启动App A的FirstActivity,此时App A的FirstActivity和App B具有相同的Task,然后点击home键,使其进入后台,在打开App A,此时FirstActivity回到App A中的Task。下面我们进行验证:
我们先来看下在App B中启动App A的FirstActivity后的任务栈情况:
```
Task id #6727
  TaskRecord{151cb8e #6727 A=im.wangchao.appB U=0 sz=2}
  Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.dbtest/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #1: ActivityRecord{95636b1 u0 im.wangchao.appA/.FirstActivity t6727}
      Intent { act=im.wangchao.First cmp=im.wangchao.appA/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{9ad1faf 17593:im.wangchao.appA/u0a705}
    Hist #0: ActivityRecord{4b0a7c5 u0 im.wangchao.appB/.MainActivity t6727}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.appB/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[378,1024][718,1464] }
      ProcessRecord{eb7ffbc 17574:im.wangchao.appB/u0a751}
```
然后我们点击Home键,点击App A,此时的任务栈情况如需啊:
```
Task id #6728
  TaskRecord{6afbd69 #6728 A=im.wangchao.appA U=0 sz=2}
  Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.appA/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #1: ActivityRecord{cb618e7 u0 im.wangchao.appA/.FirstActivity t6728}
      Intent { act=im.wangchao.First cmp=im.wangchao.appA/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{cbfd3ee 19927:im.wangchao.appA/u0a705}
    Hist #0: ActivityRecord{1e25006 u0 im.wangchao.appA/.MainActivity t6728}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.appA/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[34,1024][374,1464] }
Task id #6727
  TaskRecord{b86492e #6727 A=im.wangchao.appB U=0 sz=1}
  Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.appB/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #0: ActivityRecord{f83b11b u0 im.wangchao.appB/.MainActivity t6727}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.appB/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[378,1024][718,1464] }
      ProcessRecord{853f08f 19909:im.wangchao.appB/u0a751}
```
可以看出,之前App A的FirstActivity和App B的MainActivity在同一个任务栈中,然后我们点击Home键,然后进入App A时,此时FirstActivity直接显示在了栈顶(所在的栈为App A),点击Back键回到App A的MainActivity。

### android:alwaysRetainTaskState
### android:clearTaskOnLaunch
这个属性用来标记是否清除该任务栈中除了根Activity的所有Activity,注意这个属性需要给根Activity设置。比如我们三个Activity A,B和C,我们给A设置这个属性为true,A为根Activity,现在我们A启动B,B启动C,此时我们按Home键,然后再次点击该App,此时显示的并非为C,而是A。
### android:finishOnTaskLaunch
如果Activity A的该属性设置为true,启动Activity A后,将Activity A所在的任务栈置为后台,当该任务栈返回前台时,Activity A将会finish。比如我们用之前的例子,将FirstActivity的finishOnTaskLaunch属性设置为true,我们先将三个Activity都启动到任务栈中,也就是启动MainActivity,MainActivity启动FirstActivity,FirstActivity启动SecondActivity,此时任务栈情况如下:
```
Task id #6752
  TaskRecord{dc58c9f #6752 A=im.wangchao.launchemode U=0 sz=3}
  Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
    Hist #2: ActivityRecord{636c92c u0 im.wangchao.launchemode/.SecondActivity t6752}
      Intent { cmp=im.wangchao.launchemode/.SecondActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{fef81ec 11911:im.wangchao.launchemode/u0a705}
    Hist #1: ActivityRecord{65b9b94 u0 im.wangchao.launchemode/.FirstActivity t6752}
      Intent { cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
      ProcessRecord{fef81ec 11911:im.wangchao.launchemode/u0a705}
    Hist #0: ActivityRecord{2f691b8 u0 im.wangchao.launchemode/.MainActivity t6752}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[34,1024][374,1464] }
      ProcessRecord{fef81ec 11911:im.wangchao.launchemode/u0a705}
```
点击Home键后,任务栈情况如下:
```
Task id #6752
      TaskRecord{dc58c9f #6752 A=im.wangchao.launchemode U=0 sz=3}
      Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
        Hist #2: ActivityRecord{636c92c u0 im.wangchao.launchemode/.SecondActivity t6752}
          Intent { cmp=im.wangchao.launchemode/.SecondActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
          ProcessRecord{fef81ec 11911:im.wangchao.launchemode/u0a705}
        Hist #1: ActivityRecord{65b9b94 u0 im.wangchao.launchemode/.FirstActivity t6752}
          Intent { cmp=im.wangchao.launchemode/.FirstActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
          ProcessRecord{fef81ec 11911:im.wangchao.launchemode/u0a705}
        Hist #0: ActivityRecord{2f691b8 u0 im.wangchao.launchemode/.MainActivity t6752}
          Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[34,1024][374,1464] }
          ProcessRecord{fef81ec 11911:im.wangchao.launchemode/u0a705}
```
此时我们再点击该App,任务栈情况如下:
```
Task id #6752
   TaskRecord{dc58c9f #6752 A=im.wangchao.launchemode U=0 sz=2}
   Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} }
     Hist #1: ActivityRecord{636c92c u0 im.wangchao.launchemode/.SecondActivity t6752}
       Intent { cmp=im.wangchao.launchemode/.SecondActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[34,1024][374,1464] }
       ProcessRecord{fef81ec 11911:im.wangchao.launchemode/u0a705}
     Hist #0: ActivityRecord{2f691b8 u0 im.wangchao.launchemode/.MainActivity t6752}
       Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=im.wangchao.launchemode/.MainActivity VirtualScreenParam=Params{mDisplayId=-1, null, mFlags=0x00000000)} bnds=[34,1024][374,1464] }
       ProcessRecord{fef81ec 11911:im.wangchao.launchemode/u0a705}
```
我们发现FirstActivity没了,也就证实了之前说的,设置该属性的Activity,其所在的任务栈再次进入前台时,就会被销毁。

关于其它属性说明参见[官方文档说明]

# 最后
关于启动模式,Intent Flag,和<activity/>暂时先整理这么多,希望对后来人有所帮助,有任何疑问欢迎联系我。

[官方文档说明]: https://developer.android.google.cn/guide/topics/manifest/activity-element.html