#!/bin/sh
#
#	date	:	20140312
#	author	:	cuizz
#	note:
#
#	作用：
#		在linux本地添加串口服务器对应的串口，这样就可以利用串口服务器和aeromax通过串口通信。
#	
#	参数：	
#		serial_control.sh [ip1] [ip2]
#
#		可以传递一个IP地址，也可以传递2个IP地址（高可用）
#
#	规则：
#	
#		添加成功返回0，添加失败返回：1	
#		如果本地之前添加过配置，那么重新运行脚本后会自动覆盖之前的配置。
#		
#
RUN_USER="`whoami`"
USAGE="`basename $0`  ip1 [ip2] "
MOXA_DIR="/usr/lib/npreal2/driver"
CONFIG_FILE_NAME="npreal2d.cf "

if [ ! $RUN_USER == "root" ];then
	echo "You should use root to run this scripts !"
fi

add_server(){
	if [ $# -eq 2 ];then
                MASTER_IP=$1
		$MOXA_DIR/mxaddsvr $1 $2 >> /dev/null 2>&1
        elif [ $# -eq 3 ];then
                MASTER_IP=$1
                SLAVE_IP=$2
		$MOXA_DIR/mxaddsvr -r $1 $2 $3 >> /dev/null 2>&1
        fi
}

deal() {
	if [ -x $MOXA_DIR/mxaddsvr ] && [ -x $MOXA_DIR/mxdelsvr ] && [ -f $MOXA_DIR/$CONFIG_FILE_NAME ];then
		IPADDR_ALL="`cat $MOXA_DIR/$CONFIG_FILE_NAME | sed '1,/Minor/d' | awk '{print $2,$11}' | uniq`"
		if [ -z "$IPADDR_ALL" ];then
			add_server $@
		else
			DEL_IP="`echo $IPADDR_ALL | awk '{print $1}'`"
			$MOXA_DIR/mxdelsvr $DEL_IP >> /dev/null 2>&1
			if [ $? -eq 0 ];then
				add_server $@
			fi
		fi
	else
		echo "1"
	fi

}
if [ $# -eq 2 ];then
	deal $1 $2
elif [ $# -eq 3 ];then
	deal $1 $2 $3
else
        echo ""
        echo "Wrong Syntax: `basename $0` $*"
        echo ""
        echo "Usage: $USAGE"
        echo ""
        exit 0
fi
