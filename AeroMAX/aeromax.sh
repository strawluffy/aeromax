#!/bin/bash
# TO DO WHAT 
# NAME DATE - VERSION
# ------------------------------------------
# ########  Script Modifications  ##########
# ------------------------------------------
# No 	Who    	When		What
# ---	--- 	----      	----
# Num	NAME  	DAY/MON/YEAR  	MODIFIED
# 1		CZZ		09/09/2013		add
# 2 	CZZ		09/17/2013		MODIFY
# 3     


source /etc/profile

USAGE="`basename $0` [ start | stop ] PROGRAM_PATH"

process_check()
{
        if [ ! -z "`ps -ef | grep "$1" | grep -v grep`" ];then
	        return 0
	else
	        return 1
        fi
}

process_run()
{
	if [ ${3} -eq 0 ];then
		STATUS="START"
	elif [ ${3} -eq 1 ];then
		STATUS="STOP"
	fi
	count=0
	while true
	do
		process_check $1 
		if [ $? -eq $3 ];then
			if [ ! ${count} -eq 9 ];then
				if [ ${count} -eq 0 ];then
					echo "`date +%Y%m%d-%H:%M:%S` : $5\`S STATUS IS ${STATUS}" >> $6/$7
				else
					echo "`date +%Y%m%d-%H:%M:%S` : $4!" >> $6/$7
				fi
			fi
			break
		else
			case $count in
                        0)
			 	 $2  > /dev/null  2>&1 &
				sleep 2
                                ((count=$count+2))
				continue
                        ;;
                        2)
                                sleep 2
                                ((count=$count+2))
				continue
                        ;;
                        4)
                                sleep 2
                                ((count=$count+2))
				continue
			;;
			6)
				if [ $3 -eq 1 ];then
                			#kill -9 $5 
			 		kill -9 ${8}
					echo "`date +%Y%m%d-%H:%M:%S` : $5 HAS BEEN KILLED!" >> $6/$7
				fi
                                sleep 3
                                ((count=$count+3))
				continue
				
                        ;;
			*)
				echo "`date +%Y%m%d-%H:%M:%S` : [${5}] cannot be ${STATUS}ED !" >> $6/$7
				exit 1
                        esac
		fi
	done
}

aeromax_deal() {

if [ $9 -eq 0 -a -d $2 ];then
	cd $2 > /dev/null 2>&1
fi

case $1 in
	[sS][tT][aA][rR][tT])
	#nohup $JAVA_HOME/bin/java $PARA >/dev/null 2>&1 &
	process_run "$6" "nohup $3" 0  "$5 HAS BEEN STARTED" "$5" "$7" "$8"
	;;

	[sS][tT][oO][Pp])
	process_run "$6" "${10}" 1 "$5 HAS BEEN STOPPED"  "$5" "$7" "$8" "$4"
	;;

	[rR][eE][sS][tT][aA][rR][tT])	
	process_run "$6" "${10}" 1 "$5 HAS BEEN STOPPED"  "$5" "$7" "$8" "$4"
	process_run "$6" "nohup $3" 0  "$5 HAS BEEN STARTED" "$5" "$7" "$8"
	;;	
	*)
		exit 1
	;;
esac

if [ $9 -eq 0 ];then
cd - > /dev/null 2>&1
fi

}


###	main	###

# print usage

if [[ ! $# -eq 10 ]]
then
        echo ""
        echo "Wrong Syntax: `basename $0` $*"
        echo ""
        echo "Usage: $USAGE"
        echo ""
        exit 0
fi

##  $1 是start|stop $2是程序的主路径
##	$3 运行启动命令参数 $4是主程序的PID $5主程序名称日志记录
##	$6 程序进程名称 $7是日志的路径 $8是日志的名称
##	$9 是否进入程序目录 $10 程序停止命令参数
aeromax_deal "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}"
