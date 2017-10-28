---
title: Android 组件之 Lifecycle
date: 2017-10-28 09:13:00
categories: [Android]
tags: [Android]
---

最近更新了Android Studio 3.0 Stable版本，发现`Support 26.+`版本默认依赖了`Android Architecture Components`中的`Lifecycle`，接下来主要对`Lifecycle`这个组件进行简单的介绍以及自己对于该组件实现的一些分析，话不多少直接进入正题。

## 使用
#### 介绍
在说使用之前，先简单解释一下这个组件的作用，从它的名字上基本就能大概的了解到，这个组件是为了监听比如我们的`Activity`或者`Fragment`的生命周期的，可以让我们在开发中很容易给`ViewModel`(MVVM模式)或者`Presenter`(MVP模式)增加生命周期，接下来开始讲它简单的用法。

#### 开始
首先我们的`Activity`或者`Fragment`要实现`LifecycleOwner`接口，也就是说具有生命周期的组件来实现这个接口
```java
/**
 * A class that has an Android lifecycle. These events can be used by custom components to
 * handle lifecycle changes without implementing any code inside the Activity or the Fragment.
 *
 * @see Lifecycle
 */
public interface LifecycleOwner {
    /**
     * Returns the Lifecycle of the provider.
     *
     * @return The lifecycle of the provider.
     */
    Lifecycle getLifecycle();
}
```
可以看到，这个接口返回了一个`Lifecycle`对象，也就是生命周期的提供者，当然这里我们不用自己去实现，`Support`包中的`Activity`和`Fragment`中已经帮我们实现了这个接口，后面的实现分析会详细的说明`Support`包中具体是如何实现的。

<!--more-->

所以就可以在我们的`Activity`或者`Fragment`中直接`getLifecycle()`来获得我们的`Lifecycle`对象了，`Lifecycle`是一个抽象类，里面有三个抽象方法
```java
 /**
     * Adds a LifecycleObserver that will be notified when the LifecycleOwner changes
     * state.
     * <p>
     * The given observer will be brought to the current state of the LifecycleOwner.
     * For example, if the LifecycleOwner is in {@link State#STARTED} state, the given observer
     * will receive {@link Event#ON_CREATE}, {@link Event#ON_START} events.
     *
     * @param observer The observer to notify.
     */
    @MainThread
    public abstract void addObserver(LifecycleObserver observer);

    /**
     * Removes the given observer from the observers list.
     * <p>
     * If this method is called while a state change is being dispatched,
     * <ul>
     * <li>If the given observer has not yet received that event, it will not receive it.
     * <li>If the given observer has more than 1 method that observes the currently dispatched
     * event and at least one of them received the event, all of them will receive the event and
     * the removal will happen afterwards.
     * </ul>
     *
     * @param observer The observer to be removed.
     */
    @MainThread
    public abstract void removeObserver(LifecycleObserver observer);

    /**
     * Returns the current state of the Lifecycle.
     *
     * @return The current state of the Lifecycle.
     */
    @MainThread
    public abstract State getCurrentState();
```
可以看到这三个抽象方法都是运行在主线程中的，上面的注释很清楚，这里就不做过多解释了。所以我们可以调用`addObserver(LifecycleObserver)`方法来增加观察者，也就是我们需要监听生命周期的类，比如`ViewModel`和`Presenter`。但是我们发现这个方法需要的参数是一个`LifecycleObserver`对象，所以需要给我们的`ViewModel`或者`Presenter`类增加实现这个接口，下面是`LifecycleObserver`类
```java
/**
 * Marks a class as a LifecycleObserver. It does not have any methods, instead, relies on
 * {@link OnLifecycleEvent} annotated methods.
 * <p>
 * @see Lifecycle Lifecycle - for samples and usage patterns.
 */
@SuppressWarnings("WeakerAccess")
public interface LifecycleObserver {

}
```
可以看到这个接口没有需要实现的方法，它仅仅是起到标记的作用，说到这里，我们对于生命周期监听的准备工作就已经做完了，接下来就可以开始监听我们需要的生命周期了，比如我们需要监听`onStart`，那么我们可以这样定义我们的类
```java
public class ViewModel implements LifecycleObserver{

    @OnLifecycleEvent(Lifecycle.Event.ON_START) public void onStart(){
        Log.e("wcwcwc", "onStart");
    }
}
```
这样就可以在我们的`ViewModel`类中监听到`onStart`事件了。

#### 小结
在这里简单做一个小结

 1. 首先我们的`Activity`或者`Fragment`继承`Support`中的`Activity`和`Fragment`（当然你也可以自己实现，那么就需要看后面的实现分析了）
 2. 然后创建我们的观察者类，也就是实现`LifecycleObserver`接口的类，比如上面的`ViewModel`类
 3. 关联，调用`Activity`或者`Fragment`中的`getLifecycle()`方法得到`Lifecycle`对象，然后调用`addObserver`方法，也就是`getLifecycle().addObserver(new ViewModel())`，这里的`ViewModel`就是上面的示例类，需要注意的是，我们要记得在适当的时候调用`removeObserver(LifecycleObserver)`方法来移除我们的观察者，从而避免内存溢出
 4. 接下来就可以监听我们需要的生命周期方法了，比如上面的`onStart`方法（这个方法名随意，只需要添加OnLifecycleEvent注解既可）
 
当然，上面的`onStart`方法中也可以有一个参数就像这样
```java
public class ViewModel implements LifecycleObserver{

    @OnLifecycleEvent(Lifecycle.Event.ON_START) public void onStart(LifecycleOwner owner){
        Log.e("wcwcwc", "onStart");
    }
}
```
还记得开始我说过，要给具有生命周期的组件实现`LifecycleOwner`接口么，不难猜出，这个`owner`就是我们当前监听生命周期的`Activity`或者`Fragment`的引用。当然如果我们需要监听所有的生命周期方法，我们不需要对每一个周期对应写一个方法，只需要做一个全局的监听既可
```java
public class ViewModel implements LifecycleObserver{

    @OnLifecycleEvent(Lifecycle.Event.ON_START) public void onStart(LifecycleOwner owner){
        Log.e("wcwcwc", "onStart");
    }
    
    @OnLifecycleEvent(Lifecycle.Event.ON_ANY) public void any(LifecycleOwner owner, Lifecycle.Event event){
        Log.e("wcwcwc", "any >>> " + event);
    }
}
```
看到上面的`any`方法，可以通过判断`event`参数来判断当前的生命周期，这里需要注意，比如生命周期回调`onStart`时，上面的打印日志如下
```
10-28 09:56:36.123 7311-7311/xxx E/wcwcwc: onStart
10-28 09:56:36.123 7311-7311/xxx E/wcwcwc: any >>> ON_START
```
可以看出，我们单独监听的生命周期会在`Event.ON_ANY`的前面执行。

`Lifecycle`组件为我们提供了如下生命周期事件
```java
/**
 * Constant for onCreate event of the {@link LifecycleOwner}.
 */
ON_CREATE,
/**
 * Constant for onStart event of the {@link LifecycleOwner}.
 */
ON_START,
/**
 * Constant for onResume event of the {@link LifecycleOwner}.
 */
ON_RESUME,
/**
 * Constant for onPause event of the {@link LifecycleOwner}.
 */
ON_PAUSE,
/**
 * Constant for onStop event of the {@link LifecycleOwner}.
 */
ON_STOP,
/**
 * Constant for onDestroy event of the {@link LifecycleOwner}.
 */
ON_DESTROY,
/**
 * An {@link Event Event} constant that can be used to match all events.
 */
ON_ANY
```
这些事件的触发是根据`Lifecycle`的状态触发的，在下面的分析中会着重说明。

## 分析
接下来我们从获取`Lifecycle`对象开始，分析这个组件是如何实现的。
首先我们找到`Support`中的`Activity`或`Fragment`，发现类实现了`LifecycleOwner`接口，如下
```java
    ...

    LifecycleRegistry mLifecycleRegistry = new LifecycleRegistry(this);

    @Override
    public Lifecycle getLifecycle() {
        return mLifecycleRegistry;
    }
    
    ...
```
只提取主要部分，看到了`getLifecycle`方法返回了一个`LifecycleRegistry`对象，按照上面讲的调用顺序，获取`Lifecycle`引用后，要调用它的`addObserver`方法来添加观察者，所以我们看下`LifecycleRegistry`这个类对于这个方法的实现
```java
    @Override
    public void addObserver(LifecycleObserver observer) {
        State initialState = mState == DESTROYED ? DESTROYED : INITIALIZED;
        ObserverWithState statefulObserver = new ObserverWithState(observer, initialState);
        ObserverWithState previous = mObserverMap.putIfAbsent(observer, statefulObserver);

        if (previous != null) {
            return;
        }

        boolean isReentrance = mAddingObserverCounter != 0 || mHandlingEvent;

        State targetState = calculateTargetState(observer);
        mAddingObserverCounter++;
        while ((statefulObserver.mState.compareTo(targetState) < 0
                && mObserverMap.contains(observer))) {
            pushParentState(statefulObserver.mState);
            statefulObserver.dispatchEvent(mLifecycleOwner, upEvent(statefulObserver.mState));
            popParentState();
            // mState / subling may have been changed recalculate
            targetState = calculateTargetState(observer);
        }

        if (!isReentrance) {
            // we do sync only on the top level.
            sync();
        }
        mAddingObserverCounter--;
    }

```
简单分析下这个方法，重点看下`4，5`两行，这里创建了一个`ObserverWithState`类，这个类中保存着初始化状态和我们的`LifecycleObserver`引用（也就是用法中的ViewModel类），创建完成后，会把`ObserverWithState`的引用保存在一个`Map`中，这里避免了相同观察者的重复添加。

然后看一下`ObserverWithState`类
```java
static class ObserverWithState {
        State mState;
        GenericLifecycleObserver mLifecycleObserver;

        ObserverWithState(LifecycleObserver observer, State initialState) {
            mLifecycleObserver = Lifecycling.getCallback(observer);
            mState = initialState;
        }

        void dispatchEvent(LifecycleOwner owner, Event event) {
            State newState = getStateAfter(event);
            mState = min(mState, newState);
            mLifecycleObserver.onStateChanged(owner, event);
            mState = newState;
        }
    }
```
这个类很简单，一个构造方法，一个实例方法，从名字上可以猜到这个`dispatchEvent`方法就是进行事件调度的，这里我们先重点看下构造方法中的第一行，也就是将我们的传递的`LifecycleObserver`对象通过`Lifecycling.getCallback`方法转化成了`GenericLifecycleObserver`的引用，下来看下`GenericLifeObserver`类
```java
/**
 * Internal class that can receive any lifecycle change and dispatch it to the receiver.
 * @hide
 */
@SuppressWarnings({"WeakerAccess", "unused"})
public interface GenericLifecycleObserver extends LifecycleObserver {
    /**
     * Called when a state transition event happens.
     *
     * @param source The source of the event
     * @param event The event
     */
    void onStateChanged(LifecycleOwner source, Lifecycle.Event event);
}
```
这个接口继承了`LifecycleObserver`接口，主要是用来将接收生命周期状态来调度我们的观察者的。接下来我们看下刚刚的`Lifecycling.getCallback`方法是如何实例`GenericLifecycleObserver`对象的
```java
    @NonNull
    static GenericLifecycleObserver getCallback(Object object) {
        if (object instanceof GenericLifecycleObserver) {
            return (GenericLifecycleObserver) object;
        }
        //noinspection TryWithIdenticalCatches
        try {
            final Class<?> klass = object.getClass();
            Constructor<? extends GenericLifecycleObserver> cachedConstructor = sCallbackCache.get(
                    klass);
            if (cachedConstructor != null) {
                return cachedConstructor.newInstance(object);
            }
            cachedConstructor = getGeneratedAdapterConstructor(klass);
            if (cachedConstructor != null) {
                if (!cachedConstructor.isAccessible()) {
                    cachedConstructor.setAccessible(true);
                }
            } else {
                cachedConstructor = sREFLECTIVE;
            }
            sCallbackCache.put(klass, cachedConstructor);
            return cachedConstructor.newInstance(object);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        } catch (InstantiationException e) {
            throw new RuntimeException(e);
        } catch (InvocationTargetException e) {
            throw new RuntimeException(e);
        }
    }
```
先整体看一下，这里是通过反射实例`GenericLifecycleObserver`对象的，并且这个目标类是的构造方法是有一个参数的，回顾上面调用这个方法时传递的参数，得知这个参数就是我们自己创建实现`LifecycleObserver`的类（用法中说到的ViewModel），接着看这个方法的实现，里面有一些缓存的处理和设置构造方法可以访问的处理应该都很好理解，主要看下`14-21`行的代码，其中调用了`getGeneratedAdapterConstructor`方法，来获取实现`GenericLifecycleObserver`接口类的构造方法
```java
 @Nullable
    private static Constructor<? extends GenericLifecycleObserver> getGeneratedAdapterConstructor(
            Class<?> klass) {
        Package aPackage = klass.getPackage();
        final String fullPackage = aPackage != null ? aPackage.getName() : "";

        String name = klass.getCanonicalName();
        // anonymous class bug:35073837
        if (name == null) {
            return null;
        }
        final String adapterName = getAdapterName(fullPackage.isEmpty() ? name :
                name.substring(fullPackage.length() + 1));
        try {
            @SuppressWarnings("unchecked")
            final Class<? extends GenericLifecycleObserver> aClass =
                    (Class<? extends GenericLifecycleObserver>) Class.forName(
                            fullPackage.isEmpty() ? adapterName : fullPackage + "." + adapterName);
            return aClass.getDeclaredConstructor(klass);
        } catch (ClassNotFoundException e) {
            final Class<?> superclass = klass.getSuperclass();
            if (superclass != null) {
                return getGeneratedAdapterConstructor(superclass);
            }
        } catch (NoSuchMethodException e) {
            // this should not happen
            throw new RuntimeException(e);
        }
        return null;
    }
    
    static String getAdapterName(String className) {
            return className.replace(".", "_") + "_LifecycleAdapter";
    }
```
这个方法的作用是去递归查找你当前传递的观察者类（就是我们自定义实现`LifecycleObserver`接口的类，即上面的`ViewModel`类）所在包中是否存在名为`观察者类名_LifecycleAdapter`并且实现`GenericLifecycleObserver`接口的类的类（用`ViewModel`类说明也就是`ViewModel_LifecycleAdapter`），如果有那么就返回它的构造函数，否则继续查找递归查找你当前观察者类的父类的包中是否存在，如果都没有则方法`null`。

所以我们可以自己去监听一些事件来调度生命周期，`注意如果要自己实现这个生命周期调度器，我们至少存在一个含义一个参数的构造函数，这个参数必须是我们自己创建的观察者类，用上面的例子也就是ViewModel类`。当然一般情况下我们是不需要这样做的，如果我们没定义`getGeneratedAdapterConstructor`返回会返回`null`，然后`getCallback`方法中会判断是否为空，如果为空，那么就使用默认类的构造方法，也就是`getCallback`方法中的`20`行的处理，这里会给构造方法赋值`sREFLECTIVE`，下面我们看下这个`sREFLECTIVE`是什么
```java
    private static Constructor<? extends GenericLifecycleObserver> sREFLECTIVE;

    static {
        try {
            sREFLECTIVE = ReflectiveGenericLifecycleObserver.class
                    .getDeclaredConstructor(Object.class);
        } catch (NoSuchMethodException ignored) {

        }
    }
```
上面的代码不难看出，返回的是`ReflectiveGenericLifecycleObserver`类的构造方法，所以这个类就是为我们提供的默认调度器了，它接收一个`Object`对象，也就是说不关心我们观察者类具体是什么，现在重新回到调用`Lifecycling.getCallback`的地方，也就是`ObserverWithState`类中，记得这个类还有一个方法吧，也就是`dispatchEvent`方法，之前说过这个就是调度生命周期的方法，可以看到里面调用了我们刚刚实例的`GenericLifecycleObserver`对象的`onStateChanged`方法，ok，我们继续看一下系统默认提供的`ReflectiveGenericLifecycleObserver`类中对于`onStateChanged`方法的实现
```java
    @Override
    public void onStateChanged(LifecycleOwner source, Event event) {
        invokeCallbacks(mInfo, source, event);
    }
    
    private void invokeMethodsForEvent(List<MethodReference> handlers, LifecycleOwner source,
            Event event) {
        if (handlers != null) {
            for (int i = handlers.size() - 1; i >= 0; i--) {
                MethodReference reference = handlers.get(i);
                invokeCallback(reference, source, event);
            }
        }
    }
    
    @SuppressWarnings("ConstantConditions")
    private void invokeCallbacks(CallbackInfo info, LifecycleOwner source, Event event) {
        invokeMethodsForEvent(info.mEventToHandlers.get(event), source, event);
        invokeMethodsForEvent(info.mEventToHandlers.get(Event.ON_ANY), source, event);
    }
    
    private void invokeCallback(MethodReference reference, LifecycleOwner source, Event event) {
        //noinspection TryWithIdenticalCatches
        try {
            switch (reference.mCallType) {
                case CALL_TYPE_NO_ARG:
                    reference.mMethod.invoke(mWrapped);
                    break;
                case CALL_TYPE_PROVIDER:
                    reference.mMethod.invoke(mWrapped, source);
                    break;
                case CALL_TYPE_PROVIDER_WITH_EVENT:
                    reference.mMethod.invoke(mWrapped, source, event);
                    break;
            }
        } catch (InvocationTargetException e) {
            throw new RuntimeException("Failed to call observer method", e.getCause());
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }
    }
```
看上面`ReflectiveGenericLifecycleObserver`类中的部分代码，`onStateChanged`中调用了`invokeCallbacks`方法，`invokeCallbacks`中调用了两次`invokeMethodsForEvent`方法，一次是具体的事件，一次是固定的`Event.ON_ANY`事件，这里就印证了之前说的单独监听的方法会优先于监听`ON_ANY`事件的方法，然后我们继续看`invokeMethodsForEvent`方法这里循环调用了`invokeCallback`方法，也就是最终的触发监听生命周期回调的方法，这个方法中反射调用也就印证了之前我们在写监听方法时，可以为一个参数可以无参数，监听`Event.ON_ANY`时候是两个参数了，所以调用流程就是这样，但是你会问他们是如何得到这个方法的引用的呢，我们先回到`invokeCallbacks`中调用`invokeMethodsForEvent`方法时候传递的第一个参数`info.mEventToHandlers.get(event)`，所以成员变量`info`中保存着所有我们注册的方法，接下来回到构造方法中看下`info`的初始化
```java
    ...
    
    ReflectiveGenericLifecycleObserver(Object wrapped) {
        mWrapped = wrapped;
        mInfo = getInfo(mWrapped.getClass());
    }
    
    ...
```
可以看到`mInfo`（`onStateChanged`中调用`invokeCallbacks`时候传递的是`mInfo`，所以`invokeCallbacks`中调用`invokeMethodsForEvent`中的`info`就是`mInfo`）是通过`getInfo`方法实例的，并且`getInfo`方法中传递了我们观察者类
```java
    private static CallbackInfo getInfo(Class klass) {
        CallbackInfo existing = sInfoCache.get(klass);
        if (existing != null) {
            return existing;
        }
        existing = createInfo(klass);
        return existing;
    }
```
这个方法里面除了一些缓存处理，重点关注`createInfo`方法，这个才是最终实例的方法，同时也传递了之前传进来的类
```java
    private static CallbackInfo createInfo(Class klass) {
        Class superclass = klass.getSuperclass();
        Map<MethodReference, Event> handlerToEvent = new HashMap<>();
        if (superclass != null) {
            CallbackInfo superInfo = getInfo(superclass);
            if (superInfo != null) {
                handlerToEvent.putAll(superInfo.mHandlerToEvent);
            }
        }

        Method[] methods = klass.getDeclaredMethods();

        Class[] interfaces = klass.getInterfaces();
        for (Class intrfc : interfaces) {
            for (Entry<MethodReference, Event> entry : getInfo(intrfc).mHandlerToEvent.entrySet()) {
                verifyAndPutHandler(handlerToEvent, entry.getKey(), entry.getValue(), klass);
            }
        }

        for (Method method : methods) {
            OnLifecycleEvent annotation = method.getAnnotation(OnLifecycleEvent.class);
            if (annotation == null) {
                continue;
            }
            Class<?>[] params = method.getParameterTypes();
            int callType = CALL_TYPE_NO_ARG;
            if (params.length > 0) {
                callType = CALL_TYPE_PROVIDER;
                if (!params[0].isAssignableFrom(LifecycleOwner.class)) {
                    throw new IllegalArgumentException(
                            "invalid parameter type. Must be one and instanceof LifecycleOwner");
                }
            }
            Event event = annotation.value();

            if (params.length > 1) {
                callType = CALL_TYPE_PROVIDER_WITH_EVENT;
                if (!params[1].isAssignableFrom(Event.class)) {
                    throw new IllegalArgumentException(
                            "invalid parameter type. second arg must be an event");
                }
                if (event != Event.ON_ANY) {
                    throw new IllegalArgumentException(
                            "Second arg is supported only for ON_ANY value");
                }
            }
            if (params.length > 2) {
                throw new IllegalArgumentException("cannot have more than 2 params");
            }
            MethodReference methodReference = new MethodReference(callType, method);
            verifyAndPutHandler(handlerToEvent, methodReference, event, klass);
        }
        CallbackInfo info = new CallbackInfo(handlerToEvent);
        sInfoCache.put(klass, info);
        return info;
    }
```
先整体看下`createInfo`方法，其实主要就是验证和反射查找我们的观察者类中的使用`OnLifecycleEvent`注解注释的方法，所以这时理解为什么我们在监听生命周期时需要使用这个注解了吧，这里的代码也非常简单就不细说了，不明白的朋友可以查一下反射相关的知识。

所以现在就很清晰了，最开始`Lifecycle`的子类`LifecycleRegistry`调用`addObserver`方法中创建了`ObserverWithState`对象，然后通过`ObserverWithState`中的`dispatchEvent`方法调度事件，传递给`GenericLifecycleObserver`的实现类默认的`ReflectiveGenericLifecycleObserver`或者自己实现的`xxx_LifecycleAdapter`类，从而调度生命周期，所以现在我们只需要知道`ObserverWithState`的`dispatchEvent`方法是什么时候调用的既可。

主要就是`LifecycleRegistry`中的`forwardPass`和`backwardPass`方法，而这两方法是在`sync`方法中判断调用的，而`sync`方法是通过`handleLifecycleEvent`方法触发的，我们先不管为什么需要判断从而触发`forwardPass`或`backwardPass`，先说一下`handleLifecycleEvent`方法的调用，他是在一个叫做`ReportFragment`的`Fragment`类中调用的，我们先来说下这个`ReportFragment`的作用。

这个类是用来监听生命周期的，这个类里面有一个`injectIfNeededIn`方法
```java
    public static void injectIfNeededIn(Activity activity) {
        // ProcessLifecycleOwner should always correctly work and some activities may not extend
        // FragmentActivity from support lib, so we use framework fragments for activities
        android.app.FragmentManager manager = activity.getFragmentManager();
        if (manager.findFragmentByTag(REPORT_FRAGMENT_TAG) == null) {
            manager.beginTransaction().add(new ReportFragment(), REPORT_FRAGMENT_TAG).commit();
            // Hopefully, we are the first to make a transaction.
            manager.executePendingTransactions();
        }
```
这个方法是在`Support`包中`SupportActivity`的`onCreate`方法中调用的，所以这样就关联上了`Activity`的生命周期，所以在`ReportFragment`中的生命周期方法中触发触发`dispatch`方法从而触发了`LifecycleRegistry`的`handleLifecycleEvent`方法
```java
    private void dispatch(Lifecycle.Event event) {
        Activity activity = getActivity();
        if (activity instanceof LifecycleRegistryOwner) {
            ((LifecycleRegistryOwner) activity).getLifecycle().handleLifecycleEvent(event);
            return;
        }

        if (activity instanceof LifecycleOwner) {
            Lifecycle lifecycle = ((LifecycleOwner) activity).getLifecycle();
            if (lifecycle instanceof LifecycleRegistry) {
                ((LifecycleRegistry) lifecycle).handleLifecycleEvent(event);
            }
        }
    }
```
因为继承的`Support`包中的`Activity`中实现了`LifecycleOwner`接口，而这个返回的是`LifecycleRegistry`（上面说过）所以就可以调用`LifecycleRegistry`的`handleLifecycleEvent`方法了。现在我们就理解了，为什么我们继承`Support`包中的`Activity`就可以使用`Lifecycle`组件了吧。当然你会问如果我们继承`Fragment`时候呢，什么时候触发的`handleLifecycleEvent`方法呢，其实很简单就是在`Fragment`中的比如`performStart`，`performResume`等方法中直接调用的，这里就不做过多解释了，可以具体看下`Support`中`Fragment`的代码。

接下来回到刚刚没有说明`LifecycleRegistry`中的`forwardPass`和`backwardPass`方法，为什么会有两个方法来触发生命周期事件，还记得我在介绍如何使用`Lifecycle`组件时最后说的么，生命周期事件是根据`Lifecycle`中的状态触发的，`Lifecycle`的状态如下
```java
public enum State {
        /**
         * Destroyed state for a LifecycleOwner. After this event, this Lifecycle will not dispatch
         * any more events. For instance, for an {@link android.app.Activity}, this state is reached
         * <b>right before</b> Activity's {@link android.app.Activity#onDestroy() onDestroy} call.
         */
        DESTROYED,

        /**
         * Initialized state for a LifecycleOwner. For an {@link android.app.Activity}, this is
         * the state when it is constructed but has not received
         * {@link android.app.Activity#onCreate(android.os.Bundle) onCreate} yet.
         */
        INITIALIZED,

        /**
         * Created state for a LifecycleOwner. For an {@link android.app.Activity}, this state
         * is reached in two cases:
         * <ul>
         *     <li>after {@link android.app.Activity#onCreate(android.os.Bundle) onCreate} call;
         *     <li><b>right before</b> {@link android.app.Activity#onStop() onStop} call.
         * </ul>
         */
        CREATED,

        /**
         * Started state for a LifecycleOwner. For an {@link android.app.Activity}, this state
         * is reached in two cases:
         * <ul>
         *     <li>after {@link android.app.Activity#onStart() onStart} call;
         *     <li><b>right before</b> {@link android.app.Activity#onPause() onPause} call.
         * </ul>
         */
        STARTED,

        /**
         * Resumed state for a LifecycleOwner. For an {@link android.app.Activity}, this state
         * is reached after {@link android.app.Activity#onResume() onResume} is called.
         */
        RESUMED;

        /**
         * Compares if this State is greater or equal to the given {@code state}.
         *
         * @param state State to compare with
         * @return true if this State is greater or equal to the given {@code state}
         */
        public boolean isAtLeast(State state) {
            return compareTo(state) >= 0;
        }
    }
```
可以看到只有这5种状态，那么它是怎么判断触发生命周期的呢，[点击这里](https://developer.android.google.cn/topic/libraries/architecture/lifecycle.html)官网中有一个图很清晰的介绍了它的判断，我在这里简单说明一下

当`state`从`INITIALIZED`或者`DESTROYED`到`CREATED`时触发`ON_CREATE`事件，然后从`CREATED`到`STARTED`时触发`ON_START`事件，然后从`STARTED`到`RESUMED`触发`ON_RESUME`事件。
然后从`RESUMED`到`STARTED`时触发`ON_PAUSE`事件，从`STARTED`到`CREATED`时触发`ON_STOP`事件，接着从`CREATED`到`DESTROYED`触发`ON_DESTROY`事件。

可以看出状态可以由上至下，也可以由下至上，所以现在理解了`LifecycleRegistry`中为什么有两个方法`forwardPass`和`backwardPass`来调度事件了吧。

也写了不少了，就告一段落吧，希望对开始使用`Lifecycle`组件的你带来帮助。


 