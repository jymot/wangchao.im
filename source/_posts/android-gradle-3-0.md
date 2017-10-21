---
title: Gradle use the new dependency configurations（译）
date: 2017-10-21 09:48:38
categories: [Android]
tags: [Android, Gradle]
---
Gradle 3.4引入了新的Java Library插件配置，允许您控制是否将依赖关系发布到使用该库的项目的编译和运行时类路径。 Android插件3.0.0正在采用这些新的依赖关系配置，并且迁移大型项目以使用它们可以大大减少构建时间。 下表帮助您了解应该使用的配置。

| New configuration | Deprecated configuration | Behavior |
| ------ | ------ | ------ | 
| implementation | compile | 当您的模块配置implementation依赖关系时，它让Gradle知道模块不想在编译时泄漏对其他模块的依赖。 也就是说，依赖关系仅在运行时可用于其他模块。使用这种依赖配置而不是api或compile可以显着的构建时间改进，因为它减少了构建系统需要重新编译的项目数量。 例如，如果implementation依赖关系更改其API，则Gradle仅重新编译依赖关系和直接依赖于它的模块。 大多数应用和测试模块应该使用此配置。 |
| api | compile | 当一个模块包含api依赖性时，它让Gradle知道该模块希望将该依赖关系传递到其他模块，以便它们在运行时和编译时可用。 此配置的行为就像compile(现在已经不推荐使用)，通常只能在库模块中使用。 这是因为，如果api依赖关系改变其外部API，则Gradle会在编译时重新编译可访问该依赖关系的所有模块。 因此，拥有大量的api依赖关系可以大大增加构建时间。 除非要将依赖项的API公开到单独的测试模块，否则应用程序模块应该使用 implementation 依赖。 |
| compileOnly | provided | Gradle仅添加对编译类路径的依赖（它不会添加到构建输出）。 当您创建一个Android库模块并且在编译期间需要依赖关系时，这很有用，但它是可选的，在运行时存在。 也就是说，如果您使用此配置，那么您的库模块必须包含一个运行时条件，以检查依赖关系是否可用，然后优雅地更改其行为，以便它仍然可以在没有提供的情况下起作用。 这有助于通过不添加不重要的临时依赖关系来减少最终的APK的大小。 此配置的行为就像provided（现在已被弃用）。 |
| runtimeOnly | apk | Gradle仅添加了对构建输出的依赖关系，以便在运行时使用。 也就是说，它不会添加到编译类路径中。 此配置的行为就像apk（现在已经不推荐使用）。 |

就像Android插件的当前稳定版本一样，上述配置可用于特定于风格或构建类型的依赖关系。 例如，您可以使用implementation使所有变体的依赖关系可用，也可以使用debugImplementation使其仅适用于模块的debug变种。

    Note: compile, provided, and apk are currently still available. However, they will be removed in the next major release of the Android plugin.