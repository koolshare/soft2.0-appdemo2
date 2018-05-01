#!/bin/bash

. /koolshare/scripts/base.sh
. /koolshare/scripts/uci.sh

on_installed() {
    sleep 20
    app_init_cfg '{"appdemo2":[{"_id":"main","status":"not-init","enabled":"0", "token":" "}]}'
    app_log "installed"
}

on_start() {
    echo 'started'
}

on_stop() {
    echo 'stoped'
}

on_post() {
    echo '{"status":"ok", "description":"on_post"}'
}

on_get() {
    echo '{"status":"ok", "description":"on_get"}'
}

case $ACTION in
start)
    on_start
    ;;
post)
    on_post
    ;;
get)
    on_get
    ;;
installed)
    on_installed
    ;;
stop)
    on_stop
    ;;
help)
    echo `basename $0` 'start/post/get/installed/stop'
    ;;
*)
    on_start
    ;;
esac

