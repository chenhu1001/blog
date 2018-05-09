---
title: ARC下内存泄露总结
date: 2016-06-20 14:04:08
categories: iOS
tags: [iOS]
---
## 1、Block的循环引用
&emsp;&emsp;在iOS4.2时，Apple推出ARC内存管理机制。这是一种编译期的内存管理方式，在编译期间，编译器会判断对象的引用情况，并在合适的位置加上retain和release，使得对象的内存被合理的管理。所以，从本质上说ARC和MRC在本质上是一样的，都是通过引用计数的内存管理方式。  
&emsp;&emsp;使用ARC虽然可以简化内存管理，但是ARC并不是万能的，有些情况程序为了能够正常运行，会隐式地持有或者复制对象，如果不加以注意，便会造成内存泄露。在ARC下，当Block获取到外部变量时，由于编译器无法预测获取到的变量何时会被突然释放，为了保证程序能够正确运行，让Block持有获取到的变量。  
<!--more-->
&emsp;&emsp;下面主要通过一个例子来介绍在ARC情况下使用Block不当会导致内存泄露的问题。示例代码来源于《Effective Objective-C 2.0》（编写高质量iOS与OS X代码的52个有效方法）。  
（1）EOCNetworkFetcher.h

```
typedef void (^EOCNetworkFetcherCompletionHandler)(NSData *data);

@interface EOCNetworkFetcher : NSObject

@property (nonatomic, strong, readonly) NSURL *url;

- (id)initWithURL:(NSURL *)url;

- (void)startWithCompletionHandler:(EOCNetworkFetcherCompletionHandler)completion;

@end
```

（2）EOCNetworkFetcher.m

```
@interface EOCNetworkFetcher ()

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, copy) EOCNetworkFetcherCompletionHandler completionHandler;
@property (nonatomic, strong) NSData *downloadData;

@end

@implementation EOCNetworkFetcher

- (id)initWithURL:(NSURL *)url {
    if(self = [super init]) {
        _url = url;
    }
    return self;
}

- (void)startWithCompletionHandler:(EOCNetworkFetcherCompletionHandler)completion {
    self.completionHandler = completion;
    //开始网络请求
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        _downloadData = [[NSData alloc] initWithContentsOfURL:_url];
        dispatch_async(dispatch_get_main_queue(), ^{
             //网络请求完成
            [self p_requestCompleted];
        });
    });
}

- (void)p_requestCompleted {
    if(_completionHandler) {
        _completionHandler(_downloadData);
    }
}

@end
```

（3）EOCClass.m

```
@implementation EOCClass {
    EOCNetworkFetcher *_networkFetcher;
    NSData *_fetchedData;
}

- (void)downloadData {
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    _networkFetcher = [[EOCNetworkFetcher alloc] initWithURL:url];
    [_networkFetcher startWithCompletionHandler:^(NSData *data) {
        _fetchedData = data;
    }];
}

@end
```

代码分析：

> * completion handler块因为要设置_fetchedData实例变量的值，所以它必须捕获self变量，也就是说handler块保留了EOCClass实例。

> * 而EOCClass实例通过strong实例变量保留了EOCNetworkFetcher，最后EOCNetworkFetcher实例对象又保留了handler块。

引用关系如下下图所示
![循环引用示意图](http://7xk4rv.com1.z0.glb.clouddn.com/ARC%E4%B8%8B%E5%86%85%E5%AD%98%E6%B3%84%E9%9C%B2%E6%80%BB%E7%BB%93_1.png)
  
要想打破保留环，解决办法：

> * 方法一：使用完EOCNetworkFetcher对象之后就没有必要在保留该对象了，在block里面将对象释放即可打破保留环。

```
- (void)downloadData {
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    _networkFetcher = [[EOCNetworkFetcher alloc] initWithURL:url];
    [_networkFetcher startWithCompletionHandler:^(NSData *data) {
        _fetchedData = data;
        _networkFetcher = nil;   //加上此行，此处是为了打破循环引用
    }];
}
```

> * 方法二：上面的方法需要调用者自己来将对象手动设置为nil，对于使用者来说会造成很多困恼，如果忘记将对象设置为nil就会造成循环引用。在运行完completion handler之后将block释放即可。

```
- (void)p_requestCompleted {
    if(_completionHandler) {
        _completionHandler(_downloadData);
    }
    self.completionHandler = nil;   //加上此行，此处是为了打破循环引用
}
```

> * 方法三：将引用的一方变成weak，从而避免循环引用。

```
- (void)downloadData {
   __weak __typeof(self) weakSelf = self;
   NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
   _networkFetcher = [[EOCNetworkFetcher alloc] initWithURL:url];
   [_networkFetcher startWithCompletionHandler:^(NSData *data) {
        //如果想防止weakSelf被释放，可以再次强引用
        __typeof(&*weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.fetchedData = data;
        }
   }];
}
```

## 2、NSTimer
在使用NSTimer addTarget时，为了防止target被释放而导致的程序异常，timer会持有target，所以这也是一处内存泄露的隐患。

```
/**
 * self持有timer，timer在初始化时持有self，造成循环引用。
 * 解决的方法就是使用invalidate方法销掉timer。
 */
@interface SomeViewController : UIViewController
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation SomeViewController

- (void)someMethod
{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1  
                                             target:self  
                                           selector:@selector(handleTimer:)  
                                           userInfo:nil  
                                            repeats:YES];  
}

@end
```

## 3、performSelector 系列
performSelector顾名思义即在运行时执行一个selector，最简单的方法如下

```
- (id)performSelector:(SEL)selector;
```

这种调用selector的方法和直接调用selector基本等效，执行效果相同

```
[object methodName];
[object performSelector:@selector(methodName)];
```

但performSelector相比直接调用更加灵活

```
SEL selector;
if (/* some condition */) {
    selector = @selector(newObject);
} else if (/* some other condition */) {
    selector = @selector(copy);
} else {
    selector = @selector(someProperty);
}
id ret = [object performSelector:selector];
```

这段代码就相当于在动态之上再动态绑定。在ARC下编译这段代码，编译器会发出警告

```
warning: performSelector may cause a leak because its selector is unknow [-Warc-performSelector-leak]
```

正是由于动态，编译器不知道即将调用的selector是什么，不了解方法签名和返回值，甚至是否有返回值都不懂，所以编译器无法用ARC的内存管理规则来判断返回值是否应该释放。因此，ARC采用了比较谨慎的做法，不添加释放操作，即在方法返回对象时就可能将其持有，从而可能导致内存泄露。

以本段代码为例，前两种情况（newObject, copy）都需要再次释放，而第三种情况不需要。这种泄露隐藏得如此之深，以至于使用static analyzer都很难检测到。如果把代码的最后一行改成

```
[object performSelector:selector];
```

不创建一个返回值变量测试分析，简直难以想象这里居然会出现内存问题。所以如果你使用的selector有返回值，一定要处理掉。

## 4、循环引用
A有个属性B，B有个属性A，如果都是strong修饰的话，两个对象都无法释放。   
这种问题常发生于把delegate声明为strong属性了。 

```
@interface SampleViewController
@property (nonatomic, strong) SampleClass *sampleClass;
@end
@interface SampleClass
@property (nonatomic, strong) SampleViewController *delegate;
@end
```

## 5、循环未结束
如果某个ViewController中有无限循环，也会导致即使ViewController对应的view关掉了，ViewController也不能被释放。   
这种问题常发生于animation处理。

```
CATransition *transition = [CATransition animation];
transition.duration = 0.5;
tansition.repeatCount = HUGE_VALL;
[self.view.layer addAnimation:transition forKey:"myAnimation"];
```

上例中，animation重复次数设成HUGE_VALL，一个很大的数值，基本上等于无限循环了。 
解决办法是，在ViewController关掉的时候，停止这个animation。

```
-(void)viewWillDisappear:(BOOL)animated {
    [self.view.layer removeAllAnimations];
}
```

## 6、非OBJC对象
ARC是自动检测objc对象的，非objc对象就无能为力了，比如C或C++等。  
C语言使用malloc开辟，free释放。  
C++使用new开辟，delete释放。  
但是在ARC下，不会添加非objc对象释放语句，如果没去释放，也会造成内存泄露。

Clang的技术博客：[https://chenhu1001.github.io](https://chenhu1001.github.io)

