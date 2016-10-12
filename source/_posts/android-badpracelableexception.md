---
title: android.os.BadParcelableException
date: 2016-10-12 09:52:26
categories: Android
tags: [Android, Android Exception]
---
### 异常说明
今天在测试工程的时候,出现如下异常:
```java
Caused by android.os.BadParcelableException: ClassNotFoundException when unmarshalling:
...
android.os.Parcel.readParcelableCreator (Parcel.java:2203)
android.view.View$BaseSavedState. (View.java:18696)
...
```

<!--more-->

### 异常解析
可以看到报错在__Parcel__的__readParcelableCreator__方法中,而且是因为类找不到导致的,所以我们查看这个方法的代码,如下:
```java
 public final Parcelable.Creator<?> readParcelableCreator(ClassLoader loader) {
        ...
        synchronized (mCreators) {
            HashMap<String,Parcelable.Creator<?>> map = mCreators.get(loader);
            if (map == null) {
                map = new HashMap<>();
                mCreators.put(loader, map);
            }
            creator = map.get(name);
            if (creator == null) {
                try {
                    // If loader == null, explicitly emulate Class.forName(String) "caller
                    // classloader" behavior.
                    ClassLoader parcelableClassLoader =
                            (loader == null ? getClass().getClassLoader() : loader);
                    // Avoid initializing the Parcelable class until we know it implements
                    // Parcelable and has the necessary CREATOR field. http://b/1171613.
                    Class<?> parcelableClass = Class.forName(name, false /* initialize */,
                            parcelableClassLoader);
                    if (!Parcelable.class.isAssignableFrom(parcelableClass)) {
                        throw new BadParcelableException("Parcelable protocol requires that the "
                                + "class implements Parcelable");
                    }
                    Field f = parcelableClass.getField("CREATOR");
                    if ((f.getModifiers() & Modifier.STATIC) == 0) {
                        throw new BadParcelableException("Parcelable protocol requires "
                                + "the CREATOR object to be static on class " + name);
                    }
                    Class<?> creatorType = f.getType();
                    if (!Parcelable.Creator.class.isAssignableFrom(creatorType)) {
                        // Fail before calling Field.get(), not after, to avoid initializing
                        // parcelableClass unnecessarily.
                        throw new BadParcelableException("Parcelable protocol requires a "
                                + "Parcelable.Creator object called "
                                + "CREATOR on class " + name);
                    }
                    creator = (Parcelable.Creator<?>) f.get(null);
                }
                catch (IllegalAccessException e) {
                    Log.e(TAG, "Illegal access when unmarshalling: " + name, e);
                    throw new BadParcelableException(
                            "IllegalAccessException when unmarshalling: " + name);
                }
                catch (ClassNotFoundException e) {
                    Log.e(TAG, "Class not found when unmarshalling: " + name, e);
                    throw new BadParcelableException(
                            "ClassNotFoundException when unmarshalling: " + name);
                }
                catch (NoSuchFieldException e) {
                    throw new BadParcelableException("Parcelable protocol requires a "
                            + "Parcelable.Creator object called "
                            + "CREATOR on class " + name);
                }
                if (creator == null) {
                    throw new BadParcelableException("Parcelable protocol requires a "
                            + "non-null Parcelable.Creator object called "
                            + "CREATOR on class " + name);
                }

                map.put(name, creator);
            }
        }

        return creator;
    }
```

从上面的部分代码中可以看到第14行和第44行,就是导致异常以及抛出异常的根源,可以看出,如果传入的__ClassLoader__是__null__,那么使用的__ClassLoader__就为**getClass().getClassLoader()**也就是__Parcel__类的__ClassLoader__,也就是__java.lang.BootClassLoader__也可以称之__Framework ClassLoader__(该类加载器加载不了我们的自定义类,后面会有说明,现在先跳过),所以现在我们知道了,如果__ClassLoader__传的是__null__,那么是加载不了我们需要加载的自定义目标类的,所以现在的问题是这个__ClassLoader__是什么时候传入的,我们继续看__Parcel__类,如下:
```java
  public final <T extends Parcelable> T readParcelable(ClassLoader loader) {
        Parcelable.Creator<?> creator = readParcelableCreator(loader);
        if (creator == null) {
            return null;
        }
        if (creator instanceof Parcelable.ClassLoaderCreator<?>) {
          Parcelable.ClassLoaderCreator<?> classLoaderCreator =
              (Parcelable.ClassLoaderCreator<?>) creator;
          return (T) classLoaderCreator.createFromParcel(this, loader);
        }
        return (T) creator.createFromParcel(this);
    }
```

上面的代码不难看出,__ClassLoader__使用的是**readParcelable**方法传入的__ClassLoader__,所以我们在使用__readParcelable__方法的时候,如果传入的参数为__null__或者传入__java.lang.BootClassLoader__,都会使__readParcelableCreator__方法加载自定义类的时候抛出__ClassNotFound__异常,从而导致__android.os.BadParcelableException: ClassNotFoundException when unmarshalling__异常产生。

### 关于Android的ClassLoader
对于__Android__应用来说至少有两个__ClassLoader__,一个是__Android系统启动时候创建的__,还有一个是__APK启动时候创建的__,他们分别是**java.lang.BootClassLoader(系统启动)**和**dalvik.system.PathClassLoader(APK启动)**,其中__BootClassLoader__加载__Android类__,__PathClassLoader__加载应用DEX中的类。需要注意的是__PathClassLoader__继承__BootClassLoader__,所以__PathClassLoader__也可以加载__Android相关的类__。就像上面的例子,__Parcel__类是__Android类__所以,获取到的__ClassLoader__是__BootClassLoader__。还有需要注意的是__Activity.class.getClassLoader()__是__BootClassLoader__,而继承__Activity__的类的__ClassLoader__为__PathClassLoader__,比如__FragmentActivity__,__AppCompatActivity__等。