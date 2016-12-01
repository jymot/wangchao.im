---
title: Java,Android动态代理你需要知道的一些事
date: 2016-10-19 12:07:24
categories: Java
tags: [Android, Java]
---
### 代理模式
首先,什么是代理,拿出你的手机,打开微信朋友圈,看看朋友圈的微商,这就是代理。代理就是一个对象代表代表另一个对象做其需要做的事,就像刚才说的微商,你的朋友就是代理了原厂商。现在大概知道了代理是什么,那么Android中有哪些代理呢,举个最简单的例子,我们都知道__Context__,__Context__就是使用了代理模式,__ContextImpl__实现了__Context__的所有功能,__ContextWrapper__即为代理类,也实现了__Context__类,里面包含的__Context__引用为__ContextImpl__,所以__ContextWrapper__调用的方法都是__ContextImpl__中的实现,这就是典型的代理模式。

<!--more-->

### 动态代理
我们知道代理模式需要自己创建代理类,代理所有方法,简单的说,这就是静态代理,上述的__Context__的代理模式就是静态代理。那么动态代理是什么,简单的说就是不需要自己创建代理类,而是动态生成。废话不多说直接上代码,首先先创建一个接口抽象出需要的所有功能:
```java
public interface Action{
    void doWork();
}
```
接口很简单,只有一个方法__doWork()__,接下来我们创建委托类,也就是具体实现功能的类:
```java
public class RealAction implements Action{
    @Override public void doWork() {
        Log.e("wcwcwc", "RealAction : doWork()");
    }
}   
```
接下来就是我们的今天的重点了,创建代理处理器,我们需要创建一个实现__InvocationHandler__接口的类,如下:
```java
public class TestDynamicProxy implements InvocationHandler {
    @Override public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        Log.e("wcwcwc", "proxy: " + proxy.getClass().getCanonicalName() + "\n" +
                        "method: " + method + "\n" +
                        "args: " + args);
        return null;
    }
}
```
先不解释这个类,直接看怎么使用,代码如下:
```java
Action action = (Action) Proxy.newProxyInstance(RealAction.class.getClassLoader(), new Class[]{Action.class}, new TestDynamicProxy());
action.doWork();
```
此时,我们就完成了一次动态代理调用,但是上面的代码是有问题的,现在就相当于使用没有给__ContextWrapper__传入__ContextImpl__的__ContextWrapper__,也就是说缺少委托。对于上面的例子来说就是缺少__RealAction__类的引用,对代码做如下修改:
```java
public class TestDynamicProxy implements InvocationHandler {
    Object target;
    public TestDynamicProxy(Object target){
        this.target = target;
    }
    @Override public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        Log.e("wcwcwc", "proxy: " + proxy.getClass().getCanonicalName() + "\n" +
                        "method: " + method + "\n" +
                        "args: " + args);
        Object result = method.invoke(target, args);
        return result;
    }
}
```
```java
RealAction realAction = new RealAction();
Action action = (Action) Proxy.newProxyInstance(RealAction.class.getClassLoader(), new Class[]{Action.class}, new TestDynamicProxy(realAction));
action.doWork();
```
如上所示,我们下面执行__action.doWork()__后,就会打印__RealAction : doWork()__也就是__RealAction__中__doWork()__方法的实现。下面我们逐一说明一下每个方法的作用。

我们先看上面修改后的__TestDynamicProxy__代理类,它实现了__InvocationHandler__接口的__invoke__方法,该方法有三个参数,返回值为__Object__,其中第一个参数为动态生成的代理类对象,第二个参数为当前执行的方法,第三个参数为当前执行方法的参数,返回值当然就是当前执行方法的返回值了,所以就上上面代码一样,__target__就是委托,所以调用代理类的方法时候,调用__target__的相关方法,也就是执行__TestDynamicProxy__类中第10行的代码。

然后在看下面的__Proxy.newProxyInstance()__方法,这个方法主要是生成代理类,所以我们可以把它强转为__Action__。这个方法也有三个参数,第一个参数为类加载器,第二个是代理类需要实现的所有接口,第三个参数为__InvocationHandler__。我们在第三个参数中传入了__RealAction__类的引用,达到了最终的动态代理效果。我们就可以肯据自己的业务需求在执行代理方法前或者后做相关的操作了,也就是在__invoke__方法中实现。

### $Proxy0
__$Proxy0__是什么,__$Proxy0__就是动态生成的代理类,该类继承__Proxy__,并实现__newProxyInstance()__第二个方法的所有接口。该代理类反射了所有实现接口的方法,在调用目标方法时,调用__InvocationHandler__的__invoke()__方法,传入相关参数,因为该类继承__Proxy__,__Proxy__中有__InvocationHandler__成员变量,该变量在实例化的时候被赋值所以__$Proxy0__就可以调用__InvocationHandler__的__invoke__方法了。

值得注意的是,__$Proxy0__类除了反射实现接口的所有方法,还反射了__java.lang.Object__的__equals__方法,__hashCode__方法和__toString__方法,并和实现的接口一样,重写这三个方法,在方法体中通过__InvocationHandler__调用__invoke()__并传入反射的__method__。所以我们在测试动态代理代码的时候,切记不要调用这几个方法,比如在__InvocationHandler__的__invoke()__方法中不要调用类似如下的代码:
```java
Log.e("wcwcwc", "proxy: " + proxy);
```
因为上述方法会调用__proxy__的__toString__方法,上面我们说了__toString__方法也会调用__invoke__方法,所以就会出现死循环,因为__newProxyInstance__最终会调用__JNI__的__generateProxy__方法,所以可能会出现类似__JNI local reference table overflow (max=512)__的异常,也就是JNI局部引用表溢出的异常。