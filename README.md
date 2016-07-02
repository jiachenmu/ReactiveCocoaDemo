# ReactiveCocoaDemo
ManoBoo(ReactiveCocoa使用浅析)中的Demo

# iOS Reactive Cocoa使用浅析


---
##**目录：**

[TOC]

##Reactive Cocoa浅析

> ReactiveCocoa是响应式编程(FRP)在IOS中的一个实现框架,[Github地址](https://github.com/ReactiveCocoa/ReactiveCocoa)

###1.什么是响应式编程
推荐一个网址[响应式编程（Reactive Programming）介绍](http://www.tuicool.com/articles/BBNRRf),如果不太清楚，那么我们首先来了解一下其他的编程思想

####1.面向过程：
>“面向过程”(Procedure Oriented)是一种以过程为中心的编程思想。“面向过程”也可称之为“面向记录”编程思想，他们不支持丰富的“面向对象”特性（比如继承、多态），并且它们不允许混合持久化状态和域逻辑。

C语言就是一门面向过程的语言。

####2.面向对象
>面向对象语言（Object-Oriented Language）是一类以对象作为基本程序结构单位的程序设计语言，指用于描述的设计是以对象为核心，而对象是程序运行时刻的基本成分。语言中提供了类、继承等成分。

>万物皆对象

典型的面向对象的编程语言有C++,C#,Java等 
####3.链式编程
>是将多个操作（多行代码）通过点号(.)链接在一起成为一句代码,使代码可读性好
在`Objective-C`中的形式类似于下面这种形式

```
Person *per = [[Person allo] init];
per.eat().drink().sleep();
```
**用一个[计算器Demo](https://github.com/jiachenmu/ReactiveCocoaDemo)来简单说明什么是链式编程**
这是我写的一个非常简单的计算器
**Calculator.h**文件
```
#import <Foundation/Foundation.h>

@class Calculator;
typedef Calculator *(^CalculatorBlock)(double num);

@interface Calculator : NSObject

+ (instancetype)opeartionNum:(double)num;

@property (assign, nonatomic) double opeartionNum;

//加--减--乘--除

@property (copy, nonatomic) CalculatorBlock add;
@property (copy, nonatomic) CalculatorBlock reduce;
@property (copy, nonatomic) CalculatorBlock multiply;
@property (copy, nonatomic) CalculatorBlock divide;

@end
```

**Calculator.m**文件
```
#import "Calculator.h"

@implementation Calculator

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self buildBlock];
    }
    return self;
}

+ (instancetype)opeartionNum:(double)num {
    Calculator *calu = [[Calculator alloc] init];
    calu.opeartionNum = num;
    
    return calu;
}

- (void)buildBlock {
    __weak typeof(self) weakSelf = self;
    _add = ^Calculator *(double num){
        weakSelf.opeartionNum += num;
        return weakSelf;
    };
    
    _reduce = ^Calculator *(double num){
        weakSelf.opeartionNum -= num;
        return weakSelf;
    };
    
    _multiply = ^Calculator *(double num){
        weakSelf.opeartionNum *= num;
        return weakSelf;
    };
    
    _divide = ^Calculator *(double num){
        //除数为0 不作处理
        weakSelf.opeartionNum = _opeartionNum / (num == 0 ? 1 : num);
        return weakSelf;
    };
}
@end
```
这个Demo非常简单，说的只是链式编程的一个思想,从中我们可以看到，`加` `减` `乘` `除`四个Block，返回的均是当前对象，
我们怎么使用呢
```
//开始计算
    Calculator *calu = [Calculator opeartionNum:10.00];
    calu.add(2).reduce(2).multiply(2).divide(0);
    //输出结果
    NSLog(@"result : %f",calu.opeartionNum);
```

####3.响应式编程
我们先看看**KVO**(Key-Value Observing),直译过来也就是键值观察者模式，监听某个属性的变化，每次指定的被观察的对象的属性被修改后，KVO就会自动通知相应的观察者了。
```
//注册观察者和被观察的属性路径
[xiaoming addObserver:self forKeyPath:@"age" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

//接受属性变化的消息
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
 {
     if ([keyPath isEqualToString:@"age"] && object == xiaoming) {
        NSLog(@"小明的年龄发生变化");
     }
 }
```
接下来介绍一下iOS中一个响应式编程框架**ReactiveCocoa**
关于响应式编程的概念，我推荐看看上面推荐的那篇帖子[响应式编程（Reactive Programming）介绍](http://www.tuicool.com/articles/BBNRRf)，举的例子是`RxJS`，不过整体的概念与`ReactiveCocoa`无异，吸收思想即可。

----------
###2.ReactiveCocoa响应式编程框架
----------

`ReactiveCocoa`中常用到的是`RACSignal`,`RACSignal`继承自`RACStream`,`Stream`这个概念，直译过来也就是`事件流`的意思，那何为`数据流`，事件流就是一个按时间排序的Events序列，在这里引用[响应式编程（Reactive Programming）介绍](http://www.tuicool.com/articles/BBNRRf)其中的介绍，
**响应式编程使用异步数据流进行编程**
举个通俗的例子说明事件流：**如何把大象塞进冰箱？**
 >1. 打开冰箱门
 >2. 把大象塞进冰箱
 >3. 关上冰箱门
 
上述三个步骤组合起来就成为一个按时间排序的时间序列，即`事件流`

***
####1.`ReactiveCocoa`的核心方法
***
打开`RACStream`可以看到
```
// Lazily binds a block to the values in the receiver.
///
/// This should only be used if you need to terminate the bind early, or close
/// over some state. -flattenMap: is more appropriate for all other cases.
///
/// block - A block returning a RACStreamBindBlock. This block will be invoked
///         each time the bound stream is re-evaluated. This block must not be
///         nil or return nil.
///
/// Returns a new stream which represents the combined result of all lazy
/// applications of `block`.

- (instancetype)bind:(RACStreamBindBlock (^)(void))block;
```
关于其中各个属性的意思，可以看[RACStreamBindBlock介绍和使用](http://mobile.51cto.com/news-494321.htm)，其中对于各个属性有详细的介绍，`bind`这个思想理解即可，`RAC`已经封装了很多更方便的方法供我们使用。
***
####2.`ReactiveCocoa`的整体结构介绍
***
**`ReactiveCocoa`整体可以分为四个部分**
 1. 信号源(事件流)    `RACStream`      
 2. 订阅者    `RACSubscriber`
 3. 调度器    `RACScheduler`
 4. 清洁工    `RACDisposable`
 

----------
#####1.信号源(事件流)    `RACStream` 
举个例子：在一个具有多重UI状态的界面中，我们要实现一下几个功能
* 1 用户名和密码输入框字数超过限制时改变输入框背景颜色
* 2 用户名和密码无效和有效时登录按钮的背景颜色设置
***
**拿第一个问题当做例子**
我们平时怎么实现的呢，无非就是继承`UITextFieldDelegate`，在代理中判断输入框中的文字个数是否超过限制，然后改变背景颜色，亦或用KVO实现，这样做无可厚非，但是模板化过于严重，我们想做这个功能，需要声明代理，实现代理方法，同时代理方法中还需要判断`delegate`中的`textfield`是用户名输入框还是密码输入框，这样做不仅代码不仅冗长，而且会造成代码不易查看。
**那么在RAC中我们怎么做呢，看代码**
```
 //将ViewModel中的属性和控件中的属性绑定到一起
RAC(_userViewModel,userName) = [_userNameFeild rac_textSignal];
RAC(_userNameFeild,backgroundColor) = [_userNameFeild.rac_textSignal  
map:^id(NSString *password) {
        return weakSelf.userViewModel.isUserNameValid ? [UIColor whiteColor] : [UIColor redColor];
    }];
```
***
Tips_1: 这一部分我们可以配合`MVVM`设计模式使用，将ViewModel与控件绑定到一起，减轻`ViewController`的负担。
具体这一部分的Demo可以查看文末的Github链接，只是一个简单使用
Tips_2: 由上可以看到，我们可以将某个功能的代码写的更加集中，更加方便阅读和维护

----------
#####2.订阅者 `RACSubscriber` 
在整个`RAC`中，我们基本上都是采用`信号源-订阅者`的这种模式来使用`RAC`,为了获取到信号源中的value，我们需要订阅这个信号源。
```
[_userNameFeild.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
```
Tips: 我们查看源代码可以发现`_userNameFeild.rac_textSignal`实现过程就是监听所有的`UIControlEventAllEditingEvents`事件，然后发出信号，然后我们订阅这个信号源，可以获取到其中的值`x`。
```
- (RACSignal *)rac_textSignal {
	@weakify(self);
	return [[[[[RACSignal
		defer:^{
			@strongify(self);
			return [RACSignal return:self];
		}]
		concat:[self rac_signalForControlEvents:UIControlEventAllEditingEvents]]
		map:^(UITextField *x) {
			return x.text;
		}]
		takeUntil:self.rac_willDeallocSignal]
		setNameWithFormat:@"%@ -rac_textSignal", RACDescription(self)];
}
```
好了，上面讲了那么多理论知识，具体如何使用请看下面

----------
#####3.调度器`RACSubscriber` 和 清洁工`RACDisposable`
* 1 调度器RACSubscriber，这一部分是使用GCD的串行队列来实现的，文末Github链接中有对其的简单使用
* 2 清洁工RACDisposable
    > `RACDisposable` 在 `ReactiveCocoa` 中就充当着清洁工的角色，它封装了取消和清理一次订阅所必需的工作。它有一个核心的方法 `-dispose` ，调用这个方法就会执行相应的清理工作，这有点类似于 `NSObject` 的 `-dealloc` 方法。

 :我们上面使用`subscribeNext:^(id x) {}`这个方法订阅信号源进行处理之后会生成一个清洁工`RACDisposable`,我们可以手动的调用`dispose`方法来进行清理工作。
 
----------
##Reactive Cocoa使用
----------
###* 1 RAC发送消息,并且绑定到控件
```
- (void)racSenderMessage {
    //延迟2.0S 发送"呵呵哒~"消息
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"呵呵哒~"];
        [subscriber sendCompleted];
        return nil;
    }] delay:2.0];
    //将_userNameFeild的`text`属性与映射后的信号量的值绑定到一起
    RAC(_userNameFeild,text) = [signal map:^id(NSString *value) {
        if ([value isEqualToString:@"呵呵哒~"]) {
            return @"么么哒~";
        }
        return nil;
    }];
}
```
----------
###* 2 RAC代理
```
- (void)racProtocol {
    RACSignal *programmerSignal = [self rac_signalForSelector:@selector(whoAmI) fromProtocol:@protocol(Programmer)];
    
    [programmerSignal subscribeNext:^(id x) {
        NSLog(@"RAC通知------I'm a great programmer...");
    }];
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self_weak_ whoAmI];
    });
}

- (void)whoAmI {
    NSLog(@"whoAmI------my name is %@",_user.userName);
}
```
----------
###* 3 RAC通知
```
- (void)racNotification {
    //接受通知并且处理
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"RAC_Notifaciotn" object:nil] subscribeNext:^(NSNotification *notify) {
        NSLog(@"notify.content = %@",notify.userInfo[@"content"]);
    }];
    
    //发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RAC_Notifaciotn" object:nil userInfo:@{@"content" : @"i'm a notification"}];
}
```
----------
###* 4 RAC信号拼接
```
- (void)racSignalLink {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(2)];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    [[signal1 concat:signal2] subscribeNext:^(NSNumber *value) {
        NSLog(@"RAC信号拼接------value = %@",value);
    }];;
}
```
输出结果为：
```
2016-07-02 14:34:16.148 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号拼接------value = 1
2016-07-02 14:34:16.148 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号拼接------value = 2
```
----------
###* 5 RAC信号合并
```
- (void)racSignalMerge {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"清纯妹子"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"性感妹子"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    [[signal1 merge:signal2] subscribeNext:^(id x) {
        NSLog(@"RAC信号合并------我喜欢： %@",x);
    }];
}
```
输出结果为：
```
2016-07-02 14:34:16.149 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号合并------我喜欢： 清纯妹子
2016-07-02 14:34:16.149 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号合并------我喜欢： 性感妹子
```
----------
###* 6 RAC信号组合
```
- (void)racSignalCombine {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"年轻"];
        [subscriber sendNext:@"清纯"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"温柔"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    //combineLatest 将数组中的信号量发出的最后一个object 组合到一起
    [[RACSignal combineLatest:@[signal1, signal2]] subscribeNext:^(RACTuple *x) {
        //先进行解包
        RACTupleUnpack(NSString *signal1_Str, NSString *signal2_Str) = x;
        NSLog(@"RAC信号组合------我喜欢 %@的 %@的 妹子",signal1_Str,signal2_Str);
    }];
    
    //会注意收到 组合方法后还可以跟一个Block  /** + (RACSignal *)combineLatest:(id<NSFastEnumeration>)signals reduce:(id (^)())reduceBlock */
    /*
     reduce这个Block可以对组合后的信号量做处理
     */
    //我们还可以这样使用
    [[RACSignal combineLatest:@[signal1, signal2] reduce:^(NSString *signal1_Str, NSString *signal2_Str){
        return [signal1_Str stringByAppendingString:signal2_Str];
    }] subscribeNext:^(id x) {
        NSLog(@"RAC信号组合(Reduce处理)------我喜欢 %@ 的妹子",x);
    }];
}
```
输出结果为：
```
2016-07-02 14:34:16.149 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号合并------我喜欢： 性感妹子
2016-07-02 14:34:16.150 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号组合------我喜欢 清纯的 温柔的 妹子
2016-07-02 14:34:16.150 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号组合(Reduce处理)------我喜欢 清纯温柔 的妹子
```
----------
###* 7 RAC信号组合
```
- (void)racSignalZIP {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"年轻"];
        [subscriber sendNext:@"清纯"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"温柔"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    //zip 默认会取信号量的最开始发送的对象 所以结果会是 年轻 、温柔
    [[RACSignal zip:@[signal1,signal2]] subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSString *signal1_Str1,NSString *signal2_Str) = x;
        NSLog(@"RAC信号压缩------我喜欢 %@的 %@的 妹子",signal1_Str1, signal2_Str);
    }];
}
```
输出结果为：
```
2016-07-02 14:34:16.151 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号压缩------我喜欢 年轻的 温柔的 妹子
```
----------
###* 8 RAC信号过滤
```
- (void)racSignalFilter {
    //信号过滤可以参考上面UIButton引用RAC的实例
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(19)];
        [subscriber sendNext:@(12)];
        [subscriber sendNext:@(20)];
        [subscriber sendCompleted];
        
        return nil;
    }] filter:^BOOL(NSNumber *value) {
        if (value.integerValue < 18) {
            //18禁
            NSLog(@"RAC信号过滤------FBI Warning~");
        }
        return value.integerValue > 18;
    }]
      subscribeNext:^(id x) {
        NSLog(@"RAC信号过滤------年龄：%@",x);
   }];
    
}
```
输出结果为：
```
2016-07-02 14:34:16.151 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号过滤------年龄：19
2016-07-02 14:34:16.151 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号过滤------FBI Warning~
2016-07-02 14:34:16.152 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号过滤------年龄：20
```
----------
###* 9 RAC信号传递
```
- (void)racSignalPass {
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"老板向我扔过来一个Star"];
        return nil;
    }] flattenMap:^RACStream *(NSString *value) {
        NSLog(@"RAC信号传递------%@",value);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"我向老板扔回一块板砖"];
            return nil;
        }];
    }] flattenMap:^RACStream *(NSString *value) {
        NSLog(@"RAC信号传递------%@",value);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"我跟老板正面刚~,结果可想而知"];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        NSLog(@"RAC信号传递------%@",x);
    }];
}
```
输出结果为：
```
2016-07-02 14:34:16.152 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号传递------老板向我扔过来一个Star
2016-07-02 14:34:16.152 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号传递------我向老板扔回一块板砖
2016-07-02 14:34:16.152 ReactiveCocoaMVVMDemo[1362:1245988] RAC信号传递------我跟老板正面刚~,结果可想而知
```
----------
###* 10 RAC信号串
```
//用那个著名的脑筋急转弯说明吧，“如何把大象放进冰箱里”  第一步，打开冰箱；第二步，把大象放进冰箱；第三步，关上冰箱门。
- (void)racSignalQueue {
    //与信号传递类似，不过使用 `then` 表明的是秩序，没有传递value
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"RAC信号串------打开冰箱");
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"RAC信号串------把大象放进冰箱");
            [subscriber sendCompleted];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"RAC信号串------关上冰箱门");
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        NSLog(@"RAC信号串------Over");
    }];
}
```
输出结果为：
```
2016-07-02 17:19:53.812 ReactiveCocoaMVVMDemo[1567:2887515] RAC信号串------打开冰箱
2016-07-02 17:19:53.812 ReactiveCocoaMVVMDemo[1567:2887515] RAC信号串------把大象放进冰箱
2016-07-02 17:19:53.812 ReactiveCocoaMVVMDemo[1567:2887515] RAC信号串------关上冰箱门
```
----------
###* 11 RAC_Command介绍
```
- (void)racCommandDemo {
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"racCommandDemo------亲，帮我带份饭~");
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    //命令执行
    [command execute:nil];
}
```
输出结果为：
```
2016-07-02 17:19:53.839 ReactiveCocoaMVVMDemo[1567:2887515] racCommandDemo------亲，帮我带份饭~
```
----------
###* 12 RACSignal 的一些修饰符
```
- (void)racSignalOther {
    
    //延迟
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"RAC信号延迟-----等等我~等等我2秒"];
        [subscriber sendCompleted];
        return nil;
    }] delay:2.0] subscribeNext:^(id x) {
        NSLog(@"RAC信号延迟-----终于等到你~");
    }];
    
    //定时任务，可以代替NSTimer,可以看到`RACScheduler`使用GCD实现的
    [[RACSignal interval:60*60 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        NSLog(@"每小时吃一次药，不要放弃治疗");
    }];
    
    //设置超时时间
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"hh"];
            [subscriber sendCompleted];
            return nil;
        }] delay:4] subscribeNext:^(id x) {
            NSLog(@"RAC设置超时时间------请求到数据:%@",x);
            [subscriber sendNext:[@"RAC设置超时时间------请求到数据:" stringByAppendingString:x]];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }] timeout:3 onScheduler:[RACScheduler mainThreadScheduler]]
        subscribeNext:^(id x) {
            //在timeout规定时间之内接受到信号，才会执行订阅者的block
            //这这里3秒之内没有接受到信号，所有该次订阅已失效
            NSLog(@"请求到的数据:%@",x);
    }];
    
    //设置retry次数，这部分可以和网络请求一起用
    __block int retry_idx = 0;
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (retry_idx < 3) {
            retry_idx++;
            [subscriber sendError:nil];
        }else {
            [subscriber sendNext:@"success!"];
            [subscriber sendCompleted];
        }
        return nil;
    }] retry:3] subscribeNext:^(id x) {
        NSLog(@"请求:%@",x);
    }];
    
    //节流阀,throttle秒内只能通过1个消息
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"6"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"66"];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"666"];
            [subscriber sendCompleted];
        });
        
        return nil;
    }] throttle:2] subscribeNext:^(id x) {
        //throttle: N   N秒之内只能通过一个消息，所以@"66"是不会被发出的
        NSLog(@"RAC_throttle------result = %@",x);
    }];
    
    //条件控制
    /**
     解释：`takeUntil:(RACSignal *)signalTrigger` 只有当`signalTrigger`这个signal发出消息才会停止
     */
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            //每秒发一个消息
            [subscriber sendNext:@"RAC_Condition------吃饭中~"];
        }];
        return nil;
    }] takeUntil:[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //延迟3S发送一个消息，才会让前面的信号停止
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"RAC_Condition------吃饱了~");
            [subscriber sendNext:@"吃饱了"];
        });
        return nil;
    }]] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
```
输出结果为：
```
//延迟
2016-07-02 17:36:09.398 ReactiveCocoaMVVMDemo[2040:2898007] RAC信号延迟-----终于等到你~
//定时任务
2016-07-02 16:36:12.400 ReactiveCocoaMVVMDemo[2040:2898007] 每小时吃一次药，不要放弃治疗
2016-07-02 17:36:12.400 ReactiveCocoaMVVMDemo[2040:2898007] 每小时吃一次药，不要放弃治疗
//设置retry次数，这部分可以和网络请求一起用
2016-07-02 17:36:07.427 ReactiveCocoaMVVMDemo[2040:2898007] 请求:success!
//节流阀,throttle秒内只能通过1个消息
2016-07-02 17:36:10.404 ReactiveCocoaMVVMDemo[2040:2898007] RAC_throttle------result = 66
2016-07-02 17:36:10.404 ReactiveCocoaMVVMDemo[2040:2898007] RAC_throttle------result = 666
//takeUntil条件控制
2016-07-02 18:10:52.074 ReactiveCocoaMVVMDemo[3090:2920422] RAC_Condition------吃饭中~
2016-07-02 18:10:53.078 ReactiveCocoaMVVMDemo[3090:2920422] RAC_Condition------吃饭中~
2016-07-02 18:10:54.074 ReactiveCocoaMVVMDemo[3090:2920422] RAC_Condition------吃饭中~
2016-07-02 18:10:55.077 ReactiveCocoaMVVMDemo[3090:2920422] RAC_Condition------吃饭中~
2016-07-02 18:10:55.078 ReactiveCocoaMVVMDemo[3090:2920422] RAC_Condition------吃饱了~
```
----------
##文末

本篇文章并未很深的探讨`ReactiveCocoa`的底层实现方法，权当做抛砖引玉，给大家介绍一下`RAC`的浅析和使用

***
**Github链接和文中所引用的文章链接**
***

**如果觉得文章对你有所帮助的话，请点个Star啦~**

* 1 [文章中的链式编程和RACDemo](https://github.com/jiachenmu/ReactiveCocoaDemo)
* 2 [什么是响应式编程?](https://github.com/benjycui/introrx-chinese-edition?utm_source=tuicool&utm_medium=referral#%E4%BB%80%E4%B9%88%E6%98%AFrp)
* 3 [这样好用的ReactiveCocoa，根本停不下来](http://ios.jobbole.com/82356/)
* 4 [最快让你上手ReactiveCocoa之进阶篇](http://mobile.51cto.com/news-494321.htm)
* 5 [ReactiveCocoa v2.5 源码解析之架构总览](http://www.cocoachina.com/ios/20160106/14880.html)


