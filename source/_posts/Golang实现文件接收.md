---
title: Golang实现文件接收  
date: 2020-07-11 15:39:24
tags:
---
前段时间遇到一个问题，在只有nginx的情况下，实现文件的上传，突然想着利用Golang可以非常简单的来实现。分为两个部分：服务端和客户端。代码如下所示：  
<!--more-->
服务端：
```
package main
import (
	"fmt"
	"io"
	"net/http"
	"os"
)
const (
	upload_path string = "/Users/chenhu/Desktop/upload/"
)
func helloHandle(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "hello world!")
}
//上传
func uploadHandle(w http.ResponseWriter, r *http.Request) {
	//从请求当中判断方法
	if r.Method == "GET" {
		io.WriteString(w, "<html><head><title>我的第一个页面</title></head><body><form action='' method=\"post\" enctype=\"multipart/form-data\"><label>上传图片</label><input type=\"file\" name='file'  /><br/><label><input type=\"submit\" value=\"上传图片\"/></label></form></body></html>")
	} else {
		//获取文件内容 要这样获取
		file, head, err := r.FormFile("file")
		if err != nil {
			fmt.Println(err)
			return
		}
		defer file.Close()
		//创建文件
		fW, err := os.Create(upload_path + head.Filename)
		if err != nil {
			fmt.Println("文件创建失败")
			return
		}
		defer fW.Close()
		_, err = io.Copy(fW, file)
		if err != nil {
			fmt.Println("文件保存失败")
			return
		}
		//io.WriteString(w, head.Filename+" 保存成功")
		http.Redirect(w, r, "/hello", http.StatusFound)
		//io.WriteString(w, head.Filename)
	}
}
func main() {
	//启动一个http 服务器
	http.HandleFunc("/hello", helloHandle)
	//上传
	http.HandleFunc("/upload", uploadHandle)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Println("服务器启动失败")
		return
	}
	fmt.Println("服务器启动成功")
}
```
客户端：
```
package main

import (
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
)

func postFile(path string, targetUrl string) error {
	bodyBuf := &bytes.Buffer{}
	bodyWriter := multipart.NewWriter(bodyBuf)

	paths, fileName := filepath.Split(path)
	fmt.Println(paths, fileName)

	//关键的一步操作
	fileWriter, err := bodyWriter.CreateFormFile("file", fileName)
	if err != nil {
		fmt.Println("error writing to buffer")
		return err
	}

	//打开文件句柄操作
	fh, err := os.Open(path)
	if err != nil {
		fmt.Println("error opening file")
		return err
	}
	defer fh.Close()

	//iocopy
	_, err = io.Copy(fileWriter, fh)
	if err != nil {
		return err
	}

	contentType := bodyWriter.FormDataContentType()
	bodyWriter.Close()

	resp, err := http.Post(targetUrl, contentType, bodyBuf)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	resp_body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	fmt.Println(resp.Status)
	fmt.Println(string(resp_body))
	return nil
}

// sample usage
func main() {
	target_url := "http://localhost:9003/upload"
	path := os.Args[1]
	postFile(path, target_url)
}
```
