---
title: Android Bolts Task 从入门到放弃
date: 2016-09-07 21:14:46
categories: Android
tags: [Android, Android Bolts Task]
---
最近好多人都问我[Bolts-Android]的一些问题,其中主要都是关于__Bolts Task__的,所以先把我对[Bolts-Android]中Task的使用和分析分享一下,希望对后来人有所帮助。

### 1.Bolts Task是什么
简单的理解就是对方便我们使用和管理一些异步任务(线程),它的使用有点类似于JavaScript中的[Promise],废话不多说直接进入正题。本文使用版本为1.4.0。

### 2.下载和使用
#### 2.1下载
下载最新的JAR或者使用Gradle,Gradle依赖如下:
```gradle
dependencies {
  compile 'com.parse.bolts:bolts-tasks:x.x.x' //替换最新的版本号,如1.4.0
}
```

<!--more-->

#### 2.2使用
我们在开发Android项目时,避免不了的就是使用异步任务,那么用__Bolts Task__是如何创建一个异步任务的呢,非常简单代码如下:
```java
        Task.callInBackground(new Callable<String>() {
            @Override public String call() throws Exception {
                //TODO
                return null;
            }
        })
```
只需要在__call__方法中处理你的耗时操作就可以了,在解释这个方法之前,我们需要了解一下__Bolts Task__给我们提供的三个线程执行器:
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
以上代码摘自源码中__Task__类,我们可以从字面意思看出这三个执行器的意义,**BACKGROUND_EXECUTOR**表示任务执行在后台线程,也可以说是工作线程;**IMMEDIATE_EXECUTOR**表示在当前任务创建的线程中执行;**UI_THREAD_EXECUTOR**工作在Android的UI线程。其中**IMMEDIATE_EXECUTOR**会判断当前的线程深度,若嵌套线程过多则会使用**BACKGROUND_EXECUTOR**执行任务,关于**IMMEDIATE_EXECUTOR**的判断将在后面的源码分析中解释,这里不做过多的说明。当然这三个执行器是默认提供的,我们也可以自定义一些我们自己需要的执行器,继承__Executor__即可。

了解了这三个执行器后,我们在回来看刚才的__callInBackground__方法就很好理解了,这个方法使用的执行器就是**BACKGROUND_EXECUTOR**,__callInBackground__方法中的__Callable<T>__参数可以把它看作__Runnable__接口,只不过__Runnable__中的__run__方法返回类型为Void而且不抛出异常。当然__Callable<T>__的__call__方法的返回值和抛出去的异常都是有用的,我们后面会说到。

关于_Bolts Task_的使用,我自己简单的分为如下三大类:
 * __Execute__
    主要包括__call__方法,__callInBackground__方法和__delay__方法,都为静态方法;
 * __ContinueExecute__
    主要包括__continueWith__方法,__continueWithTask__方法,__onSuccess__方法,__onSuccessTask__方法和__continueWhile__方法;
 * __CombineExecute__
    主要包括__whenAll__方法,__whenAllResult__方法,__whenAny__方法和__whenAnyResult__方法。
    
接下来我们将逐一说明
##### call
__call__方法的作用就是使用指定的执行器执行__Callable<TResult>__接口,该方法有四个重载方法如下:
```java
  public static <TResult> Task<TResult> call(final Callable<TResult> callable, Executor executor) {
    ...
  }

  public static <TResult> Task<TResult> call(final Callable<TResult> callable, Executor executor,
      final CancellationToken ct) {
    ...
  }

  public static <TResult> Task<TResult> call(final Callable<TResult> callable) {
    ...
  }

  public static <TResult> Task<TResult> call(final Callable<TResult> callable, CancellationToken ct) {
    ...
  }

```
其中第一个参数都是__Callable<TResult>__,前面有说过这里就不在过多说明,其中__Executor__参数用于执行__Callable<TResult>__接口决定了该任务的执行线程,可以传自定义的执行器也可以传我们自定义的执行器,不传执行器的方法执行器默认为**BACKGROUND_EXECUTOR**执行器,__CancellationToken__参数用于取消该Task,相关示例如下:
```java
//#1 执行在BACKGROUND_EXECUTOR执行器中
Task.call(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        //Todo
        return null;
    }
});

//#2 执行在UI_THREAD_EXECUTOR执行器中
Task.call(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        //Todo
        return null;
    }
}, Task.UI_THREAD_EXECUTOR);

//#3 执行在BACKGROUND_EXECUTOR执行器中,可以通过source取消该Task
CancellationTokenSource source = new CancellationTokenSource();
Task.call(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        //Todo
        return null;
    }
}, source.getToken());
...
source.cancel();

//#4 执行在UI_THREAD_EXECUTOR执行器中,可以通过cts取消该Task
CancellationTokenSource cts = new CancellationTokenSource();
Task.call(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        //Todo
        return null;
    }
}, Task.UI_THREAD_EXECUTOR, cts.getToken());
...
cts.cancel();
```
__Executor__参数和__CancellationToken__参数在别的方法中传递作用相同,在说明其他方法时将不再过多赘述。

##### callInBackground 和 delay
__callInBackground__和__call__方法相同,只不过执行器固定为**BACKGROUND_EXECUTOR**。
__delay__则是延迟执行任务,参数单位为毫秒,一般和__ContinueExecute__类型方法一起使用,示例如下:
```java
//延迟1000毫秒后,执行Todo
Task.delay(1000).continueWith(new Continuation<Void, Object>() {
    @Override
    public Object then(Task<Object> task) throws Exception {
        //Todo
        return null;
    }
});
```

##### continueWith
首先__continueWith__可以理解为给Task设置回调的方法,该方法主要参数为__Continuation<TResult, TContinuationResult>__接口,该接口中有一个__then__方法在Task执行完成后执行该方法,当然该方法也有__Execute__和__CancellationToken__方法,它们的作用相同只不过是用于处理__Continuation<TResult, TContinuationResult>__接口的__then__方法的,在__then__方法中我们可以判断Task的成功失败或者取消,如下:
```java
Task.call(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        //Todo
        return null;
    }
}).continueWith(new Continuation<Object, Void>() {
    @Override
    public Void then(Task<Object> task) throws Exception {
        if (task.isCancelled()) {
          // 任务已取消。
        } else if (task.isFaulted()) {
          // 任务失败,使用getError()方法获取异常。
          Exception error = task.getError();
        } else {
          // 任务执行成功,使用getResult()方法获取返回值,该返回值也就是上面Callable中call()中的返回值,所以下面得到的值为null。
         Object object = task.getResult();
        }
        return null;
    }
});
```
观察细心的同学会发现__Continuation<TResult, TContinuationResult>__接口中的__then__方法也有返回值,其返回类型为该接口泛型的_TContinuationResult_类型,__then__方法传递的参数为当前执行结束的Task<TResult>。刚才我们说__continueWith__方法是可以理解为设置Task回调的方法,其实该方法中新创建了一个Task并返回,也就是说__continueWith__方法也会返回一个Task,这个Task的泛型就是__Continuation<TResult, TContinuationResult>__接口中__then__方法的返回类型,也就是_TContinuationResult_,所以__then__方法中即可以处理上一个Task的结果也可以当成一个新Task的__Callable__接口中的__call__方法使用,当然新Task的执行时机就是上一个Task执行结束后执行,也就是形成了线程同步执行任务,就像我上面说的__then__方法的执行器可以自定义,是否需要取消当然也是在__continueWith__方法中是否传递__CancellationToken__实现了。

所以我们可以通过该方法实现任务链,如下:
```java
Task.call(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        // 执行任务1
        return null;
    }
}).continueWith(new Continuation<Object, Object>() {
    @Override
    public Object then(Task<Object> task) throws Exception {
        // 执行任务2
        return null;
    }
}).continueWith(new Continuation<Object, Object>() {
      @Override
      public Object then(Task<Object> task) throws Exception {
          // 执行任务3
          return null;
      }
});
```
##### continueWithTask
__continueWithTask__方法和__continueWith__方法使用基本相同,方法参数我就不做过多说明了,主要说一下它们的区别。从方法名字上可以看出,__continueWithTask__比__continueWith__多了一个Task,所以是不是方法中执行也多一个Task呢,可以先暂时这样理解,首先__continueWith__参数__Continuation<TResult, TContinuationResult>__接口中__then__方法的返回类型为_TContinuationResult_类型,__continueWithTask__方法中的__Continuation__参数稍有不同,为__Continuation<TResult, Task<TContinuationResult>>__,所以该__Continuation__接口的__then__方法的返回类型是一个__Task<TContinuationResul>__,这就是这两个方法的主要区别,那么这个区别带来了什么样的效果呢,看下面的例子:
```java
//#1.continueWith
Task.callInBackground(new Callable<String>() {
    @Override public String call() throws Exception {
        log("callInBackground");
        return null;
    }
}).continueWith(new Continuation<String, String>() {
    @Override public String then(Task<String> task) throws Exception {
        log("continueWith: TODO");
        return null;
    }
}).continueWith(new Continuation<String, Object>() {
    @Override public Object then(Task<String> task) throws Exception {
        log("continueWith: finish");
        return null;
    }
});
        
//#2.continueWithTask
Task.callInBackground(new Callable<String>() {
    @Override public String call() throws Exception {
        log("callInBackground");
        return null;
    }
}).continueWithTask(new Continuation<String, Task<Object>>() {
    @Override public Task<Object> then(Task<String> task) throws Exception {
        log("continueWithTask: TODO");
        return Task.call(new Callable<Object>() {
           @Override public Object call() throws Exception {
               log("continueWithTask: doTask");
               return null;
           }
        });
    }
}).continueWith(new Continuation<Object, Object>() {
    @Override public Object then(Task<Object> task) throws Exception {
        log("continueWithTask: finish");
        return null;
    }
});
```
__continueWith__示例的log打印顺序为:
__log("callInBackground");__->__log("continueWith: TODO");__->__log("continueWith: finish");__
__continueWithTask__示例的log打印顺序为:
__log("callInBackground");__->__log("continueWithTask: TODO");__->__log("continueWithTask: doTask");__->__log("continueWithTask: finish");__

第一个__continueWith__的log打印顺序通过之前的讲解应该已经了解了,主要看一下__continueWithTask__的log,直接看__log("continueWithTask: doTask");__这条log,该log打印在__then__方法返回的Task中,我们通过log的打印顺序可以发现doTask这条log打印完成后才打印最后的finish,所以在使用__continueWithTask__方法的时候,该方法返回的Task(我们签名说过__continueWith__方法里面会新创建一个Task并返回,__continueWithTask__同理)在__then__方法返回的Task完成后才会完成,它的执行原理后面在进行源码分析时会说到。

所以现在好理解了,这两方法的区别主要就是__then__返回一个返回的是Object一个返回的是Task,而在进行链式调用时,需要等待返回的Task执行结束后才会继续执行后面的__continueWith__或__continueWithTask__等方法。当然如果在使用__continueWithTask__方法时,__then__方法返回的Task为null,那么它的执行效果和__continueWith__是相同的。

##### onSuccess 和 onSuccessTask
__onSuccess__和__onSuccessTask__类似于上面说的__continueWith__和__continueWithTask__,只不过__onSuccess__和__onSuccessTask__的__Continuation__参数是否执行取决于Task是否成功,如下:
```java
//#1
Task.call(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        //正常执行
        return null;
    }
}).onSuccess(new Continuation<Object, Object>() {
    @Override
    public Object then(Task<Object> task) throws Exception {
        //正常执行
        return null;
    }
});

//#2
Task.call(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        //抛出异常
        if(true){
           throw new RuntimeException();
        }
        return null;
    }
}).onSuccess(new Continuation<Object, Object>() {
    @Override
    public Object then(Task<Object> task) throws Exception {
        //不执行,因为Task抛出了异常
        return null;
    }
});
```
第一个例子的__onSuccess__方法中的__then__方法会正常调用,而第二个例子中__onSuccess__中的__then__方法就不会执行,因为其Task抛出了异常,当然刚才说到__onSuccess__方法只有在成功时候才会调用,也就是说Task被取消或者Task抛出异常的情况都不会调用。__onSuccessTask__同理在这里就不再过多说明了。

##### continueWhile
__Bolts Task__中还提供了一个循环方法,类似于__while__方法,该方法为__continueWhile__,直接看例子:
```java
int i = 0;
//Task.forResult() 方法返回一个执行成功的Task,后面会说到。
Task.forResult(null).continueWhile(new Callable<Boolean>() {
    @Override
    public Boolean call() throws Exception {
        i++;
        log("call : " + i);
        return i != 4;
    }
    }, new Continuation<Void, Task<Void>>() {
    @Override
    public Task<Void> then(Task<Void> task) throws Exception {
        log("do then");
        return null;
    }
}).continueWith(new Continuation<Void, Object>() {
    @Override
    public Object then(Task<Void> task) throws Exception {
        log("finish");
        return null;
    }
});
```
例子中log的打印为:
```
09-10 08:19:24.410 32611-32611/im.wangchao.m E/wcwcwc: call : 1
09-10 08:19:24.410 32611-32611/im.wangchao.m E/wcwcwc: do then
09-10 08:19:24.410 32611-32611/im.wangchao.m E/wcwcwc: call : 2
09-10 08:19:24.410 32611-32611/im.wangchao.m E/wcwcwc: do then
09-10 08:19:24.410 32611-32611/im.wangchao.m E/wcwcwc: call : 3
09-10 08:19:24.410 32611-32611/im.wangchao.m E/wcwcwc: do then
09-10 08:19:24.410 32611-32611/im.wangchao.m E/wcwcwc: call : 4
09-10 08:19:24.410 32611-32611/im.wangchao.m E/wcwcwc: finish
```
是不是看明白了,__call__方法返回一个__Boolean__值用于判断是否需要继续循环,__then__则是循环体,如果__call__返回_true_那么就执行__then__方法,如果返回false,那么执行结束。相信你已经看到后面的__continueWith__方法了,我们前面说过__continueWith__可以当作__callback__来使用,所以在此的作用为监听循环时间结束。

##### whenAll 和 whenAllResult
__whenAll__方法和__whenAllResult__方法的功能是处理并发Task的,它们接收一个__Collection<? extends Task<?>>__参数,也就是需要并发的Task,我们直接看例子:
```java
//任务 a
Task<Object> a = Task.callInBackground(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        log("Task a.");
        return null;
    }
});

//任务 b
Task<Object> b = Task.callInBackground(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        SystemClock.sleep(2000);
        log("Task b.");
        return null;
    }
});

List<Task<Object>> list = Arrays.asList(a, b);

//#1
Task.whenAll(list).continueWith(new Continuation<Void, Object>() {
    @Override
    public Object then(Task<Void> task) throws Exception {
        log("whenAll finish.");
        return null;
    }
});

//#2
Task.whenAllResult(list).continueWith(new Continuation<List<Object>, Object>() {
    @Override
    public Object then(Task<List<Object>> task) throws Exception {
        List<Object> temp = task.getResult();
        return null;
    }
});
```
我们先来说__whenAll__方法,打印的log如下:
```
09-10 08:37:57.140 18311-18912/im.wangchao.m E/wcwcwc: Task a.
09-10 08:37:59.150 18311-18913/im.wangchao.m E/wcwcwc: Task b.
09-10 08:37:59.150 18311-18913/im.wangchao.m E/wcwcwc: whenAll finish.
```
我们看出任务a和任务b执行完成后,才会调用__then__方法,也就是说,当我们有多个并发任务时,就可以使用该方法处理,可以方便监听所有并发任务结束的事件。刚刚例子中__#1__里面__then__方法返回的事__Task<Void>__,而__#2__中__then__方法返回的则是__Task<List<Object>>__,所以__whenAllResult__和__whenAll__的区别是__whenAllResult__能在结束的监听中得到每个并发Task的返回值,可以看出__whenAllResult__返回Task的result为一个List,该List里面存储之前并发Task的返回值,和之前传入Task的List的索引是一一对应的。

##### whenAny 和 whenAnyResult
这两个方法比较简单,和__whenAll__那两个方法类似,也是接收__Collection<? extends Task<?>>__参数,处理并发Task,只不过__whenAll__和__whenAllResult__是在所有并发结束后才会继续执行,而__whenAny__和__whenAnyResult__则是并发的Task中只要有一个Task结束后,就会继续执行后面的操作,直接看例子:
```java
//任务 a
Task<Object> a = Task.callInBackground(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        log("Task a.");
        return "Task a";
    }
});

//任务 b
Task<Object> b = Task.callInBackground(new Callable<Object>() {
    @Override
    public Object call() throws Exception {
        SystemClock.sleep(2000);
        log("Task b.");
        return "Task b";
    }
});

List<Task<Object>> list = Arrays.asList(a, b);

//#1
Task.whenAny(list).continueWith(new Continuation<Task<?>, Object>() {
    @Override
    public Object then(Task<Task<?>> task) throws Exception {
        log("whenAny : " + task.getResult().getResult());
        return null;
    }
});

//#2
Task.whenAnyResult(list).continueWith(new Continuation<Task<Object>, Object>() {
    @Override
    public Object then(Task<Task<Object>> task) throws Exception {
        log("whenAnyResult : " + task.getResult().getResult());
        return null;
    }
});
```
log结果如下:
```
09-10 09:04:43.670 10473-11726/im.wangchao.m E/wcwcwc: Task a.
09-10 09:04:43.670 10473-10473/im.wangchao.m E/wcwcwc: whenAny : Task a
09-10 09:04:43.670 10473-10473/im.wangchao.m E/wcwcwc: whenAnyResult : Task a
09-10 09:04:45.680 10473-11727/im.wangchao.m E/wcwcwc: Task b.
```
只要有任意一个Task结束后就会执行后面的__continueWith__方法,当然__whenAny__和__whenAnyResult__方法也有不同的地方,通过上面的例子也不难发现,__whenAny__方法在回调__then__方法时候返回的Task是未知类型,而__whenAnyResult__则是已知类型。

##### 其它方法
__Bolts Task__还提供了一些其它快捷的方法:
 * Task.forError(Exception) 提供一个已经完成的异常Task,接收一个Exception参数。
 * Task.forResult(TResult) 提供一个已经完成的成功Task,接受一个TResult参数,也就是Result的泛型。

当然还有就是,我们如果自己创建一个Task怎么做呢:
```java
TaskCompletionSource<Object> tcs = new TaskCompletionSource<>();
//tcs.setResult(null);
//tcs.setError(new Exception());
//tcs.setCancelled();

tcs.getTask();
```
我们可以实例一个__TaskCompletionSource<TResult>__对象(注意该对象为bolts.TaskCompletionSource<TResult>),如果我们需要一个成功的Task,那么调用__setResult()__方法并传入一个Result,如果需要一个异常Task,那么调用__setError()__方法并传入一个异常,如果需要一个已经取消的Task,那么调用__setCancelled()__方法即可。

### 3.最后
关于__Bolts Task__的用法就先写到这,后面会在写一篇关于__Bolts Task__的源码分析,希望能给初学者带来一些帮助。

[Bolts-Android]: https://github.com/BoltsFramework/Bolts-Android
[JAR]: https://search.maven.org/remote_content?g=com.parse.bolts&a=bolts-tasks&v=LATEST
[Promise]: https://github.com/then/promise