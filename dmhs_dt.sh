#!/bin/sh
#
#   create : 20140311
#   author : cuizz
#   note   : 脚本用于探测网关服务器是否可以联通转包机器
#            0表示可以联通，1表示不能联通
#            返回一般为：00,01,10,11
#
#


REMOTE_IP=$1
GATEWAY_1="172.18.16.26"
GATEWAY_2="172.18.16.31"

if ping -f -c 10 $GATEWAY_1 >> /dev/null 2>&1 ;then
	ssh $GATEWAY_1 "ping -f -c 10 $REMOTE_IP" >> /dev/null 2>&1
	if [ ! $? -eq 0 ];then
		RESULT_1=10
	fi
else
	RESULT_1=10
fi
if ping -f -c 10 $GATEWAY_2 >> /dev/null 2>&1 ;then
	ssh $GATEWAY_2 "ping -f -c 10 $REMOTE_IP" >> /dev/null 2>&1
	if [ ! $? -eq 0 ];then
		RESULT_2=1
	fi
else
	RESULT_2=1
fi
let RESULT=RESULT_1+RESULT_2
if [ $RESULT -ge 10 ];then
	echo "$RESULT"
else
	RESULT="0${RESULT}"
	echo "$RESULT"
fi
