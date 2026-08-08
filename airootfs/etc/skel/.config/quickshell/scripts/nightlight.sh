#!/bin/bash
case "$1" in
    on)
        pkill hyprsunset 2>/dev/null
        nohup hyprsunset -t 4000 >/dev/null 2>&1 &
        ;;
    off)
        pkill hyprsunset 2>/dev/null
        ;;
esac
