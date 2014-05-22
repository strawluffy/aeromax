#!/bin/sh
cmd="show sensor-status"
STAND_TEMP_NU="43"
NAGIOS_PLUGINS_PATH="/usr/lib64/nagios/plugins"
if [ ! -f $NAGIOS_PLUGINS_PATH/a.log ];then
        echo "OK - 目前信息暂时还没有获取到请稍等..." 
        exit 0
fi
tag=1
REAL_TEMP=$(cat $NAGIOS_PLUGINS_PATH/a.log | sed -n "/$cmd/,/Success/p" | sed -n "/-------------/,/-------------/p" | grep "OK" | wc -l )
if [ "$STAND_TEMP_NU" == "$REAL_TEMP" ];then
        echo "OK - 所有温度监测点温度正常" 
        exit 0
else
        echo "WARNING - 发现异常温度器件，请检查 $REAL_TEMP"
        exit 1
	
fi
