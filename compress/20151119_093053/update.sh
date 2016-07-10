#! /bin/sh

IsTargzFile()
{
	FILENAME=$1
	TMPVAL=${FILENAME%".tar.gz"}
	test "${TMPVAL}" = "${FILENAME}" 
	if [ $? -eq "0" ];then
		return 1 
	else
		return 0
	fi
}

IsZipFile()
{
	FILENAME=$1
	TMPVAL=${FILENAME%".zip"}
	test "${TMPVAL}" = "${FILENAME}" 
	if [ $? -eq "0" ]; then
		return 1
	else
		return 0
	fi
}

#产品可根据实际keeper配置文件存储位置修改ChangeAppStartPath()
ChangeAppStartPath()
{
	if [ -e /mnt/log/update/config.kp ]; then
		FILEPATH="/mnt/log/update/"
		FILENAME="config.kp"
		BAKFILENAME="config_bak.kp"
		cp "${FILEPATH}${FILENAME}" "${FILEPATH}${BAKFILENAME}"
		sed -i 's:/app_bin0:/app_bin5:' ${FILEPATH}${BAKFILENAME}
		sed -i 's:/app_bin1:/app_bin0:' ${FILEPATH}${BAKFILENAME}
		sed -i 's:/app_bin5:/app_bin1:' ${FILEPATH}${BAKFILENAME}
		excute_shell_order "rm -f  ${FILEPATH}${FILENAME}"
		excute_shell_order "mv ${FILEPATH}${BAKFILENAME} ${FILEPATH}${FILENAME}"
	else
		if [ ! -d /mnt/log/update ];then
			mkdir /mnt/log/update
		fi
		echo $RUNNING_APP | grep app_bin0 > /dev/null 2>&1
        	if [ $? -ne "0" ]; then
			echo "#name  mem(kB) cpu  ommand" > /mnt/log/update/config.kp
			echo "app_arm 128000 100  /mnt/app_bin0/bin_arm/app_arm" >> /mnt/log/update/config.kp
			echo "app_arm 128000 100  /mnt/app_bin1/bin_arm/app_arm" >> /mnt/log/update/config.kp
        	else
			echo "#name  mem(kB) cpu  ommand" > /mnt/log/update/config.kp
			echo "app_arm 128000 100  /mnt/app_bin1/bin_arm/app_arm" >> /mnt/log/update/config.kp
			echo "app_arm 128000 100  /mnt/app_bin0/bin_arm/app_arm" >> /mnt/log/update/config.kp
        	fi
	fi
	return 0
}

excute_shell_order()
{
	for try_cnt in `seq 1 10`
	do
		$1
		retcode=$?
		if [ $retcode -eq 0 ];then 
			return 0
		fi	
		echo "`date` [APP update] INFO: can not excute shell: \"$1\", retcode: $retcode" >> /home/update/update.log
		usleep 100000
	done
	echo "`date` [APP update]  ERR: can not excute shell: \"$1\", retcode: $retcode" >> /home/update/update.log
	echo "ERR: can not excute shell: \"$1\", retcode: $retcode"
	exit 5
}

#监听app_arm进程，如果不在则杀掉占用/dev/watchdog的进程再自行喂狗
#产品根据实际升级时间在合适的地方调用该函数
watch_app_arm()
{
	pidof app_arm > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		for kill_cnt in `seq 1 1000`
		do
			(watchdog -t 10ms /dev/watchdog) > /dev/null 2>&1
			if [ $? -eq 0 ]; then
				echo "`date` [BSP update] WARN: app isn't running, kill keeper times: $kill_cnt" >> /home/update/update.log
				return 0
			fi
			
			RUNNING_PROCESS=`ps |grep -v grep |awk '{print $1}' |grep -v PID`
			for process_id in $RUNNING_PROCESS
			do
				(ls -lh /proc/$process_id/fd |grep /dev/watchdog) >/dev/null  2>&1
				if [ $? -eq 0 ]; then 
					kill -9 $process_id
				fi
			done

			usleep 10000
		done
		echo "`date` [BSP update]  ERR: can not watch dog" >> /home/update/update.log
		echo "ERR: can not watch dog"
		exit 1
	fi
	return 0
}

#add by KF70786
#结束APP进程并结束keeper及其它占/dev/watchdog设备进程,自己接管喂狗
exit_app_process()
{
	pidof app_arm > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		for kill_cnt in `seq 1 1000`
		do
			#为了释放app进程占用的flash空间，将app进程杀死，并马上watch app_arm
			#echo $kill_cnt >> /home/update/update.log
			(kill -9 `pidof app_arm`) > /dev/null 2>&1
			pidof app_arm > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo "`date` [BSP update] INFO: kill app times: $kill_cnt and watch app_arm immediately" >> /home/update/update.log
				break
			fi	
				
			usleep 10000
		done
		if [ 1000 -eq $kill_cnt ];then
			echo "`date` [BSP update]  ERR: can not kill app" >> /home/update/update.log
			echo "ERR: can not kill app"
			return 1
		fi
	fi
	
	#结束APP后，结束keeper及其它占/dev/watchdog设备进程,自己接管喂狗
	for kill_cnt in `seq 1 1000`
	do
		(watchdog -t 10ms /dev/watchdog) > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "`date` [BSP update] WARN: app isn't running, kill keeper times: $kill_cnt" >> /home/update/update.log
			return 0
		fi
			
		RUNNING_PROCESS=`ps |grep -v grep |awk '{print $1}' |grep -v PID`
		for process_id in $RUNNING_PROCESS
		do
			(ls -lh /proc/$process_id/fd |grep /dev/watchdog) >/dev/null  2>&1
			if [ $? -eq 0 ]; then 
				kill -9 $process_id
			fi
		done

		usleep 10000
	done
	echo "`date` [BSP update]  ERR: can not watch dog" >> /home/update/update.log
	echo "ERR: can not watch dog"
	return 1
}

#update_so只支持形如"libname_版本号*"的so库
update_so()
{
	lib_name=${1%_*}
	lib_num=`find /home/so_bin/ -name ""$lib_name"_*" |wc -l`

	if [ $lib_num -eq "0" ]; then
		#so文件不存在，直接更新
		excute_shell_order "cp  ${INPUTPATH}/$1		/home/so_bin" 
	elif [ $lib_num -eq "1" ]; then
		if ! [ -e /home/so_bin/$1 ]; then
			#当前已存在的so库文件与要更新的so库文件不一致，更新
			excute_shell_order "cp  ${INPUTPATH}/$1		/home/so_bin" 
		else
			diff ${INPUTPATH}/$1 /home/so_bin/$1 > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				#同名so文件，内容不一致
				excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
			fi
		fi
	else
		#删除较老版本的so库
		if ! [ -e /home/so_bin/$1 ]; then #新库不存在，直接删除旧版本文件
			old_lib=`find /home/so_bin/ -name ""$lib_name"_*" |sort |awk 'NR==1'`
			excute_shell_order "rm -rf $old_lib"
			#更新
			excute_shell_order "cp  ${INPUTPATH}/$1		/home/so_bin" 
		else
			diff ${INPUTPATH}/$1 /home/so_bin/$1 > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo "`date` [BSP update]  copy" >> /home/update/update.log
				#同名so文件，内容不一致
				excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
			fi
		fi
	fi
}

update_so1()
{
	lib_name=${1%.so.*}
	lib_num=`find /home/so_bin/ -name ""$lib_name".so.*" |wc -l`

	if [ $lib_num -eq "0" ]; then
		#so文件不存在，直接更新
		excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
	elif [ $lib_num -eq "1" ]; then
		if ! [ -e /home/so_bin/$1 ]; then
			#当前已存在的so库文件与要更新的so库文件不一致，更新
			excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
		else
			diff ${INPUTPATH}/$1 /home/so_bin/$1 > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				#同名so文件，内容不一致
				excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
			fi
		fi
	else
		#删除较老版本的so库
		if ! [ -e /home/so_bin/$1 ]; then
			old_lib=`find /home/so_bin/ -name ""$lib_name".so.*" |sort |awk 'NR==1'`
			excute_shell_order "rm -rf $old_lib"
			#更新
			excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
		else
			diff ${INPUTPATH}/$1 /home/so_bin/$1 > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo "`date` [BSP update]  copy" >> /home/update/update.log
				#同名so文件，内容不一致
				excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
			fi
		fi
	fi
}

#从运行目录移出so库等比较大的文件到home下，并软连接过去
# $1 当前运行目录,例如/mnt/app_bin0/bin_arm
# $2 拷贝目标目录,例如/home/app_bin0
link_to_home()
{
	echo "INFO: link_to_home $1 $2" 
	
	#不是软连接，需要1）复制mnt到home；2）删除mnt；3）建立软连接
	#是软连接则不做操作
	if [ -L $1/web_server ]; then
		echo "INFO:  soft link $1/web_server..." 
	else
		if [ -e $1/web_server ]; then #mnt下存在
			if [ ! -e $2/web_server ]; then #home下不存在
				echo "INFO: cp webserver from $1 to $2" 
				excute_shell_order "cp -f $1/web_server $2"
			fi
			echo "INFO: link $2/web_server..." 
			excute_shell_order "rm -f $1/web_server"
		fi
		echo "INFO:  build soft link $1/web_server..."
		excute_shell_order "ln -s $2/web_server $1/web_server"
	fi
	
	if [ -L $1/snmp_cfg.bin ]; then
		echo "INFO:  soft link $1/snmp_cfg.bin..." 
	else
		if [ -e $1/snmp_cfg.bin ]; then #mnt下存在
			if [ ! -e $2/snmp_cfg.bin ]; then #home下不存在
				echo "INFO: cp snmp_cfg.bin from $1 to $2" 
				excute_shell_order "cp -f $1/snmp_cfg.bin $2"
			fi
			echo "INFO: link $2/snmp_cfg.bin..." 
			excute_shell_order "rm -f $1/snmp_cfg.bin"
		fi
		echo "INFO:  build soft link $1/snmp_cfg.bin..." 
		excute_shell_order "ln -s $2/snmp_cfg.bin $1/snmp_cfg.bin"
	fi
	
	if [ -L $1/apploadso ]; then
		echo "INFO:  soft link $1/apploadso..." 
	else
		if [ -d $1/apploadso ]; then #mnt下存在
			if [ ! -d $2/apploadso ]; then #home下不存在
				echo "INFO: cp apploadso from $1 to $2" 
				excute_shell_order "cp -rf $1/apploadso $2"
			fi
			echo "INFO: link $2/apploadso..." 
			excute_shell_order "rm -rf $1/apploadso"
		fi
		echo "INFO:  build soft link $1/apploadso..."
		excute_shell_order "ln -s $2/apploadso $1/apploadso"
	fi
}

# 如果没有参数，返回
if [ $# -lt 1 ]; then	
	echo "[Uage] ./update.sh xxxx.tar.gz updateall"
	echo $#
	return 0
fi

# 如果参数是两个，验证参数2 是否为 “updateall”
if [ $# -eq 2 ]; then	
	if [ $2 != "updateall" ]; then
		echo "[Uage] ./update.sh xxxx.tar.gz updateall"
		return 0
	fi
fi

if [ ! -d /home/update ];then
	mkdir /home/update
fi

if [ ! -d /mnt/app_bin0/bin_arm ];then
	mkdir /mnt/app_bin0/bin_arm
fi

if [ ! -d /mnt/app_bin1/bin_arm ];then
	mkdir /mnt/app_bin1/bin_arm
fi

if [ -e /home/update/update.log ]; then
	if [ `du -k /home/update/update.log |awk '{print $1}'` -gt 100 ]; then
		mv /home/update/update.log /home/update/update_bak.log
	fi
fi

SCRIPT_VERSION=V1.0.2
BSP_VERSION=`version`
pidof app_arm > /dev/null 2>&1
if [ $? -eq 0 ]; then
	RUNNING_APP=`cat /proc/\`pidof app_arm\`/cmdline`
	if [ -e ${RUNNING_APP%app_arm*}config/version ]; then
		APP_VERSION=`cat ${RUNNING_APP%app_arm*}config/version`
	fi
else
	#默认当前运行的是app1，这样就可以默认升级app0
	RUNNING_APP="/mnt/app_bin1/bin_arm/app_arm"
fi


INPUTFILENAME=$1	
INPUTNAME=${INPUTFILENAME##*/}	
INPUTPATH=${INPUTFILENAME%${INPUTNAME}*}

if [ ${#INPUTPATH} -eq 0 ];then
	INPUTPATH=`pwd`
fi

echo -e "\n`date` [APP update] INFO: ==============APP update Start==============" >> /home/update/update.log
echo "`date` [APP update] INFO:   Script  Version: $SCRIPT_VERSION" >> /home/update/update.log
echo "`date` [APP update] INFO:   BSP     Version:${BSP_VERSION##*:}" >> /home/update/update.log
echo "`date` [APP update] INFO:   Product Version: ${APP_VERSION##*=}" >> /home/update/update.log
echo "`date` [APP update] INFO: ============================================" >> /home/update/update.log

#一键升级工具一上来就结束APP进程及keeper
if [ $# -eq 2 ]; then
	if [ $2 == "updateall" ]; then
		exit_app_process
		if [ $? -ne 0 ]; then
			#echo "ERR: exit app process error"
			return 1
		fi
		
		#删除占用/mnt/app_bin0及/mnt/app1的进程
		kill -9 `fuser -m /mnt/app_bin0`
		kill -9 `fuser -m /mnt/app_bin1`
	fi
fi

#watch dog
watch_app_arm

echo "`date` decompress update package..." >> /home/update/update.log
echo "decompress update package..."
if IsTargzFile $1; then
	watch_app_arm
	tar -zxf $1  -C $INPUTPATH 
	if  [ $? -eq 1 ]
	then
		echo "`date` [APP update]  ERR: tar $1 fail">> /home/update/update.log
		echo "ERR: tar $1 fail"
		return 2
	fi
elif IsZipFile $1; then
	watch_app_arm
	unzip -o $1   
	if  [ $? -eq 1 ]
	then
		echo "`date` [APP update]  ERR: unzip $1 fail" >> /home/update/update.log
		echo "ERR: unzip $1 fail"
		return 3
	fi
elif [ $1 == "updateappload" ];then
	echo "`date` [APPLOAD update]  info: start ..." >> /home/update/update.log
else
	echo "`date` [APP update]  ERR: unsupported update package" >> /home/update/update.log
	echo "ERR: unsupported update package"
	return 4
fi	

#determine which partion to update 
echo $RUNNING_APP | grep app_bin0 > /dev/null 2>&1
if [ $? -eq 0 ];then
	TARGET_PATH=/mnt/app_bin1/bin_arm/
	OTHER_TARGET_PATH=/mnt/app_bin0/bin_arm/
	LINK_TARGET_PATH=/home/app_bin1/
	LINK_OTHER_TARGET_PATH=/home/app_bin0/
else 
	TARGET_PATH=/mnt/app_bin0/bin_arm/
	OTHER_TARGET_PATH=/mnt/app_bin1/bin_arm/
	LINK_TARGET_PATH=/home/app_bin0/
	LINK_OTHER_TARGET_PATH=/home/app_bin1/
fi
#create link dir
excute_shell_order "mkdir -p $LINK_TARGET_PATH"
excute_shell_order "mkdir -p $LINK_OTHER_TARGET_PATH"

#app can modify the following codes to customize updating scheme
echo "`date` update app to $TARGET_PATH..." >> /home/update/update.log
echo "update app to $TARGET_PATH..."
#backup bspversioninfo.emap

if [ -e $TARGET_PATH/bspversioninfo.emap ];then
	cp $TARGET_PATH/bspversioninfo.emap /tmp/bspversioninfo.emap
fi

#一键升级工具一上来就结束APP进程及keeper
if [ $# -eq 2 ]; then
	if [ $2 == "updateall" ]; then
		exit_app_process
		if [ $? -ne 0 ]; then
			#echo "ERR: exit app process error"
			return 1
		fi
		
		#删除占用/mnt/app_bin0及/mnt/app1的进程
		kill -9 `fuser -m /mnt/app_bin0`
		kill -9 `fuser -m /mnt/app_bin1`
		excute_shell_order "rm -rf $TARGET_PATH*"
		echo "`date` [update]  INFO: RM -rf $TARGET_PATH*" >> /home/update/update.log
		excute_shell_order "rm -rf $OTHER_TARGET_PATH*"
		echo "`date` [update]  INFO: RM -rf $OTHER_TARGET_PATH*" >> /home/update/update.log
		excute_shell_order "rm -rf $LINK_TARGET_PATH*"
		echo "`date` [update]  INFO: RM -rf $LINK_TARGET_PATH*" >> /home/update/update.log
		excute_shell_order "rm -rf $LINK_OTHER_TARGET_PATH*"
		echo "`date` [update]  INFO: RM -rf $LINK_OTHER_TARGET_PATH*" >> /home/update/update.log
	fi
fi

#一键升级不进入
if [ $# -ne 2 ]; then
	## =============================================================================
	## 排除删除的2个文件夹和一个bspversioninfo.emap文件
	keep_dir0=apploadso
	keep_dir1=apploadbin
	keep_file0=bspversioninfo.emap
	keep_webserver=web_server
	keep_snmpcfg=snmp_cfg.bin
	b9_Temp_File=/tmp/update/b9_update_record.emap
	if [ -d $TARGET_PATH ];then
		watch_app_arm
		if [ -e $b9_Temp_File ];then
			echo "`date` [APPLoad update]  INFO: Exist $b9_Temp_File" >> /home/update/update.log
			cd $TARGET_PATH
			clear_cmd=`ls |grep -v "$keep_dir0\|$keep_dir1"`
			#echo "rm filter:$clear_cmd"
			excute_shell_order "rm -rf $clear_cmd"
			cd -
			echo "`date` [APPLoad update]  INFO: RM -rf $clear_cmd" >> /home/update/update.log
		else
			excute_shell_order "rm -rf $TARGET_PATH*"
			echo "`date` [APPLoad update]  INFO: RM -rf $TARGET_PATH*" >> /home/update/update.log
			excute_shell_order "rm -rf $LINK_TARGET_PATH*"
			echo "`date` [APPLoad update]  INFO: RM -rf $LINK_TARGET_PATH*" >> /home/update/update.log
		fi
	fi 
	if [ -d $OTHER_TARGET_PATH$keep_dir0 ];then
		#file0index=`find $OTHER_TARGET_PATH$keep_dir0 -name "*.sh" |wc -l`
		file0index=`ls $OTHER_TARGET_PATH$keep_dir0 | cat | grep ".sh" |wc -l`
		#echo "Curr SO Exist $file0index"
		echo "`date` [APPLoad update]  INFO: Curr SO Exist $file0index" >> /home/update/update.log
		#if [ $file0index != 0 ];then
			file0index=0
			for filename in $OTHER_TARGET_PATH$keep_dir0/*.sh;
			do
				#echo "SO File $filename"
				matchstr=${filename##*/}
				matchstr=${matchstr%.*}
				if [ -e $b9_Temp_File ]; then
					#echo "file:$filename $matchstr"
					cat $b9_Temp_File |grep -q "^$matchstr$"
					if [ $? != 0 ];then
						excute_shell_order "$filename 2"
						#echo "file:$filename $matchstr"
						echo "`date` [APPLoad update]  INFO: So Not In Temp Cp $matchstr" >> /home/update/update.log
					fi
				else
					excute_shell_order "$filename 2"
					#echo $filename $matchstr
					echo "`date` [APPLoad update]  INFO: Curr So App Cp $matchstr" >> /home/update/update.log
				fi
				let "file0index+=1"
			done
		
		#fi
	fi
	echo $file0index
	watch_app_arm
	if [ -d $OTHER_TARGET_PATH$keep_dir1 ];then
		file1index=`find $OTHER_TARGET_PATH$keep_dir1 -name "*.sh" |wc -l`
		echo "`date` [APPLoad update]  INFO: Curr App Exist $file1index" >> /home/update/update.log
		if [ $file1index != 0 ];then
			file1index=0
			for filename in $OTHER_TARGET_PATH$keep_dir1/*.sh;
			do
				matchstr=${filename##*/}
				matchstr=${matchstr%.*}
				if [ -e $b9_Temp_File ]; then
					#echo "file:$filename $matchstr"
					cat $b9_Temp_File |grep -q "^$matchstr$"
					if [ $? != 0 ];then
						excute_shell_order "$filename 2"
						#echo "file:$filename $matchstr"
						echo "`date` [APPLoad update]  INFO: Bin Not In Temp Cp $matchstr" >> /home/update/update.log
					fi
				else
					excute_shell_order "$filename 2"
					#echo $filename $matchstr
					echo "`date` [APPLoad update]  INFO: Curr Bin App Cp $matchstr" >> /home/update/update.log
				fi
				let "file1index+=1"
			done
		fi
	fi
	if [ -e $b9_Temp_File ];then
		rm -rf $b9_Temp_File
	fi

	#拷贝temp路径下web_server.sh和web_server.emap到目标目录下
	if [ ! -d ${TARGET_PATH}${keep_dir1} ];then
		echo " `date` [APPLoad update] INFO: mkdir ${TARGET_PATH}${keep_dir1}" >> /home/update/update.log
		mkdir -p ${TARGET_PATH}${keep_dir1}
	fi

	if [ -e ${INPUTPATH}${keep_dir1}/web_server.sh ];then
		cp ${INPUTPATH}${keep_dir1}/web_server.sh ${TARGET_PATH}${keep_dir1}/web_server.sh
		echo " `date` [APPLoad update] INFO: cp web_server.sh" >> /home/update/update.log
	fi

	if [ -e ${INPUTPATH}${keep_dir1}/web_server.emap ];then
		cp ${INPUTPATH}${keep_dir1}/web_server.emap ${TARGET_PATH}${keep_dir1}/web_server.emap
		echo " `date` [APPLoad update] INFO: cp web_server.emap" >> /home/update/update.log
	fi

	if [ $# -eq 1 ]; then
		if [ $1 == "updateappload" ]; then
			watch_app_arm
			if [ -d $TARGET_PATH -a -d $OTHER_TARGET_PATH ];then
				cd $OTHER_TARGET_PATH
				#webserver和snmp.bin两个文件也要排除，单独拷贝
				filter_dir=`ls |grep -v "$keep_dir0\|$keep_dir1\|$keep_file0\|$keep_webserver\|$keep_snmpcfg"`
				#echo "cp filter:$filter_dir"
				excute_shell_order "cp -rf $filter_dir $TARGET_PATH"
				watch_app_arm
				if [ -e /tmp/bspversioninfo.emap ];then
					excute_shell_order "cp -rf /tmp/bspversioninfo.emap $TARGET_PATH$keep_file0"
					echo "`date` [APPLoad update] INFO: cp $TARGET_PATH$keep_file0" >> /home/update/update.log
				fi
				#web_server snmp_cfg.bin两个文件从不是软连接home下面拷贝，否则当前目录拷贝
				#如果不是软连接就直接拷贝，否则从home下拷贝
				if [ -L $keep_webserver ];then #是软连接，从home下拷贝
					excute_shell_order "cp -rf $LINK_OTHER_TARGET_PATH/web_server $LINK_TARGET_PATH$keep_webserver"
					echo "`date` [APPLoad update] INFO: cp home $LINK_TARGET_PATH$keep_webserver" >> /home/update/update.log
				else #不是软连接，直接拷贝
					excute_shell_order "cp -rf $keep_webserver $LINK_TARGET_PATH"
					echo "`date` [APPLoad update] INFO: cp current $LINK_TARGET_PATH$keep_webserver" >> /home/update/update.log
				fi
				if [ -L $keep_snmpcfg ];then #是软连接，从home下拷贝
					excute_shell_order "cp -rf $LINK_OTHER_TARGET_PATH/snmp_cfg.bin $LINK_TARGET_PATH$keep_snmpcfg"
					echo "`date` [APPLoad update] INFO: cp home $LINK_TARGET_PATH$keep_snmpcfg" >> /home/update/update.log
				else #不是软连接，直接拷贝
					excute_shell_order "cp -rf $keep_snmpcfg $LINK_TARGET_PATH"
					echo "`date` [APPLoad update] INFO: cp current $LINK_TARGET_PATH$keep_snmpcfg" >> /home/update/update.log
				fi
				link_to_home $TARGET_PATH $LINK_TARGET_PATH
				cd -
				ChangeAppStartPath
				# 同步文件到flash 执行2次
				excute_shell_order "sync"
				excute_shell_order "sync"
				echo "`date` [APPLoad update] INFO: cp $filter_dir OK and change start path ok" >> /home/update/update.log
				echo "OK"
				return 0
			fi
			echo "`date` [APPLoad update]  ERR:  Dir not exist" >> /home/update/update.log
			return 1
		fi
	fi
	## 升级脚本兼容从不支持APP加载版本到支持APP加载版本
	Emap_version=${OTHER_TARGET_PATH}emap_version.txt
	if [ ! -e $Emap_version ]; then
		echo "`date` [APPLoad update] INFO: BEFORE V1R3" >> /home/update/update.log
		
		if [ -d ${TARGET_PATH}${keep_dir0} ]; then
			excute_shell_order "rm -rf ${TARGET_PATH}${keep_dir0}"
			echo "`date` [APPLoad update] INFO: RM old $keep_dir0" >> /home/update/update.log
		fi
		
		if [ -d ${TARGET_PATH}${keep_dir1} ]; then
			excute_shell_order "rm -rf ${TARGET_PATH}${keep_dir1}"
			echo "`date` [APPLoad update] INFO: RM old $keep_dir1" >> /home/update/update.log
		fi
		
		watch_app_arm
		
		if [ -d ${INPUTPATH}${keep_dir0} ]; then
			echo "`date` [APPLoad update] INFO: cp ${INPUTPATH}${keep_dir0} " >> /home/update/update.log
			excute_shell_order "cp -rf ${INPUTPATH}${keep_dir0}		$TARGET_PATH"
		fi
		
		if [ -d ${INPUTPATH}${keep_dir1} ]; then
			echo "`date` [APPLoad update] INFO: cp ${INPUTPATH}${keep_dir1} " >> /home/update/update.log
			excute_shell_order "cp -rf ${INPUTPATH}${keep_dir1}		$TARGET_PATH"
		fi
	else
		# emap_version.txt文件是从V100R003开始的，找到即为不支持
		cat $Emap_version |grep -q "V100R003"
		if [ $? == 0 ];then
			echo "`date` [APPLoad update] INFO: V1R3 update" >> /home/update/update.log
			
			if [ -d ${TARGET_PATH}${keep_dir0} ]; then
				excute_shell_order "rm -rf ${TARGET_PATH}${keep_dir0}"
				echo "`date` [APPLoad update] INFO: RM old $keep_dir0" >> /home/update/update.log
			fi
			
			if [ -d ${TARGET_PATH}${keep_dir1} ]; then
				excute_shell_order "rm -rf ${TARGET_PATH}${keep_dir1}"
				echo "`date` [APPLoad update] INFO: RM old $keep_dir1" >> /home/update/update.log
			fi
		
			watch_app_arm
			if [ -d ${INPUTPATH}${keep_dir0} ]; then
				echo "`date` [APPLoad update] INFO: cp ${INPUTPATH}${keep_dir0} " >> /home/update/update.log
				excute_shell_order "cp -rf ${INPUTPATH}${keep_dir0}		$TARGET_PATH"
			fi
			
			if [ -d ${INPUTPATH}${keep_dir1} ]; then
				echo "`date` [APPLoad update] INFO: cp ${INPUTPATH}${keep_dir1} " >> /home/update/update.log
				excute_shell_order "cp -rf ${INPUTPATH}${keep_dir1}		$TARGET_PATH"
			fi
		fi
		echo "`date` [APPLoad update] INFO: AFTER V1R3" >> /home/update/update.log
	fi
fi

if [ -e /tmp/bspversioninfo.emap ];then
	cp /tmp/bspversioninfo.emap $TARGET_PATH/bspversioninfo.emap
fi

#remove 
#excute_shell_order "rm -rf $TARGET_PATH/*"	

#update
excute_shell_order "cp  ${INPUTPATH}/app.cfg        	$TARGET_PATH"
echo "INFO: cp ${INPUTPATH}/app_arm..."
excute_shell_order "cp  ${INPUTPATH}/app_arm		$TARGET_PATH"
excute_shell_order "cp  ${INPUTPATH}/init_env		$TARGET_PATH"
watch_app_arm

if [ -e ${INPUTPATH}/web_server ]; then
	echo "INFO: ${INPUTPATH}/web_server..." 
	excute_shell_order "cp  ${INPUTPATH}/web_server		$LINK_TARGET_PATH" 
fi

if [ -d ${INPUTPATH}/config ]; then
	echo "INFO: cp ${INPUTPATH}/config..."
	excute_shell_order "cp -rf ${INPUTPATH}/config		$TARGET_PATH"
fi

if [ -d ${INPUTPATH}/webpage ]; then
	echo "INFO: cp ${INPUTPATH}/webpage..."
	excute_shell_order "cp -rf ${INPUTPATH}/webpage 	$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/auth.txt ]; then
	excute_shell_order "cp  ${INPUTPATH}/auth.txt		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/ca.crt ]; then
	excute_shell_order "cp  ${INPUTPATH}/ca.crt		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/debug_define.conf ]; then
	excute_shell_order "cp  ${INPUTPATH}/debug_define.conf	$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/debugging ]; then
	excute_shell_order "cp  ${INPUTPATH}/debugging		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/route.txt ]; then
	excute_shell_order "cp  ${INPUTPATH}/route.txt		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/snmp_cfg.bin ]; then
	excute_shell_order "cp  ${INPUTPATH}/snmp_cfg.bin		$LINK_TARGET_PATH"
fi

if [ -e ${INPUTPATH}/HUAWEI-MIB.mib ]; then
	excute_shell_order "cp  ${INPUTPATH}/HUAWEI-MIB.mib	$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/tomcat_client.crt ]; then
	excute_shell_order "cp  ${INPUTPATH}/tomcat_client.crt	$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/tomcat_client.key ]; then
	excute_shell_order "cp  ${INPUTPATH}/tomcat_client.key	$TARGET_PATH"
fi 

if [ -d ${INPUTPATH}/kp ]; then
	excute_shell_order "cp ${INPUTPATH}/kp/keeper /mnt/kp/" 
fi 

if [ -d ${INPUTPATH}/kp ]; then
	excute_shell_order "cp ${INPUTPATH}/kp/privilege_config /mnt/kp/" 
fi
if [ -d ${INPUTPATH}/kp ]; then
	excute_shell_order "cp ${INPUTPATH}/kp/privilege_emap /mnt/kp/" 
fi
if [ -d ${INPUTPATH}/kp ]; then
	excute_shell_order "cp ${INPUTPATH}/kp/privilege_product /mnt/kp/" 
fi 
if [ -e ${INPUTPATH}/equiptest ]; then
	excute_shell_order "cp  ${INPUTPATH}/equiptest		$TARGET_PATH"
fi

if [ -d ${INPUTPATH}/ko ]; then
	excute_shell_order "cp -rf ${INPUTPATH}/ko		$TARGET_PATH"
fi

if [ -d ${INPUTPATH}/public_ko ]; then
	if [ ! -d /home/ko ]; then
		mkdir -p /home/ko
	fi
	excute_shell_order "cp -rf ${INPUTPATH}/public_ko/*	/home/ko"
fi

watch_app_arm
		
if [ -d ${INPUTPATH}/so ]; then
	echo "INFO: cp ${INPUTPATH}/so..."
	if [ ! -d $TARGET_PATH/so ];then
		mkdir $TARGET_PATH/so
	fi
	excute_shell_order "cp -rf `find ${INPUTPATH}/so/* |grep -v libservice_1.1.1.so` ${TARGET_PATH}/so"
	if [ -e ${INPUTPATH}/so/libservice_1.1.1.so ]; then
		echo "INFO: cp ${INPUTPATH}/so/libservice_1.1.1.so..." #libservice_1.1.1.so有5M，需要单独拷贝
		excute_shell_order "cp -rf ${INPUTPATH}/so/libservice_1.1.1.so		${TARGET_PATH}/so"
	fi	
fi
		
if [ -d ${INPUTPATH}/web ]; then
	echo "INFO: cp ${INPUTPATH}/web..."
	excute_shell_order "cp -rf ${INPUTPATH}/web		$TARGET_PATH"
fi
		
if [ -e ${INPUTPATH}/gprsDial ]; then
	excute_shell_order "cp -rf ${INPUTPATH}/gprsDial	$TARGET_PATH"
fi
		
if [ -e ${INPUTPATH}/umconfig.txt ]; then
	excute_shell_order "cp -rf ${INPUTPATH}/umconfig.txt	$TARGET_PATH"
fi


#update so
if [ ! -d /home/so_bin ];then
	mkdir /home/so_bin
fi

watch_app_arm
# dopra库 不管有没有都更新，因为从C01到C02dopra库升级过，如果不更新，程序跑不起来。
# 2015/08/03:dopra内容变更，版本号必须升级。
#if [ -e ${INPUTPATH}/libdopra_2.1.2.so ];then
#	echo "INFO: ${INPUTPATH}/libdopra_2.1.2.so..."
#	cp -rf ${INPUTPATH}/libdopra_2.1.2.so	/home/so_bin
#fi

# goahead库 不管有没有更新，如果包里面有都要更新下，
# 2015/08/03:goahead内容变更，版本号必须升级。用update_so升级so库，不能直接cp。

echo "`date` [APP update] INFO: libdopra_2.2.0.so Start" >> /home/update/update.log
if [ -e ${INPUTPATH}/libdopra_2.2.0.so ];then
	update_so "libdopra_2.2.0.so"
fi
echo "`date` [APP update] INFO: libdopra_2.2.0.so End" >> /home/update/update.log

if [ -e ${INPUTPATH}/libnetsnmp_5.7.1.2.so ];then
	update_so "libnetsnmp_5.7.1.2.so"
fi

if [ -e ${INPUTPATH}/libgoahead_3.4.4.so ];then
	update_so "libgoahead_3.4.4.so"
fi
if [ -e ${INPUTPATH}/libtinyxml_2.6.2.so ];then
	update_so "libtinyxml_2.6.2.so"
fi
watch_app_arm

if [ -e ${INPUTPATH}/libnetsnmpagent_5.7.1.2.so ];then
	update_so "libnetsnmpagent_5.7.1.2.so"
fi

if [ -e ${INPUTPATH}/libnetsnmphelpers_5.7.1.2.so ];then
	update_so "libnetsnmphelpers_5.7.1.2.so"
fi

if [ -e ${INPUTPATH}/libnetsnmpmibs_5.7.1.2.so ];then
	update_so "libnetsnmpmibs_5.7.1.2.so"
fi

watch_app_arm

echo "`date` [APP update] INFO: libssl.so.1.0.1p Start" >> /home/update/update.log
echo "INFO: ${INPUTPATH}/libssl.so.1.0.1p..."
if [ -e ${INPUTPATH}/libssl.so.1.0.1p ]; then		
	update_so1 "libssl.so.1.0.1p"
fi
echo "`date` [APP update] INFO: libssl.so.1.0.1p End" >> /home/update/update.log

echo "`date` [APP update] INFO: libcrypto.so.1.0.1p Start" >> /home/update/update.log
if [ -e ${INPUTPATH}/libcrypto.so.1.0.1p ]; then
	echo "INFO: ${INPUTPATH}/libcrypto.so.1.0.1p..."
	update_so1 "libcrypto.so.1.0.1p"
fi
echo "`date` [APP update] INFO: libcrypto.so.1.0.1p End" >> /home/update/update.log

#add by KF70786 增加支持EMAP SMU05A升级
watch_app_arm

if [ -d ${INPUTPATH}/smu_bin ]; then
	echo "INFO: cp ${INPUTPATH}/smu_bin..."
	excute_shell_order "cp -rf ${INPUTPATH}/smu_bin		$TARGET_PATH"
fi

if [ -d ${INPUTPATH}/dc_cab_bin ]; then
	echo "INFO: cp ${INPUTPATH}/dc_cab_bin..."
	excute_shell_order "cp -rf ${INPUTPATH}/dc_cab_bin		$TARGET_PATH"
fi

if [ -d ${INPUTPATH}/ac_cab_bin ]; then
	echo "INFO: cp ${INPUTPATH}/ac_cab_bin..."
	excute_shell_order "cp -rf ${INPUTPATH}/ac_cab_bin		$TARGET_PATH"
fi
#end by KF70786

#add begin by linjingshan 网络安全修改，将初始化默认明文密码删掉，改用文件的形式
if [ -e ${INPUTPATH}/user_init_cfg.emap ]; then
	echo "INFO: cp ${INPUTPATH}/user_init_cfg.emap..."
	excute_shell_order "cp -rf ${INPUTPATH}/user_init_cfg.emap		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/user_init_salt.emap ]; then
	echo "INFO: cp ${INPUTPATH}/user_init_salt.emap..."
	excute_shell_order "cp -rf ${INPUTPATH}/user_init_salt.emap		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/bin_plugin_auth.emap ]; then
	echo "INFO: cp ${INPUTPATH}/bin_plugin_auth.emap..."
	excute_shell_order "cp -rf ${INPUTPATH}/bin_plugin_auth.emap		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/weak_password.emap ]; then
	echo "INFO: cp ${INPUTPATH}/weak_password.emap..."
	excute_shell_order "cp -rf ${INPUTPATH}/weak_password.emap		$TARGET_PATH"
fi
if [ -e ${INPUTPATH}/privilege_details.emap ]; then
	echo "INFO: cp ${INPUTPATH}/privilege_details.emap..."
	excute_shell_order "cp -rf ${INPUTPATH}/privilege_details.emap		$TARGET_PATH"
fi
#end by linjingshan
#add begin by linjingshan 网络安全修改，将初始化默认明文密码删掉，改用文件的形式
if [ -e ${INPUTPATH}/user_init_cfg.emap ]; then
	echo "INFO: cp ${INPUTPATH}/user_init_cfg.emap..."
	excute_shell_order "cp -rf ${INPUTPATH}/user_init_cfg.emap		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/user_init_salt.emap ]; then
	echo "INFO: cp ${INPUTPATH}/user_init_salt.emap..."
	excute_shell_order "cp -rf ${INPUTPATH}/user_init_salt.emap		$TARGET_PATH"
fi
if [ -e ${INPUTPATH}/weak_password.emap ]; then
	echo "INFO: cp ${INPUTPATH}/weak_password.emap..."
	excute_shell_order "cp -rf ${INPUTPATH}/weak_password.emap		$TARGET_PATH"
fi
if [ -e ${INPUTPATH}/privilege_details.emap ]; then
	echo "INFO: cp ${INPUTPATH}/privilege_details.emap..."
	excute_shell_order "cp -rf ${INPUTPATH}/privilege_details.emap		$TARGET_PATH"
fi
#end by linjingshan

#add begin by linjingshan 网络安全修改，wifi和GPRS初始密码加密存储在文件中
if [ -e ${INPUTPATH}/wifi_init_cfg ]; then
	echo "INFO: cp ${INPUTPATH}/wifi_init_cfg..."
	excute_shell_order "cp -rf ${INPUTPATH}/wifi_init_cfg		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/gprs_init_cfg ]; then
	echo "INFO: cp ${INPUTPATH}/gprs_init_cfg..."
	excute_shell_order "cp -rf ${INPUTPATH}/gprs_init_cfg		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/ip_camera_ftp_server ]; then
	echo "INFO: cp ${INPUTPATH}/ip_camera_ftp_server..."
	excute_shell_order "cp -rf ${INPUTPATH}/ip_camera_ftp_server		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/gprs ]; then
	echo "INFO: cp ${INPUTPATH}/gprs..."
	excute_shell_order "cp -rf ${INPUTPATH}/gprs		$TARGET_PATH"
fi
#end by linjingshan
#add begin by linjingshan 网络安全修改，fsu设备初始密码加密存储在文件中
if [ -e ${INPUTPATH}/fsu_init_cfg ]; then
	echo "INFO: cp ${INPUTPATH}/fsu_init_cfg..."
	excute_shell_order "cp -rf ${INPUTPATH}/fsu_init_cfg		$TARGET_PATH"
fi

if [ -e ${INPUTPATH}/kp/sudoers ];then
	echo "INFO: ${INPUTPATH}/kp/sudoers..." >> /home/update/update.log
	mv -rf ${INPUTPATH}/kp/sudoers	/mnt/kp/etc
fi

if [ -d ${INPUTPATH}/apploadso ]; then
	echo "INFO: cp ${INPUTPATH}/apploadso..."
	#excute_shell_order "cp -rf ${INPUTPATH}/apploadso		$LINK_TARGET_PATH"
fi

if [ -d ${INPUTPATH}/apploadbin ]; then
	echo "INFO: cp ${INPUTPATH}/apploadbin..."
	excute_shell_order "cp -rf ${INPUTPATH}/apploadbin		$TARGET_PATH"
fi


if [ $# -eq 2 ]; then
    	if [ $2 = "updateall" ]; then
		echo "`date` update app to $OTHER_TARGET_PATH..." >> /home/update/update.log
		echo "update app to $OTHER_TARGET_PATH..."
		
		if [ -d $OTHER_TARGET_PATH ];then
			watch_app_arm
			excute_shell_order "rm -rf $OTHER_TARGET_PATH/*"
		fi
		
		watch_app_arm
	
		if [ -e /tmp/bspversioninfo.emap ];then
			cp /tmp/bspversioninfo.emap $OTHER_TARGET_PATH/bspversioninfo.emap
		fi
		
		excute_shell_order "cp  ${INPUTPATH}/app.cfg        	$OTHER_TARGET_PATH"
		excute_shell_order "cp  ${INPUTPATH}/app_arm		$OTHER_TARGET_PATH"
		excute_shell_order "cp  ${INPUTPATH}/init_env		$OTHER_TARGET_PATH"

		if [ -e ${INPUTPATH}/web_server ]; then
			echo "INFO: ${INPUTPATH}/web_server..." 
			excute_shell_order "cp  ${INPUTPATH}/web_server		$LINK_OTHER_TARGET_PATH"
		fi

		if [ -d ${INPUTPATH}/config ]; then
			echo "INFO: cp ${INPUTPATH}/config..."
			excute_shell_order "cp -rf ${INPUTPATH}/config		$OTHER_TARGET_PATH"
		fi

		if [ -d ${INPUTPATH}/webpage ]; then
			echo "INFO: cp ${INPUTPATH}/webpage..."
			excute_shell_order "cp -rf ${INPUTPATH}/webpage 	$OTHER_TARGET_PATH"
		fi

		if [ -e ${INPUTPATH}/auth.txt ]; then
			excute_shell_order "cp  ${INPUTPATH}/auth.txt		$OTHER_TARGET_PATH"
		fi

		if [ -e ${INPUTPATH}/ca.crt ]; then
			excute_shell_order "cp  ${INPUTPATH}/ca.crt		$OTHER_TARGET_PATH"
		fi

		if [ -e ${INPUTPATH}/debug_define.conf ]; then
			excute_shell_order "cp  ${INPUTPATH}/debug_define.conf	$OTHER_TARGET_PATH"
		fi

		if [ -e ${INPUTPATH}/debugging ]; then
			excute_shell_order "cp  ${INPUTPATH}/debugging		$OTHER_TARGET_PATH"
		fi

		if [ -e ${INPUTPATH}/route.txt ]; then
			excute_shell_order "cp  ${INPUTPATH}/route.txt		$OTHER_TARGET_PATH"
		fi

		if [ -e ${INPUTPATH}/snmp_cfg.bin ]; then
			excute_shell_order "cp  ${INPUTPATH}/snmp_cfg.bin	$LINK_OTHER_TARGET_PATH"
		fi

		if [ -e ${INPUTPATH}/tomcat_client.crt ]; then
			excute_shell_order "cp  ${INPUTPATH}/tomcat_client.crt	$OTHER_TARGET_PATH"
		fi

		if [ -e ${INPUTPATH}/tomcat_client.key ]; then
			excute_shell_order "cp  ${INPUTPATH}/tomcat_client.key	$OTHER_TARGET_PATH"
		fi
		
		if [ -e ${INPUTPATH}/equiptest ]; then
			excute_shell_order "cp  ${INPUTPATH}/equiptest		$OTHER_TARGET_PATH"
		fi
		
		if [ -e /mnt/log/update/config.kp ]; then
			excute_shell_order "rm -rf /mnt/log/update/config.kp"
		fi
		
		if [ -d /mnt/log ]; then
			excute_shell_order "rm -rf /mnt/log/*"
		fi
			
		#C00版本的统计日志也放在/home下面，需要删除
		rm -rf /home/statistic
		
		if [ -d /home/sys_cfg ]; then
			excute_shell_order "rm -rf /home/sys_cfg"
		fi		
		
		if [ -d /home/pictures ]; then
			excute_shell_order "rm -rf /home/pictures"
		fi
		rm -rf /mnt/sub_bin/* 
			
					
		if [ -d ${INPUTPATH}/ko ]; then
			excute_shell_order "cp -rf ${INPUTPATH}/ko		$OTHER_TARGET_PATH"
		fi
		
		if [ -d ${INPUTPATH}/public_ko ]; then
			if [ ! -d /home/ko ]; then
				mkdir -p /home/ko
				#升级前一个区是公共目录已放好了ko目录下的文件，这里就不在拷贝了
				excute_shell_order "cp -rf ${INPUTPATH}/public_ko/*	/home/ko"
			fi
		fi
		
		watch_app_arm
		if [ -d ${INPUTPATH}/so ]; then
			echo "INFO: cp ${INPUTPATH}/so..."
			if [ ! -d $OTHER_TARGET_PATH/so ];then
				mkdir $OTHER_TARGET_PATH/so
			fi
			excute_shell_order "cp -rf `find ${INPUTPATH}/so/* |grep -v libservice_1.1.1.so` ${OTHER_TARGET_PATH}/so"
			if [ -e ${INPUTPATH}/so/libservice_1.1.1.so ]; then
				echo "INFO: cp ${INPUTPATH}/so/libservice_1.1.1.so..." #libservice_1.1.1.so有5M，需要单独拷贝
				excute_shell_order "cp -rf ${INPUTPATH}/so/libservice_1.1.1.so		${OTHER_TARGET_PATH}/so"
			fi	
		fi
		
		if [ -d ${INPUTPATH}/web ]; then
			echo "INFO: cp ${INPUTPATH}/web..."
			excute_shell_order "cp -rf ${INPUTPATH}/web		$OTHER_TARGET_PATH"
		fi
		
		if [ -e ${INPUTPATH}/gprsDial ]; then
			excute_shell_order "cp -rf ${INPUTPATH}/gprsDial	$OTHER_TARGET_PATH"
		fi
		
		if [ -e ${INPUTPATH}/umconfig.txt ]; then
			excute_shell_order "cp -rf ${INPUTPATH}/umconfig.txt	$OTHER_TARGET_PATH"
		fi
		
		#add by KF70786 增加支持EMAP SMU05A升级
		watch_app_arm

		if [ -d ${INPUTPATH}/smu_bin ]; then
			echo "INFO: cp ${INPUTPATH}/smu_bin..."
			excute_shell_order "cp -rf ${INPUTPATH}/smu_bin		$OTHER_TARGET_PATH"
		fi

		if [ -d ${INPUTPATH}/dc_cab_bin ]; then
			echo "INFO: cp ${INPUTPATH}/dc_cab_bin..."
			excute_shell_order "cp -rf ${INPUTPATH}/dc_cab_bin	$OTHER_TARGET_PATH"
		fi

		if [ -d ${INPUTPATH}/ac_cab_bin ]; then
			echo "INFO: cp ${INPUTPATH}/ac_cab_bin..."
			excute_shell_order "cp -rf ${INPUTPATH}/ac_cab_bin	$OTHER_TARGET_PATH"
		fi
		
		if [ -e ${INPUTPATH}/HUAWEI-MIB.mib ]; then
			excute_shell_order "cp  ${INPUTPATH}/HUAWEI-MIB.mib	$OTHER_TARGET_PATH"
		fi
		#end by KF70786
		
		#add begin by linjingshan 网络安全修改，将初始化默认明文密码删掉，改用文件的形式
		if [ -e ${INPUTPATH}/user_init_cfg.emap ]; then
			echo "INFO: cp ${INPUTPATH}/user_init_cfg.emap..."
			excute_shell_order "cp -rf ${INPUTPATH}/user_init_cfg.emap		$OTHER_TARGET_PATH"
		fi

		if [ -e ${INPUTPATH}/user_init_salt.emap ]; then
			echo "INFO: cp ${INPUTPATH}/user_init_salt.emap..."
			excute_shell_order "cp -rf ${INPUTPATH}/user_init_salt.emap		$OTHER_TARGET_PATH"
		fi
		
		if [ -e ${INPUTPATH}/bin_plugin_auth.emap ]; then
			echo "INFO: cp ${INPUTPATH}/bin_plugin_auth.emap..."
			excute_shell_order "cp -rf ${INPUTPATH}/bin_plugin_auth.emap		$OTHER_TARGET_PATH"
		fi

        if [ -e ${INPUTPATH}/weak_password.emap ]; then
			echo "INFO: cp ${INPUTPATH}/weak_password.emap..."
			excute_shell_order "cp -rf ${INPUTPATH}/weak_password.emap		$OTHER_TARGET_PATH"
		fi
		if [ -e ${INPUTPATH}/privilege_details.emap ]; then
			echo "INFO: cp ${INPUTPATH}/privilege_details.emap..."
			excute_shell_order "cp -rf ${INPUTPATH}/privilege_details.emap		$OTHER_TARGET_PATH"
		fi
		#end by linjingshan
		#add begin by linjingshan 网络安全修改，wifi和GPRS初始密码加密存储在文件中
		if [ -e ${INPUTPATH}/wifi_init_cfg ]; then
			echo "INFO: cp ${INPUTPATH}/wifi_init_cfg..."
			excute_shell_order "cp -rf ${INPUTPATH}/wifi_init_cfg		$OTHER_TARGET_PATH"
		fi

		if [ -e ${INPUTPATH}/gprs_init_cfg ]; then
			echo "INFO: cp ${INPUTPATH}/gprs_init_cfg..."
			excute_shell_order "cp -rf ${INPUTPATH}/gprs_init_cfg		$OTHER_TARGET_PATH"
		fi
		
		if [ -e ${INPUTPATH}/gprs ]; then
			echo "INFO: cp ${INPUTPATH}/gprs..."
			excute_shell_order "cp -rf ${INPUTPATH}/gprs		$OTHER_TARGET_PATH"
		fi
		
		if [ -e ${INPUTPATH}/ip_camera_ftp_server ]; then
			echo "INFO: cp ${INPUTPATH}/ip_camera_ftp_server..."
			excute_shell_order "cp -rf ${INPUTPATH}/ip_camera_ftp_server		$OTHER_TARGET_PATH"
		fi
		#end by linjingshan
		#add begin by linjingshan 网络安全修改，fsu设备初始密码加密存储在文件中
		if [ -e ${INPUTPATH}/fsu_init_cfg ]; then
			echo "INFO: cp ${INPUTPATH}/fsu_init_cfg..."
			excute_shell_order "cp -rf ${INPUTPATH}/fsu_init_cfg		$OTHER_TARGET_PATH"
		fi
		
		if [ -d ${INPUTPATH}/apploadso ]; then
			echo "INFO: cp ${INPUTPATH}/apploadso..."
			excute_shell_order "cp -rf ${INPUTPATH}/apploadso		$LINK_OTHER_TARGET_PATH"
		fi

		if [ -d ${INPUTPATH}/apploadbin ]; then
			echo "INFO: cp ${INPUTPATH}/apploadbin..."
			excute_shell_order "cp -rf ${INPUTPATH}/apploadbin		$OTHER_TARGET_PATH"
		fi


	else
		echo "para err [Uage] ./update.sh xxxx.tar.gz updateall"
		return 1
    	fi
else
	pidof app_arm > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "`date` [APP update] INFO: not find app_arm,we reboot the system" >> /home/update/update.log	
		reboot;
	fi
  	ChangeAppStartPath	  	
fi 

#add by s00251849 --- move "web_server" "snmp_cfg.bin" to /home/app_binX/, then link 

#一键升级工具另外一面也要做类似的拷贝，软连接操作
link_to_home $TARGET_PATH $LINK_TARGET_PATH
if [ $# -eq 2 ]; then
	if [ $2 == "updateall" ]; then
		link_to_home $OTHER_TARGET_PATH $LINK_OTHER_TARGET_PATH
	fi
fi
#add by s00251849 End


#app can modify the above codes to customize updating scheme

echo "`date` [APP update] INFO: app update success" >> /home/update/update.log
echo "OK"
return 0

