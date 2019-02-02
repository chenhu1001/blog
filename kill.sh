#!/usr/bin/env bash
lsof -i :4000 | grep LISTEN | awk '{print $2}' | xargs kill -9
