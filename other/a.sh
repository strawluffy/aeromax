#!/bin/sh
#
#	author:cuizz	date:201403011446
#	note
#	
#
#
#
####网络配置文件位置
NETWORK_FILE_DIR="/etc/sysconfig/network-scripts"
####防火墙配置文件
IPTABLES_FILE="/etc/sysconfig/iptables"
####内部网络网段
INNER_NETWORK="66.66.66.0/24"
####网关接入内部网络的端口
INNER_PORT="bond0"
####网关内部网络的IP地址
INNER_PORT_IP="66.66.66.41"
####aeromax的虚拟IP地址。
DEST_IP_ADDR="66.66.66.1"

make_network_file(){
cat > $NETWORK_FILE_DIR/ifcfg-eth$1<<EOF
DEVICE="eth$1"
BOOTPROTO="static"
ONBOOT="yes"
type="Ethernet"
EOF
check_nic_status $1
}
add_main_channel(){
    #echo "add main channel for eth$1 ip addr:$2 "
    if ! cat $IPTABLES_FILE  | grep "^##eth ${1} S$";then
        sed "1 a##eth ${1} S" -i $IPTABLES_FILE >> /dev/null 2>&1 
        sed "2 a##eth ${1} E" -i $IPTABLES_FILE >> /dev/null 2>&1 
    else
        if [ -f $IPTABLES_FILE ];then
                sed -i "/####eth ${1} MS/,/##eth ${1} ME/d" $IPTABLES_FILE >> /dev/null 2>&1
        fi
    fi
    sed "/##eth ${1} S/ a####eth ${1} MS" -i $IPTABLES_FILE >> /dev/null 2>&1
    sed "/####eth ${1} MS/ a####eth ${1} ME" -i $IPTABLES_FILE >> /dev/null 2>&1
    NETMASK="`ipcalc -p $2|awk -F= '{print $2}'`"
    NETWORK="`ipcalc -n $2|awk -F= '{print $2}'`"
    OUT_IP_ADDR="`echo $2 | awk -F/ '{print $1}'`"
    OUT_NETWORK="$NETWORK/$NETMASK"

-A POSTROUTING -o eth0 -p tcp -s 66.66.66.0/24 -d 172.18.16.0/20 --dport 1950 -j SNAT --to-source 172.18.26.63
-A INPUT -i eth0 -p tcp -d 172.18.16.0/20 --dport 1:1024 -j DROP


    USER_CHANNEL_1="-A POSTROUTING -o eth${1} -p tcp -s $INNER_NETWORK -d $OUT_NETWORK --dport 1950 -j SNAT --to-source $OUT_IP_ADDR"
    USER_CHANNEL_2="-A INPUT -i eth${1} -p tcp -d $OUT_NETWORK --dport 1:1024 -j DROP"
    sed "/####eth ${1} MS/ a${USER_CHANNEL_1}" -i $IPTABLES_FILE >> /dev/null 2>&1
    sed "/####eth ${1} MS/ a${USER_CHANNEL_2}" -i $IPTABLES_FILE >> /dev/null 2>&1
    /sbin/iptables-restore $IPTABLES_FILE
}
add_user_channel(){
    #echo "add user channel for eth$1 ip addr:$2" 

    if ! cat $IPTABLES_FILE  | grep "^##eth ${1} S$";then
    	sed "1 a##eth ${1} S" -i $IPTABLES_FILE >> /dev/null 2>&1
    	sed "2 a##eth ${1} E" -i $IPTABLES_FILE >> /dev/null 2>&1
    else
    	if [ -f $IPTABLES_FILE ];then
    		sed -i "/####eth ${1} US/,/##eth ${1} UE/d" $IPTABLES_FILE >> /dev/null 2>&1
    	fi
    fi
    sed "/##eth ${1} S/ a####eth ${1} US" -i $IPTABLES_FILE >> /dev/null 2>&1
    sed "/####eth ${1} US/ a####eth ${1} UE" -i $IPTABLES_FILE >> /dev/null 2>&1
    NETMASK="`ipcalc -p $2|awk -F= '{print $2}'`"
    NETWORK="`ipcalc -n $2|awk -F= '{print $2}'`"
    OUT_IP_ADDR="`echo $2 | awk -F/ '{print $1}'`"
    OUT_NETWORK="$NETWORK/$NETMASK"
    USER_CHANNEL_1="-A POSTROUTING -o $INNER_PORT -p tcp -s $OUT_NETWORK -d $INNER_NETWORK --dport 3001:3003 -j SNAT --to-source $INNER_PORT_IP"
    USER_CHANNEL_2="-A PREROUTING -d $OUT_IP_ADDR -p tcp --dport 3001:3003 -j DNAT --to-destination $DEST_IP_ADDR"
    USER_CHANNEL_3="-A INPUT -i eth${1} -p tcp -d $OUT_NETWORK --dport 1:1024 -j DROP"
    sed "/####eth ${1} US/ a${USER_CHANNEL_1}" -i $IPTABLES_FILE >> /dev/null 2>&1
    sed "/####eth ${1} US/ a${USER_CHANNEL_2}" -i $IPTABLES_FILE >> /dev/null 2>&1
    sed "/####eth ${1} US/ a${USER_CHANNEL_3}" -i $IPTABLES_FILE >> /dev/null 2>&1
    /sbin/iptables-restore $IPTABLES_FILE
}

delete_channel(){
    #echo "del channel eth$1"
    if [ -f $IPTABLES_FILE ];then
           sed -i "/##eth ${1} S/,/##eth ${1} E/d" $IPTABLES_FILE >> /dev/null 2>&1
    fi
    /sbin/iptables-restore $IPTABLES_FILE
}

add_channel(){
    if ! cat $IPTABLES_FILE  | grep "^##eth ${1} S$";then
        sed "1 a##eth ${1} S" -i $IPTABLES_FILE >> /dev/null 2>&1
        sed "2 a##eth ${1} E" -i $IPTABLES_FILE >> /dev/null 2>&1
	add_user_channel $1 $2
    else
		if [ "`cat $IPTABLES_FILE  |  grep "^####eth ${1} .*S$" | awk '{print $3}'`" == 'US' ];then
			delete_channel $1
			add_user_channel $1 $2
		elif [ "`cat $IPTABLES_FILE  |  grep "^####eth ${1} .*S$" | awk '{print $3}'`" == 'MS' ];then
			delete_channel $1
			add_main_channel $1 $2
		fi
    fi
}

#
#	用于集中处理干线信道参数。
#

main_channel_del(){

	if [ $1 -ge 200 ];then
		let local_var=$1-200
		MYADDR="`ip addr list | sed -n "/eth${local_var}/,/inet/p" | grep inet | awk '{print $2}'`"
		delete_channel ${local_var}
		add_user_channel ${local_var} ${MYADDR}
	elif [ $1 -ge 100 ];then
		let local_var=$1-100
		MYADDR="`ip addr list | sed -n "/eth${local_var}/,/inet/p" | grep inet | awk '{print $2}'`"
		delete_channel ${local_var}
		add_main_channel ${local_var} ${MYADDR}
	fi


}
check_nic_status(){
	ifconfig | grep eth$1 >> /dev/null 2>&1
	if [ ! $? -eq 0 ] && [ -f $NETWORK_FILE_DIR/ifcfg-eth$1 ];then
		ifup eth$1
	fi
}

del_server(){
	check_nic_status $1
        make_network_file $1
	ip addr flush eth$1
        #echo  "del server port : $1 "
###     real deal
        delete_channel $1 
}
add_server(){
        add_channel $1 $2 
	check_nic_status $1 $2
        make_network_file $1
	a="`echo "$2" | awk -F/ '{print $1}'`"
	echo "IPADDR=$a" >> $NETWORK_FILE_DIR/ifcfg-eth$1
	echo "`ipcalc -m $2`" >> $NETWORK_FILE_DIR/ifcfg-eth$1
	ip addr flush eth$1
	ip addr add dev eth$1 $2
}
####main
if [ $1 -eq 4 ] || [ $1 -eq 5 ];then
	echo "we have to exit"
	exit 0
fi
case $# in
1)
	del_server $1
;;
2)
        if [ "$2" = "zzzz" ];then
           main_channel_del $1
        else
           add_server $1 $2
        fi
;;
*)
	exit 1
;;
esac
