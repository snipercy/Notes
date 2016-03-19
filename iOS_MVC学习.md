# MVC设计模式

模型-视图-控制器(Model-View-Controller, MVC)一种软件设计模式，广泛应用于用户交互应用程序中。在`iOS`开发中`MVC`的机制被使用的淋漓尽致。

![mvc.png] (https://github.com/snipercy/Notes/blob/master/image/model_view_controller.png)是

## 模型对象(model)

model中封装了应用程序的数据，并定义操控和处理数据的逻辑和运算。模型对象可能是表示游戏中的角色或地址薄中的联系人。

用户在view中所进行的`创建`或`修改`数据的操作，通过`controller`传达出去，最终会创建或更新`model`。model更改时（例如，通过网络连接接收到新数据），会通知`controller`，controller去更新相应的view对象。

## 视图对象（view）

这是应用程序中用户**可以看见**的对象。`view`知道如何将自己绘制出来，并可以对用户的操作做出响应。`view`的主要目的就是显示model的数据。

在iOS app开发中，所有的控件、窗口等都继承自 UIView，对应MVC中的V。UIView及其子类主要负责UI的实现，而UIView所产生的时间都可以采用委托的方式，交给UIViewController实现。

## 控制器对象（controller）

对于不同的UIView，有相应的UIViewController，对应MVC中的C。

控制器对象可以理解为同步管道程序，通过它，视图对象可以知道模型对象的变化，反之亦然。控制器对象还可以为应用程序执行设置和协调任务，并管理其他对象的生命周期。

控制器对象解释在视图对象中进行的用户操作，并将新的或更改过的数据传达给模型对象。模型对象更改时，一个控制器对象会将新的模型数据传达给视图对象，以便视图对象可以显示它。

- Model和View永远不能相互通信，只能通过Controller传递。
- Controller可以直接与Model对话（读写调用Model），Model通过Notification和KVO机制与Controller间接通信。
- Controller可以直接与View对话，通过outlet,直接操作View,outlet直接对应到View中的控件,View通过action向Controller报告事件的发生(如用户Touch我了)。Controller是View的直接数据源（数据很可能是Controller从Model中取得并经过加工了）。Controller是View的代理（delegate),以同步View与Controller。
有关”模型－视图－控制器”的完整信息，请参阅 Concepts in Objective-C Programming（Objective-C 编程中的概念）中的：Model-View-Controller

----

>
参考文献:
- https://developer.apple.com/library/ios/documentation/general/conceptual/CocoaEncyclopedia/Model-View-Controller/Model-View-Controller.html#//apple_ref/doc/uid/TP40010810-CH14-SW1
- https://liuzhichao.com/p/1379.html
