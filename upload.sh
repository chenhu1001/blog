#!/usr/bin/env bash
hexo clean
hexo generate
cp baidu_verify_pPAplH5qPr.html public/baidu_verify_pPAplH5qPr.html
cp googlec2ea9934f0a4f099.html public/googlec2ea9934f0a4f099.html
cp sitemap.xml public/sitemap.xml
cp baidusitemap.xml public/baidusitemap.xml
hexo deploy
