---
title: Vue实现跨域请求
date: 2019-02-02 14:15:44
categories: 前端
tags: [Vue]
---
一般解决跨域问题可以通过CORS跨域、JSONP和反向代理跨域。下面分别介绍这三种跨域方式：
## 1、CORS
以netty为例，支持跨域请求需要配置的返回头信息。
<!--more-->
```
FullHttpResponse response = null;
String responseStr = result.toString() + "xxxxx";
response.headers().set("response", MD5Util.getMD5Code(responseStr, true));
response.headers().set(HttpHeaderNames.ACCESS_CONTROL_EXPOSE_HEADERS, "response"); // 有增加头的配置
response.headers().set(HttpHeaderNames.CONTENT_TYPE, "application/json");
response.headers().set(HttpHeaderNames.CONTENT_LENGTH, response.content().readableBytes());
response.headers().set(HttpHeaderNames.ACCESS_CONTROL_ALLOW_ORIGIN, "*");
response.headers().set(HttpHeaderNames.ACCESS_CONTROL_ALLOW_HEADERS, "*");
response.headers().set("Access-Control-Allow-Headers", "PLATFORM,H5TOKEN,sign,UUID,RESOURCEPLATFORM,response"); // 根据实际情况配置
response.headers().set(HttpHeaderNames.CONNECTION, HttpHeaderValues.KEEP_ALIVE);
ctx.writeAndFlush(response);
```
spring全局配置
```
@Configuration
public class WebAppConfigurer extends WebMvcConfigurerAdapter {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
		        .allowedOrigins("http://192.168.89.89") // 根据情况，可以是*
                .allowedMethods("GET", "POST","DELETE")
                .allowCredentials(false).maxAge(3600);
    }
}
```
spring单接口配置
```
@CrossOrigin(origins = "*", maxAge = 3600) //* 可以改成ip地址
@PostMapping("save")
public ResponseEntity<Result> addNote(@RequestParam String noteName) {
    //
}

```
## 2、JSONP
ajax与jsonp的异同：  
1、ajax和jsonp这两种技术在调用方式上”看起来”很像，目的也一样，都是请求一个url，然后把服务器返回的数据进行处理，因此jquery和ext等框架都把jsonp作为ajax的一种形式进行了封装。  
2、但ajax和jsonp其实本质上是不同的东西。ajax的核心是通过XmlHttpRequest获取非本页内容，而jsonp的核心则是动态添加。
```
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
     <title>Untitled Page</title>
      <script type="text/javascript" src=jquery.min.js"></script>
      <script type="text/javascript">
     jQuery(document).ready(function(){ 
        $.ajax({
             type: "get",
             async: false,
             url: "http://flightQuery.com/jsonp/flightResult.aspx?code=CA1998",
             dataType: "jsonp",
             jsonp: "callback",//传递给请求处理程序或页面的，用以获得jsonp回调函数名的参数名(一般默认为:callback)
             jsonpCallback:"flightHandler",//自定义的jsonp回调函数名称，默认为jQuery自动生成的随机函数名，也可以写"?"，jQuery会自动为你处理数据
             success: function(json){
                 alert('您查询到航班信息：票价： ' + json.price + ' 元，余票： ' + json.tickets + ' 张。');
             },
             error: function(){
                 alert('fail');
             }
         });
     });
     </script>
     </head>
  <body>
  </body>
</html>
```
## 3、反向代理
配置nginx就可以实现跨域，一般在生产环境采用这种方式。具体配置如下：
```
location /ticketManagement/ {
    proxy_pass http://116.6.1.53:9001/;
    proxy_redirect off;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $http_host;
}
```
