---
title: Realm，一个跨平台、高性能的数据库
date: 2016-06-20 14:05:14
categories: iOS
tags: [iOS]
---
## 为什么要使用Realm？
### 1、简单易用
Realm并不是一个建立在SQLite之上的ORM，而是一个基于自己的持久化引擎，简单并且快速的面向对象移动数据库。我们的用户们说分分钟就学会了怎样使用Realm，迁移App到Realm也不过只需要花几个小时，方便的Realm为他们省却了数周的开发工作。
<!--more-->
### 2、跨平台
Realm支持iOS、OS X（Objective-C和Swift）以及Android。Realm文件可以跨平台共享，让Java、Swift和Objective-C使用相同的抽象模型访问，从而让您在各个平台上使用尽可能相似的业务逻辑。
### 3、快速
得益于zero-copy的设计，Realm比普通的ORM要快很多，甚至比单独无封装的SQLite还要快。请参考iOS benchmark和Android benchmark，或者看看我们的用户们在Twitter上怎么说。
### 4、支持
您可以通过以下渠道获得迅速的官方支持：Github、StackOverflow、Twitter、微博。

## 安装
### 系统要求
1、使用 Realm 构建应用的基本要求：iOS >= 7, OS X >= 10.9，并且支持 WatchKit；  
2、需要使用 Xcode 6.4 或者以后的版本;  
3、程序支持Objective-C, Swift 1.2 & Swift 2.x。
### 动态框架
注意：动态框架与 iOS 7 不兼容，要支持 iOS 7 的话请使用"静态框架"。  
1、[下载](https://static.realm.io/downloads/objc/realm-objc-0.98.3.zip)最新的Realm发行版本，并解压；  
2、前往Xcode 工程的"General"设置项中，从ios/dynamic/、osx/、tvos/或者watchos/中将"Realm.framework"拖曳到"Embedded Binaries"选项中。确认Copy items if needed被选中后，点击Finish按钮；  
3、在单元测试目标的”Build Settings”中，在”Framework Search Paths”中添加Realm.framework的上级目录；  
4、如果希望使用Swift加载Realm，请拖动Swift/RLMSupport.swift文件到 Xcode 工程的文件导航栏中并选中Copy items if needed；  
5、如果在 iOS、watchOS 或者 tvOS 项目中使用 Realm，请在您应用目标的”Build Phases”中，创建一个新的”Run Script Phase”，并将这条脚本复制到文本框中。 因为要绕过APP商店提交的bug，这一步在打包通用设备的二进制发布版本时是必须的。
  
```
bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Realm.framework/strip-frameworks.sh"
```

### 静态框架
1、下载 Realm 的[最新版本](https://static.realm.io/downloads/objc/realm-objc-0.98.3.zip)并解压；  
2、将 Realm.framework 从 ios/static/ 文件夹拖曳到您 Xcode 项目中的文件导航器当中。确保 Copy items if needed 选中然后单击 Finish；  
3、在 Xcode 文件导航器中选择您的项目，然后选择您的应用目标，进入到** Build Phases** 选项卡中。在 Link Binary with Libraries 中单击 + 号然后添加 libc++.dylib；  
4、如果你在用 Swift 来使用 Realm，那么将位于 Swift/RLMSupport.swift 的文件拖曳进您 Xcode 项目中的文件导航器当中，确保 Copy items if needed 选中。  

## 从这里开始
Objective-C版本的 Realm 能够让您以一种安全、耐用以及迅捷的方式来高效地编写应用的数据模型层，如下例所示：

```
// 定义模型的做法和定义常规 Objective-C 类的做法类似
@interface Dog : RLMObject
@property NSString *name;
@property NSInteger age;
@end
RLM_ARRAY_TYPE(Dog)
@interface Person : RLMObject
@property NSString             *name;
@property NSData               *picture;
@property RLMArray<Dog *><Dog> *dogs;
@end
//-------------------------------------------
// 使用的方法和常规 Objective-C 对象的使用方法类似
Dog *mydog = [[Dog alloc] init];
mydog.name = @"大黄";
mydog.age = 1;
mydog.picture = nil; // 属性的值可以为空
NSLog(@"狗狗的名字： %@", mydog.name);
//-------------------------------------------
// 检索 Realm 数据库，找到小于 2 岁 的所有狗狗
RLMResults<Dog *> *puppies = [Dog objectsWhere:@"age < 2"];
puppies.count; // => 0 因为目前还没有任何狗狗被添加到了 Realm 数据库中
//-------------------------------------------
// 数据持久化操作十分简单
RLMRealm *realm = [RLMRealm defaultRealm];
[realm transactionWithBlock:^{
  [realm addObject:mydog];
}];
//-------------------------------------------
// 检索结果会实时更新
puppies.count; // => 1
//-------------------------------------------
// 可以在任何一个线程中执行检索操作
dispatch_async(dispatch_queue_create("background", 0), ^{
  Dog *theDog = [[Dog objectsWhere:@"age == 1"] firstObject];
  RLMRealm *realm = [RLMRealm defaultRealm];
  [realm beginWriteTransaction];
  theDog.age = 3;
  [realm commitWriteTransaction];
});
```

## 相关资料
https://github.com/realm/realm-cocoa  
https://realm.io/cn/docs/objc/latest/#section

Clang的技术博客：[https://chenhu1001.github.io](https://chenhu1001.github.io)

