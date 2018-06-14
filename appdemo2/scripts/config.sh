#!/bin/bash

. /koolshare/scripts/base.sh
. /koolshare/scripts/jshn.sh
. /koolshare/scripts/uci.sh

on_get() {
    appdemo2_status=`pidof appdemo2|wc -w`

    INPUT_JSON=`uci export_json appdemo2`
    json_load "$INPUT_JSON"
    json_select "appdemo2"
    json_select "1"

    if [ "$appdemo2_status"x = "2"x ];then
        json_add_string "status" "start"
    else
        json_add_string "status" "stop"
    fi
    json_dump
}

on_post() {
    local appdemo2_enabled
    local appdemo2_token

    json_load "$INPUT_JSON"
    json_select "appdemo2"
    json_select "1"
    json_get_var appdemo2_enabled "enabled"
    json_get_var appdemo2_token "token"

    app_log $appdemo2_enabled
    app_log $appdemo2_token
    if [ "$appdemo2_enabled"x = "1"x ]; then
        killall appdemo2 > /dev/null 2>&1
        $APP_ROOT/bin/appdemo2 -u $appdemo2_token -d > /dev/null 2>&1
        json_add_string "status" ""
        json_dump|app_save_cfg

        # mark as start
        json_add_string "status" "start"
        json_dump
    elif [ "$appdemo2_enabled"x = "0"x ]; then
        killall appdemo2 > /dev/null 2>&1
        json_add_string "status" ""
        json_dump|app_save_cfg

        # mark as stop
        json_add_string "status" "stop"
        json_dump
    else
        echo '{"status": "json_parse_failed"}'
    fi
}

on_start() {
    local appdemo2_enabled
    local appdemo2_token
    config_load appdemo2
    config_get appdemo2_enabled main enabled
    config_get appdemo2_token main token
    if [ "$appdemo2_enabled"x = "1"x ]; then
        killall appdemo2 > /dev/null 2>&1
        $APP_ROOT/bin/appdemo2 -u $appdemo2_token -d > /dev/null 2>&1
    else
        killall appdemo2 > /dev/null 2>&1
    fi
}

on_stop() {
    killall appdemo2 > /dev/null 2>&1
}

on_status() {
    appdemo2_status=`pidof appdemo2|wc -w`
    appdemo2_pid=`pidof appdemo2`
    appdemo2_version=`$APP_ROOT"/bin/appdemo2" -v`
    appdemo2_route_id=`$APP_ROOT"/bin/appdemo2" -w | awk '{print $2}'`
    if [ "$appdemo2_status"x = "2"x ];then
        echo 进程运行正常！版本：${appdemo2_version} 路由器ID：${appdemo2_route_id} （PID：$appdemo2_pid）
    else
        echo \<em\>【警告】：进程未运行！\<\/em\> 版本：${appdemo2_version} 路由器ID：${appdemo2_route_id}
    fi
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
    app_init_cfg '{"appdemo2":[{"_id":"main","status":"not-init","enabled":"0", "token":" "}]}'
    ;;
status)
    on_status
    ;;
stop)
    on_stop
    ;;
*)
    on_start
    ;;
esac
