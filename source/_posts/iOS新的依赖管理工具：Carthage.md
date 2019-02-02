---
title: iOS新的依赖管理工具：Carthage
date: 2016-06-21 14:05:24
categories: iOS
tags: [iOS]
---
## 1、什么是[Carthage](https://github.com/Carthage/Carthage)
* Carthage的目标是用最简单的方式来管理Cocoa第三方框架。
* 基本的工作流如下：
  * 创建一个Cartfile文件，包含你希望在项目中使用的框架的列表。
  * 运行Carthage，将会获取列出的框架并编译它们。
  * 将编译完成的.framework二进制文件拖拽到你的Xcode项目当中。
* Carthage编译你的依赖，并提供框架的二进制文件，但你仍然保留对项目的结构和设置的完整控制。Carthage不会自动的修改你的项目文件或编译设置。
<!--more-->

## 2、Carthage与CocoaPods的不同
* CocoaPods是已存在很长时间的Cocoa依赖管理器，那么为什么要创建Carthage呢？
* CocoaPods默认会自动创建并更新你的应用程序和所有依赖的Xcode workspace。Carthage使用xcodebuild来编译框架的二进制文件，但如何集成它们将交由用户自己判断。CocoaPods的方法更易于使用，但Carthage更灵活并且是非侵入性的。
* Carthage创建的是去中心化的依赖管理器。它没有总项目的列表，这能够减少维护工作并且避免任何中心化带来的问题（如中央服务器宕机）。不过，这样也有一些缺点，就是项目的发现将更困难，用户将依赖于Github的趋势页面或者类似的代码库来寻找项目。
* CocoaPods项目同时还必须包含一个podspec文件，里面是项目的一些元数据，以及确定项目的编译方式。Carthage使用xcodebuild来编译依赖，而不是将他们集成进一个workspace，因此无需类似的设定文件。不过依赖需要包含自己的Xcode工程文件来描述如何编译。
* 最后，我们创建Carthage的原因是想要一种尽可能简单的工具（一个只关心本职工作的依赖管理器），而不是取代部分Xcode的功能，或者需要让框架作者做一些额外的工作。CocoaPods提供的一些特性很棒，但由于附加的复杂性，它们将不会被包含在Carthage当中。

## 3、安装Carthage
* 通过pkg包安装
  * Carthage提供OS X平台的pkg安装文件，可以从Github的最新[release](https://github.com/Carthage/Carthage/releases)中找到，按照引导一步步安装即可。
* 通过终端命令安装
  * 安装brew
	安装命令如下：

```
	curl -LsSf http://github.com/mxcl/homebrew/tarball/master | sudo tar xvz -C/usr/local --strip 1
```

  * 然后执行如下命令获取最新版本：

```
	brew update
```

  * 安装carthage

```
	sudo brew install carthage
```

  * 卸载的话，命令如下：

```
	sudo brew uninstall carthage
```

## 4、使用Carthage
* 创建一个Cartfile文件，将你想要使用的框架列在里面
	类似于 CocoaPods 中的 Podfile 文件，把需要的包写进去就行了，具体可参阅[官方说明](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)，如：

```
	\# 必须最低 2.3.1 版本
	github "ReactiveCocoa/ReactiveCocoa" >= 2.3.1

	\# 必须 1.x 版本
	github "Mantle/Mantle" ~> 1.0    # (大于或等于 1.0 ，小于 2.0)

	\# 必须 0.4.1 版本

	github "jspahrsummers/libextobjc" == 0.4.1

	\# 使用最新的版本

	github "jspahrsummers/xcconfigs"

	\# 使用一个私有项目，在 "development" 分支
	git "https://enterprise.local/desktop/git-error-translations.git" "development"
```

* 运行carthage update，将获取依赖文件到一个Carthage.checkout文件夹，然后编译每个依赖
* 在项目中引入依赖的 Framkework，只需要在对应Target中的Build Setting中的Framework Search Path项加入以下路径，Xcode 便会自动搜索目录下的Framework（$(SRCROOT)/Carthage/Build/iOS）

![更新carthage](http://chenhu1001.github.io/images/iOS新的依赖管理工具：Carthage_1.png)

转载请注明原地址，Clang的博客：https://chenhu1001.github.io 谢谢！
