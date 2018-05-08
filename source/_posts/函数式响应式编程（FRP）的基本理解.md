---
title: 函数式响应式编程（FRP）的基本理解
date: 2016-06-21 14:05:01
categories: iOS
tags: [iOS]
---
## 理念
&emsp;&emsp;所有的程序都是为了完成某些任务。大多数程序员所受的训练都是命令式编程。这种模式依赖于他们希望自己的程序如何来完成这些任务：开发者编写很多的指令来修正程序的状态；如果开发者在正确的位置上编写了正确的指令，那么程序将会正确的完成任务。 
<!--more-->
&emsp;&emsp;这听起来很平凡。。。  
&emsp;&emsp;为什么编程时我们思考问题的方式停留在“怎么做”这个点上？因为计算机实际上是以一条命令来工作的，CPU的程序计算尽职尽责，按部就班：读取（指令）->执行->读取->执行。。。所以理所当然的，我们只要告诉他们“怎么做”就好了（即命令式编程）。。。多么的无聊  
&emsp;&emsp;与此相反，声明式编程（Declarative Programming）将程序员们从纷繁复杂的对如何完成某些任务的细枝末节的流程中解放出来，将关注点集中在任务到底“是什么”而非实现任务的流程。声明式编程是命令式编程之外的几种编程范式的一个总称。  
&emsp;&emsp;声明式编程（Declarative Programming）是一种编程范性，与命令式编程相对立。它描述目标的性质，让电脑明白目标，而非流程。而指令式编程则需要用算法来明确的指出每一步该怎么做。函数式响应式编程是声明式编程的子编程范式之一。  

## 函数式编程
&emsp;&emsp;在高效地进行函数式响应式编程之前，我们首先需要理解函数式编程。
### 1、高阶函数
&emsp;&emsp;函数式编程的一个关键概念是“高阶函数”。从维基百科的解释来看，一个高阶函数需要满足下面两个条件： 1、一个或者多个函数作为输入。  2、有且仅有一个函数输出。  
&emsp;&emsp;在Objective-c中我们经常使用block作为函数。我们不需要跋山涉水地去寻找‘高阶函数’，实际上，Apple为我们提供的Foundation库中就有。考虑象下面这么简单的一个NSNumber 的数组：

```
NSArray * array = @[ @(1), @(2), @(3) ];
```

我们想要枚举这个数组的内容，利用数组元素来做些事情。
“好吧”，你说， “我将写一个for循环～”
住手吧，伙计，停止写for循环,好好看看我之前说的，我们可以用一个NSArray的高阶函数来代替。代码如下：

```
for (NSNumber *number in array) NSLog(@"%@",number);
```

这个等同于下面的高阶函数:


```
[array enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *stop)
{
    NSLog(@"%@",number);
}];
```

### 2、高阶映射
&emsp;&emsp;我们要学习的第一个高阶函数是'映射[map]'.映射是在函数的层次上把一个列表变成相同长度的另一个列表，原始列表中的每一个值，在新的列表中都有一个对应的值。如下所示是一个平方数的映射：

```
map(1,2,3) => (1,4,9)
```

&emsp;&emsp;当然，这只是一个伪代码，一个高阶函数会返回另外一个函数而不是一个列表。那么我们要如何利用RXCollections呢?
&emsp;&emsp;我们这么来用rx_mapWithBlock:方法：

```
NSArray * mappedArray = [array rx_mapWithBlock:^id(id each){
    return @(pow([each integerValue],2));
}];
```

&emsp;&emsp;这将会达成上面伪代码所完成的任务，如果我们打印出array的日志，我们将会看到如下内容:

```
(
    1，
    4，
    9
)
```

&emsp;&emsp;简直完美!请注意rx_mapWithBlock: 并不是一个真正的函数映射，因为他不是技术上的高阶函数(她没有返回一个函数)。后面提到的库(RAC)已经解决了这一点,在下一章我们将看到映射是如何在ReactiveCocoa的上下文中工作的。  
&emsp;&emsp;注意rx_mapWithBlock:在没有对原数组元素进行任何修改的前提下返回了一个新的数组，这里Foundation的类真的是非常好用的一个例子，因为他们的类默认就是不可变的。  
想象一下，往常(命令式编程)为了完成这个任务，我们不得不写下这样的代码:

```
NSMutableArray *mutableArray = [NSMutableArray arryaWithCapacity:array.count];
for (NSNumber *number in array) [mutableArray addObject:@(pow([number integerValue], 2))];
NSArray *mappedArray = [NSArray arrayWithArray: mutableArray];
```

&emsp;&emsp;代码显然更多，而且还有一个无用的局部变量mutableArray污染了我们的作用域，简直是个毛线！  
所以当你想把一个列表里的元素转化为另一个列表的元素时，你就能体会到映射的强大。
### 3、高阶过滤
&emsp;&emsp;谈到ReactiveCocoa，我们要使用的另一种关键的高阶函数就是过滤器。一个列表通过过滤能够返回一个只包含了原列表中符合条件的元素的新列表，具体我们来看实践中的例子:

```
NSArray *filteredArray = [array rx_filterWithBlock:^BOOL(id each){
    return ([each integerValue] % 2 == 0);
}]
```

&emsp;&emsp;过滤后，现在filteredArray等于@[ @2 ].如果没有这样的抽象方法(即高阶过滤)，我们不得不像下面这样来完成工作:

```
NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity: array.count];
for ( NSNumber * number in array ){
    if ( [number integerValue] % 2 == 0 ){
        [mutableArray addObject:number];
    }
}
NSArray *filteredArray = [NSArray arrayWithArray:mutableArray];
```

&emsp;&emsp;有点明白了,对不对? 你可能像上面这样子写代码写了成百上千次。我们每一天的工作中涉及到类似这种高阶映射或者高阶过滤的事情有多少? 非常多！通过使用像高阶过滤、高阶映射类似的高阶函数，我们能够把这种繁琐又乏味的任务抽象出来，轻松工作，轻松生活。。。
### 4、高阶折叠
&emsp;&emsp;Flod 是一个有趣的高阶函数－她把列表中的所有元素变成一个值。一个简单的高阶折叠能够用来给数值数组求和。

```
NSNumber * sum = [array rx_foldWithBlock:^ id (id memo , id each){
    return @([memo integerValue] + [each integerValue]);
}];
```

&emsp;&emsp;输出的值为@6.数组中的每一个元素按顺序执行上述合并规则:[memo integerValue] + [each integerValue],其中memo参数纪录的是上一次合并后的结果，其初始值为零。这还不是很有趣，有趣的是我们还能给memo(这个参数的泛称)赋初始值:

```
[[array rx_mapWithBlock:^id (id each){
        return [each stringValue];
    }] rx_foldInitialValue:@"" block:^id (id memo , id each){
        return [memo stringByAppendingString:each];
}];
```

&emsp;&emsp;代码的结果:@“123”. 我们来分析一下这是怎么做到的. 首先我们对数组中的所有NSNumber对象做了映射，把他们变成了NSString对象，然后我们实现了一个高阶折叠，并给了memo变量一个空字符串。  
       在没有RXCollections的情况下能得到这样的结果吗？当然可以。但这是一个明确的"是什么，而不是如何"的解决问题的方法。这种方法可以让我们不必跟CPU一样去想"这一步要如何，下一步要如何"类似这样的事情。写代码的时候如此，读代码的时候更是如此(意:更多地关注任务是什么，要达成什么目标)
### 5、性能
&emsp;&emsp;这一章有关函数式编程的事例代码可能会让你开始担心性能的问题。例如，在一个长数组中，给每个元素创建一个过渡的字符描述并把他们追加到前面的结果中去，比起命令式编程来说，可能需要消耗更长的时间。  
&emsp;&emsp;这可能是个问题，但幸运的是，现在的计算机(甚至iPhone手机)性能已经足够强大，在大多数情况下，这种性能损耗是无关紧要的，况且当这种损耗变成一个性能瓶颈的时候，你随时都可以回头去优化她让她更加高效。CPU的时间很廉价，但是你的时间是很宝贵，因此牺牲CPU的时间会是更好的选择。
### 6、总结
&emsp;&emsp;我们使用RXCollections后不需要额外的可变变量就可以在列表上进行操作，虽然RXCollections可能隐式地生成了这样的可变变量来完成任务，但是这不是我们要关心的，因为它已经为我们抽象出了这样的方式，通过:mapping、filtering和folding这种方式让我们不必在意实现任务的步骤。(当然，这并不是说，我们不应该熟悉RXCollections的源码，只是告诉你不必按部就班地去完成任务了)  
在最后，我们也看到了，使用链式操作一次可以输出一个更为复杂的逻辑操作的结果。下一章我们将谈论更多的有关链式操作的内容———实际上，它是ReactiveCocoa中的重要语法之一。

转载请注明原地址，Clang的博客：https://chenhu1001.github.io 谢谢！