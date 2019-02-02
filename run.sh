#!/usr/bin/env bash
#ps -ef | grep run.sh | grep -v 'grep' | awk '{print $2}' | xargs kill -9
#lsof -i :4000 | grep LISTEN | awk '{print $2}' | xargs kill -9
hexo server
