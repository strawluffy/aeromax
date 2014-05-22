#!/bin/sh
cmd="show vdisks"
NAGIOS_PLUGINS_PATH="/usr/lib64/nagios/plugins"
if [ ! -f $NAGIOS_PLUGINS_PATH/a.log ];then
        echo "OK - 目前信息暂时还没有获取到请稍等..." 
        exit 0
fi
if cat $NAGIOS_PLUGINS_PATH/a.log | sed -n "/$cmd/,/Success/p" | sed -n "/-------------/,/-------------/p" |  grep "OK" > /dev/null 2>&1;then
        echo "OK - 存储磁盘阵列工作正常"
        exit 0
else
        echo "WARNING - 存储磁盘阵列检测存在异常，请检查"
        exit 1

fi
