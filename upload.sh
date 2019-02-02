#!/usr/bin/env bash
hexo clean
hexo generate
cp baidu_verify_QlXZgAkD3G.html public/baidu_verify_QlXZgAkD3G.html
cp baidu_verify_kGgjmJoWEu.html public/baidu_verify_kGgjmJoWEu.html
cp googlec2ea9934f0a4f099.html public/googlec2ea9934f0a4f099.html
hexo deploy
