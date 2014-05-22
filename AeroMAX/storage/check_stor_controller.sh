#!/bin/sh
source /etc/profile
. /etc/init.d/functions
cmd="show controllers"
tag="1"
CONTROL_NAME=( "上"  "下" )
NAGIOS_PLUGINS_PATH="/usr/lib64/nagios/plugins"
source $NAGIOS_PLUGINS_PATH/connect_status.sh
b=0
$NAGIOS_PLUGINS_PATH/expect_login_p2000 "$STOR_SERVER" | grep -v "Press" > $NAGIOS_PLUGINS_PATH/a.log

for i in `cat $NAGIOS_PLUGINS_PATH/a.log  | sed -n "/$cmd/,/Success/p" | grep -i  "Health:"`

do
        if [ ! $i == "Health:"  ];then

		if echo $i | grep "OK" >> /dev/null 2>&1;then
                	a[$b]=OK
                	let b=b+1
		elif echo $i | grep "Degraded" >> /dev/null 2>&1;then
			a[$b]=Degraded
                        let b=b+1
		else
			a[$b]=UNKNOWN
                        let b=b+1
			
		fi
        fi
done


for i in 0 1
do
        if  [ "${a[$i]}" ==  "OK" ];then
                RETURN="${CONTROL_NAME[$i]}控制器运行正常"
        elif  [ "${a[$i]}" = "Degraded" ] ;then
                RETURN="${CONTROL_NAME[$i]}控制器处于降级运行状态"
                let RESULT=RESULT+3
        elif  [ "${a[$i]}" = "UNKNOWN" ] ;then
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

