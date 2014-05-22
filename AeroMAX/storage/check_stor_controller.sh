#!/bin/sh
#
# 脚本用于监控p2000存储服务器的控制器信息
# NAME DATE - VERSION
# ------------------------------------------
# ########  Script Modifications  ##########
# ------------------------------------------
# No    Who     WhenWhat
# ---   ---     ----        ----
# NumberNAME    DAY/MON/YEAR    MODIFIED
# 1     CZZ     05/21/2014      add
#
#
#
cmd="show controllers"
tag="1"
CONTROL_NAME=( "A"  "B" )
NAGIOS_PLUGINS_PATH="/usr/lib64/nagios/plugins"
source $NAGIOS_PLUGINS_PATH/connect_status.sh
b=0
$NAGIOS_PLUGINS_PATH/expect_login_p2000 "$STOR_SERVER" | sed -n "/show sensor-status/,/Press any/p" >> $NAGIOS_PLUGINS_PATH/a.log

for i in `cat $NAGIOS_PLUGINS_PATH/a.log  | sed -n "/$cmd/,/Success/p" | grep -i  "Health:" | awk "{print $2}"`

do
        if [ ! $i == "Health:"  ];then
                a[$b]=$i
                let b=b+1
        fi
done



for i in 0 1
do
        if  echo "${a[$i]}" | grep "OK" >> /dev/null 2>&1;then
                RETURN="${CONTROL_NAME[$i]}控制器运行正常"
        elif  echo "${a[$i]}" | grep "Degraded" >> /dev/null 2>&1;then
                RETURN="${CONTROL_NAME[$i]}控制器处于降级运行状态"
                let RESULT=RESULT+3
        else
                RETURN="${CONTROL_NAME[$i]}控制器处于未知状态"
                let RESULT=RESULT+10
        fi
        RETURN_LOCAL="$RETURN_LOCAL $RETURN"

done
case $RESULT in

0)
        echo "OK - $RETURN_LOCAL" 
        exit 0
        ;;
3|6|13)
        echo "WARNING - $RETURN_LOCAL"
        exit 1
        ;;
20)
        echo "CRITICAL - $RETURN_LOCAL"
        exit 2
        ;;
esac

