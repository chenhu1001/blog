---
title: Github+Hexo搭建免费个人博客
date: 2016-06-10 14:03:28
categories: 随笔
tags: [随笔]
---
经过各种找资料，踩过各种坑，终于搭建好了hexo，域名目前用的是github的，我的hexo是3.2.2版本，hexo不同的版本，很多配置都不一样。好吧，废话不多说了，开始吧。  
<!--more-->
## 正文
这篇教程是针对Mac的，之前是想着写博客，一方面是给自己做笔记，可以提升自己的写作、总结能力。一个技术点我们会使用，并不难，但是要做到让别人也能听懂，还是需要一定的技巧和经验的。很多类似于CSDN、博客园也都可以写文章，但是页面的样式我不是太喜欢，简书还算好点（我的文章在简书上也有同步）。最近看到一些大神们的博客，貌似都是用hexo写的，我也依葫芦画瓢的搭建了一个。不啰嗦了，直接上搭建步骤。
## 配置环境
### 安装Node.js（必须）
作用：用来生成静态页面。  
到Node.js[官网](https://nodejs.org/en/)下载相应平台的最新版本，按照提示一路安装即可。
### 安装Git（必须）
作用：把本地的hexo内容提交到github上去。  
如果已经安装了Xcode就自带Git，我就不多说了。
### 申请GitHub（必须）
作用：是用来做博客的远程仓库、域名、服务器之类的，怎么与本地hexo建立连接等下讲。
[Github](https://github.com/)账号我也不再啰嗦了，没有的话直接申请就行了，跟一般的注册账号差不多，SSH Keys，看你自己了，可以不配置，不配置的话以后每次对自己的博客有改动提交的时候就要手动输入账号密码，假如配置了就不需要了，怎么配置我就不多说了，网上有很多教程。
## 开始安装Hexo
### 安装Hexo
Node.js和Git都安装好后，可执行如下命令安装hexo：
  
```
$ sudo npm install -g hexo
```

### 初始化
然后，执行init命令初始化hexo到你指定的目录，我是直接cd到目标，在目录里执行如下命令:

```
$ hexo init
```

好啦，至此，全部安装工作已经完成！
### 生成静态页面
cd 到你的init目录，执行如下命令，生成静态页面至public目录。

```
$ hexo generate（hexo g也可以）
```

### 本地启动
启动本地服务，进行文章预览调试，命令：

```
$ hexo server
```

在浏览器中输入:http://localhost:4000
我不知道你们能不能，反正我不能，因为我还没有把环境配置好
我把我报的一些错，和解决方式列出来：

```
ERROR Plugin load failed: hexo-server
```

原因：

```
Besides, utilities are separated into a standalone module. hexo.util is not reachable anymore.
```

解决方法，执行命令：

```
$ sudo npm install hexo-server --save 
```

安装完成后，输入以下命令以启动服务器，您的网站会在 http://localhost:4000 下启动。在服务器启动期间，Hexo 会监视文件变动并自动更新，您无须重启服务器。
这个时候再重新生成静态文件，命令：

```
$ hexo generate（或hexo g）  
```

启动本地服务器：

```
$ hexo server
```

如果您想要更改端口，或是在执行时遇到了 EADDRINUSE 错误，可以在执行时使用 -p 选项指定其他端口，如下：

```
$ hexo server -p 5000
```
 
## 配置 Github
### 建立Repository
建立与你用户名对应的仓库，仓库名必须为【your_user_name.github.io】，固定写法。然后建立关联，我的blog在本地/Users/chenhu/Documents/Hexo，这里面有：

```
_config.yml    node_modules    public        source　　　　
db.json        package.json    scaffolds    themes
```

现在我们需要修改_config.yml文件来建立关联，命令：

```
$ vim _config.yml
```

翻到最下面，改成类似我这样子

```
deploy:
  type: git
  repository: https://github.com/chenhu1001/chenhu1001.github.io.git
  branch: master
```

执行如下命令才能使用git部署

```
$ sudo npm install hexo-deployer-git --save
```

网上会有很多说法，有的type是github，还有repository最后面的后缀也不一样，是github.com.git，我也踩了很多坑，我现在的版本是hexo:3.2.2，执行命令hexo -version就出来了，貌似3.0以后全部改成我上面这种格式了。
然后，执行配置命令：

```
$ hexo deploy
```

然后再浏览器中输入[https://chenhu1001.github.io](https://chenhu1001.github.io)就行了，我的github账户叫chenhu1001，把这个改成你github的账户名就行了。
## 部署步骤
### 步骤
每次部署的步骤，可按以下三步来进行。

```
hexo clean  
hexo generate  
hexo deploy
```

还可以将上面的3个命令封装成一个shell脚本（publish.sh），放在Hexo对应的目录下方便上传部署。
### 一些常用命令：  
hexo new "postName"&emsp;&emsp;&emsp;//新建文章  
hexo new page "pageName"&emsp;&emsp;&emsp;//新建页面  
hexo generate&emsp;&emsp;&emsp;//生成静态页面至public目录  
hexo server&emsp;&emsp;&emsp;//开启预览访问端口（默认端口4000，'ctrl + c'关闭server）  
hexo deploy&emsp;&emsp;&emsp;//将Hexo部署到GitHub  
hexo help&emsp;&emsp;&emsp;//查看帮助  
hexo version&emsp;&emsp;&emsp;//查看Hexo的版本   
&emsp\;&emsp\;&emsp;&emsp;&emsp;//段落前空两格(为了显示，没有转移符) 
<!-\-more-\-\>&emsp;&emsp;&emsp;//用于文章的隔断，显示更多  
[iOS,WebRTC,直播,FFMpeg]&emsp;&emsp;&emsp;//用于写文章时增加tag
### 一些基本路径  
文章在source/_posts下，支持Markdown语法，可以用Markdown编辑器进行编辑，如果想修改头像可以直接在主题的_config.yml文件里面修改，友情链接之类的都在这里，开始打理你的博客吧，有什么问题或者建议，都可以提出来，我会继续完善的。  
## Markdown语法 
[实用的Markdown语法例子](https://www.zybuluo.com/mdeditor)

Clang的技术博客：[https://chenhu1001.github.io](https://chenhu1001.github.io)

