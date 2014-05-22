#!/bin/sh
#
# 脚本用于监控p2000存储服务器的磁盘阵列信息
# NAME DATE - VERSION
# ------------------------------------------
# ########  Script Modifications  ##########
# ------------------------------------------
# No    Who     WhenWhat
# ---   ---     ----        ----
# NumberNAME    DAY/MON/YEAR    MODIFIED
# 1     CZZ     05/21/2014      add
#
cmd="show vdisks"
NAGIOS_PLUGINS_PATH="/usr/lib64/nagios/plugins"
if [ ! -f $NAGIOS_PLUGINS_PATH/a.log ];then
        echo "OK - 目前信息暂时海没有获取到请稍等..." 
        exit 0
fi
source $NAGIOS_PLUGINS_PATH/connect_status.sh
if cat $NAGIOS_PLUGINS_PATH/a.log | sed -n "/$cmd/,/Success/p" | sed -n "/-------------/,/-------------/p" |  grep "OK" > /dev/null 2>&1;then
        echo "OK - 存储磁盘阵列工作正常"
        exit 0
else
        echo "WARNING - 存储磁盘阵列检测存在异常，请检查"
        exit 1

fi
