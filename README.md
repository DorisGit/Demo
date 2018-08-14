# Notification与多线程
2018-08-13
1、验证大量对象销毁的耗时
2、用Block捕捉对象，将对象丢到后台线程销毁的可行性

一、概述

在多线程中，无论在哪个线程注册了观察者，Notification接收和处理都是在发送Notification的线程中的。所以，当我们需要在接收到Notification后作出更新UI操作的话，就需要考虑线程的问题了，如果在子线程中发送Notification，想要在接收到Notification后更新UI的话就要切换回到主线程。先看一个例子：

运行结果：

2017-03-11 17:56:33.898 NotificationTest[23457:1615587] Current thread = <NSThread: 0x608000078080>{number = 1, name = main}
2017-03-11 17:56:33.899 NotificationTest[23457:1615738] Post notification，Current thread = <NSThread: 0x60000026c500>{number = 3, name = (null)}
2017-03-11 17:56:33.899 NotificationTest[23457:1615738] Receive notification，Current thread = <NSThread: 0x60000026c500>{number = 3, name = (null)}
上面我们在主线程注册观察者，在子线程发送Notification，最后Notification的接收和处理也是在子线程。



二、重定向Notification到指定线程

当然，想要在子线程发送Notification、接收到Notification后在主线程中做后续操作，可以用一个很笨的方法，在 handleNotification 里面强制切换线程：

在简单情况下可以使用这种方法，但是当我们发送了多个Notification并且有多个观察者的时候，难道我们要在每个地方都手动切换线程？所以，这种方法并不是一个有效的方法。

最好的方法是在Notification所在的默认线程中捕获发送的通知，然后将其重定向到指定的线程中。关于Notification的重定向官方文档给出了一个方法：

一种重定向的实现思路是自定义一个通知队列(不是NSNotificationQueue对象)，让这个队列去维护那些我们需要重定向的Notification。我们仍然是像之前一样去注册一个通知的观察者，当Notification到达时，先看看post这个Notification的线程是不是我们所期望的线程，如果不是，就将这个Notification放到我们的队列中，然后发送一个信号(signal)到期望的线程中，来告诉这个线程需要处理一个Notification。指定的线程收到这个信号(signal)后，将Notification从队列中移除，并进行后续处理。
我们根据官方文档中的教程测试一下：

/*
在注册任何通知之前，需要先初始化属性。下面方法初始化了队列和锁定对象，保留对当前线程对象的引用，并创建一个Mach通信端口，将其添加到当前线程的运行循环中。
此方法运行后，发送到notificationPort的任何消息都会在首次运行此方法的线程的run loop中接收。如果接收线程的run loop在Mach消息到达时没有运行，则内核保持该消息，直到下一次进入run loop。接收线程的run loop将传入消息发送到端口delegate的handleMachMessage：方法。
*/

在子线程中发送Notification，在主线程中接收与处理Notification。

上面的实现方法也不是绝对完美的，苹果官方指出了这种方法的限制：

（1）所有线程的Notification的处理都必须通过相同的方法（processNotification :)。

（2）每个对象必须提供自己的实现和通信端口。

更好但更复杂的方法是我们自己去子类化一个NSNotificationCenter，或者单独写一个类来处理这种转发。


除了上面苹果官方给我们提供的方法外，我们还可以利用基于block的NSNotification去实现，apple 从 ios4 之后提供了带有 block 的 NSNotification。使用方式如下：

- (id<NSObject>)addObserverForName:(NSString *)name
object:(id)obj
queue:(NSOperationQueue *)queue
usingBlock:(void (^)(NSNotification *note))block
其中：

观察者就是当前对象
queue 定义了 block 执行的线程，nil 则表示 block 的执行线程和发通知在同一个线程
block 就是相应通知的处理函数
这个 API 已经能够让我们方便的控制通知的线程切换。但是，这里有个问题需要注意。就是其 remove 操作。

原来的 NSNotification 的 remove 方式如下：

其中 _observer 是 addObserverForName 方式的 api 返回观察者对象。这也就意味着，你需要为每一个观察者记录一个成员对象，然后在 remove 的时候依次删除。试想一下，你如果需要 10 个观察者，则需要记录 10 个成员对象，这个想想就是很麻烦，而且它还不能够方便的指定 observer 。因此，理想的做法就是自己再做一层封装，将这些细节封装起来。

