#!/usr/bin/env bash
rm -rf .deploy_git/
rm -rf pubilc/
hexo clean
hexo generate
cp baidu_verify_pPAplH5qPr.html public/baidu_verify_pPAplH5qPr.html
cp google8819a7729474aec5.html public/google8819a7729474aec5.html
cp sitemap.xml public/sitemap.xml
cp baidusitemap.xml public/baidusitemap.xml
cp list.m3u public/list.m3u
hexo deploy
