---
title: Android Bolts Task 从入门到放弃
date: 2016-09-07 21:14:46
categories: Android
tags: [Android, Android-Bolts-Task]
---
最近好多人都问我[Bolts-Android]的一些问题,其中主要都是关于_Bolts Task_的,所以先把我对[Bolts-Android]中Task的使用和分析分享一下,希望对后来人有所帮助。

## 1.Bolts Task是什么
简单的理解就是对方便我们使用和管理一些异步任务(线程),它的使用有点类似雨JavaScript中的[Promise],废话不多说直接进入正题。

## 2.下载和使用
#### 2.1下载
下载最新的JAR或者使用Gradle,Gradle依赖如下:
```gradle
dependencies {
  compile 'com.parse.bolts:bolts-tasks:1.4.0'
}
```
#### 2.2使用
我们在开发Android项目时,避免不了的就是使用异步任务,那么用_Bolts Task_是如何创建一个异步任务的呢,非常简单代码如下:
```java
        Task.callInBackground(new Callable<String>() {
            @Override public String call() throws Exception {
                //TODO
                return null;
            }
        })
```
只需要在_call_方法中处理你的耗时操作就可以了,在解释这个方法之前,我们需要了解一下_Bolts Task_给我们提供的三个线程执行器:
```java
 /**
   * An {@link java.util.concurrent.Executor} that executes tasks in parallel.
   */
  public static final ExecutorService BACKGROUND_EXECUTOR = BoltsExecutors.background();

  /**
   * An {@link java.util.concurrent.Executor} that executes tasks in the current thread unless
   * the stack runs too deep, at which point it will delegate to {@link Task#BACKGROUND_EXECUTOR} in
   * order to trim the stack.
   */
  private static final Executor IMMEDIATE_EXECUTOR = BoltsExecutors.immediate();

  /**
   * An {@link java.util.concurrent.Executor} that executes tasks on the UI thread.
   */
  public static final Executor UI_THREAD_EXECUTOR = AndroidExecutors.uiThread();
```
以上代码摘自源码中_Task_类,我们可以从字面意思看出这三个执行器的意义,*BACKGROUND_EXECUTOR*表示任务执行在后台线程,也可以说是工作线程;*IMMEDIATE_EXECUTOR*表示在当前任务创建的线程中执行;*UI_THREAD_EXECUTOR*工作在Android的UI线程。其中*IMMEDIATE_EXECUTOR*会判断当前的线程深度,若嵌套线程过多则会使用*BACKGROUND_EXECUTOR*执行任务,关于*IMMEDIATE_EXECUTOR*的判断将在后面的源码分析中解释,这里不做过多的说明。
  

[Bolts-Android]: https://github.com/BoltsFramework/Bolts-Android
[JAR]: https://search.maven.org/remote_content?g=com.parse.bolts&a=bolts-tasks&v=LATEST
[Promise]: https://github.com/then/promise