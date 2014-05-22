#!/bin/sh
cmd="show power-supplies"
POWER_SUPPLY=( "左侧电源" "右侧电源" )
local=0
NAGIOS_PLUGINS_PATH="/usr/lib64/nagios/plugins"

if [ ! -f $NAGIOS_PLUGINS_PATH/a.log ];then
        echo "OK - 目前信息暂时还没有获取到请稍等..." 
        exit 0
fi
for i in $(cat $NAGIOS_PLUGINS_PATH/a.log  | sed -n "/$cmd/,/Success/p" | grep "CN8401T5" | awk '{print $6}' )
do
	POWER_STATUS[$local]=$i
	let local=local+1
done
RESULT=0
for i in 0 1
do
	if [ "${POWER_STATUS[$i]}" == "OK" ];then
		RETURN="${POWER_SUPPLY[$i]} 运行正常"
	else
		RETURN="${POWER_SUPPLY[$i]} 处于异常状态"
                let RESULT=RESULT+3
	fi
	RETURN_LOCAL="$RETURN_LOCAL $RETURN"
#	echo "${POWER_SUPPLY[$i]} status is ${POWER_STATUS[$i]}"
done


case $RESULT in

0)
        echo "OK - $RETURN_LOCAL" 
        exit 0
        ;;
3|6)
        echo "WARNING - $RETURN_LOCAL"
        exit 1
        ;;
*)
        echo "CRITICAL - $RETURN_LOCAL"
        exit 2
esac


