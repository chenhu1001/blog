#!/usr/bin/env bash
hexo clean
hexo generate
cp baidu_verify_pPAplH5qPr.html public/baidu_verify_pPAplH5qPr.html
cp google8819a7729474aec5.html public/google8819a7729474aec5.html
cp sitemap.xml public/sitemap.xml
cp baidusitemap.xml public/baidusitemap.xml
hexo deploy
