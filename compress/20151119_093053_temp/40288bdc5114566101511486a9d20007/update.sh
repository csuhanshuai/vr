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

#��Ʒ�ɸ���ʵ��keeper�����ļ��洢λ���޸�ChangeAppStartPath()
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

#����app_arm���̣����������ɱ��ռ��/dev/watchdog�Ľ���������ι��
#��Ʒ����ʵ������ʱ���ں��ʵĵط����øú���
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
#����APP���̲�����keeper������ռ/dev/watchdog�豸����,�Լ��ӹ�ι��
exit_app_process()
{
	pidof app_arm > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		for kill_cnt in `seq 1 1000`
		do
			#Ϊ���ͷ�app����ռ�õ�flash�ռ䣬��app����ɱ����������watch app_arm
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
	
	#����APP�󣬽���keeper������ռ/dev/watchdog�豸����,�Լ��ӹ�ι��
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

#update_soֻ֧������"libname_�汾��*"��so��
update_so()
{
	lib_name=${1%_*}
	lib_num=`find /home/so_bin/ -name ""$lib_name"_*" |wc -l`

	if [ $lib_num -eq "0" ]; then
		#so�ļ������ڣ�ֱ�Ӹ���
		excute_shell_order "cp  ${INPUTPATH}/$1		/home/so_bin" 
	elif [ $lib_num -eq "1" ]; then
		if ! [ -e /home/so_bin/$1 ]; then
			#��ǰ�Ѵ��ڵ�so���ļ���Ҫ���µ�so���ļ���һ�£�����
			excute_shell_order "cp  ${INPUTPATH}/$1		/home/so_bin" 
		else
			diff ${INPUTPATH}/$1 /home/so_bin/$1 > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				#ͬ��so�ļ������ݲ�һ��
				excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
			fi
		fi
	else
		#ɾ�����ϰ汾��so��
		if ! [ -e /home/so_bin/$1 ]; then #�¿ⲻ���ڣ�ֱ��ɾ���ɰ汾�ļ�
			old_lib=`find /home/so_bin/ -name ""$lib_name"_*" |sort |awk 'NR==1'`
			excute_shell_order "rm -rf $old_lib"
			#����
			excute_shell_order "cp  ${INPUTPATH}/$1		/home/so_bin" 
		else
			diff ${INPUTPATH}/$1 /home/so_bin/$1 > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo "`date` [BSP update]  copy" >> /home/update/update.log
				#ͬ��so�ļ������ݲ�һ��
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
		#so�ļ������ڣ�ֱ�Ӹ���
		excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
	elif [ $lib_num -eq "1" ]; then
		if ! [ -e /home/so_bin/$1 ]; then
			#��ǰ�Ѵ��ڵ�so���ļ���Ҫ���µ�so���ļ���һ�£�����
			excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
		else
			diff ${INPUTPATH}/$1 /home/so_bin/$1 > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				#ͬ��so�ļ������ݲ�һ��
				excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
			fi
		fi
	else
		#ɾ�����ϰ汾��so��
		if ! [ -e /home/so_bin/$1 ]; then
			old_lib=`find /home/so_bin/ -name ""$lib_name".so.*" |sort |awk 'NR==1'`
			excute_shell_order "rm -rf $old_lib"
			#����
			excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
		else
			diff ${INPUTPATH}/$1 /home/so_bin/$1 > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo "`date` [BSP update]  copy" >> /home/update/update.log
				#ͬ��so�ļ������ݲ�һ��
				excute_shell_order "cp  ${INPUTPATH}/$1  /home/so_bin" 
			fi
		fi
	fi
}

#������Ŀ¼�Ƴ�so��ȱȽϴ���ļ���home�£��������ӹ�ȥ
# $1 ��ǰ����Ŀ¼,����/mnt/app_bin0/bin_arm
# $2 ����Ŀ��Ŀ¼,����/home/app_bin0
link_to_home()
{
	echo "INFO: link_to_home $1 $2" 
	
	#���������ӣ���Ҫ1������mnt��home��2��ɾ��mnt��3������������
	#����������������
	if [ -L $1/web_server ]; then
		echo "INFO:  soft link $1/web_server..." 
	else
		if [ -e $1/web_server ]; then #mnt�´���
			if [ ! -e $2/web_server ]; then #home�²�����
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
		if [ -e $1/snmp_cfg.bin ]; then #mnt�´���
			if [ ! -e $2/snmp_cfg.bin ]; then #home�²�����
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
		if [ -d $1/apploadso ]; then #mnt�´���
			if [ ! -d $2/apploadso ]; then #home�²�����
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

# ���û�в���������
if [ $# -lt 1 ]; then	
	echo "[Uage] ./update.sh xxxx.tar.gz updateall"
	echo $#
	return 0
fi

# �����������������֤����2 �Ƿ�Ϊ ��updateall��
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
	#Ĭ�ϵ�ǰ���е���app1�������Ϳ���Ĭ������app0
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

#һ����������һ�����ͽ���APP���̼�keeper
if [ $# -eq 2 ]; then
	if [ $2 == "updateall" ]; then
		exit_app_process
		if [ $? -ne 0 ]; then
			#echo "ERR: exit app process error"
			return 1
		fi
		
		#ɾ��ռ��/mnt/app_bin0��/mnt/app1�Ľ���
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

#һ����������һ�����ͽ���APP���̼�keeper
if [ $# -eq 2 ]; then
	if [ $2 == "updateall" ]; then
		exit_app_process
		if [ $? -ne 0 ]; then
			#echo "ERR: exit app process error"
			return 1
		fi
		
		#ɾ��ռ��/mnt/app_bin0��/mnt/app1�Ľ���
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

#һ������������
if [ $# -ne 2 ]; then
	## =============================================================================
	## �ų�ɾ����2���ļ��к�һ��bspversioninfo.emap�ļ�
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

	#����temp·����web_server.sh��web_server.emap��Ŀ��Ŀ¼��
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
				#webserver��snmp.bin�����ļ�ҲҪ�ų�����������
				filter_dir=`ls |grep -v "$keep_dir0\|$keep_dir1\|$keep_file0\|$keep_webserver\|$keep_snmpcfg"`
				#echo "cp filter:$filter_dir"
				excute_shell_order "cp -rf $filter_dir $TARGET_PATH"
				watch_app_arm
				if [ -e /tmp/bspversioninfo.emap ];then
					excute_shell_order "cp -rf /tmp/bspversioninfo.emap $TARGET_PATH$keep_file0"
					echo "`date` [APPLoad update] INFO: cp $TARGET_PATH$keep_file0" >> /home/update/update.log
				fi
				#web_server snmp_cfg.bin�����ļ��Ӳ���������home���濽��������ǰĿ¼����
				#������������Ӿ�ֱ�ӿ����������home�¿���
				if [ -L $keep_webserver ];then #�������ӣ���home�¿���
					excute_shell_order "cp -rf $LINK_OTHER_TARGET_PATH/web_server $LINK_TARGET_PATH$keep_webserver"
					echo "`date` [APPLoad update] INFO: cp home $LINK_TARGET_PATH$keep_webserver" >> /home/update/update.log
				else #���������ӣ�ֱ�ӿ���
					excute_shell_order "cp -rf $keep_webserver $LINK_TARGET_PATH"
					echo "`date` [APPLoad update] INFO: cp current $LINK_TARGET_PATH$keep_webserver" >> /home/update/update.log
				fi
				if [ -L $keep_snmpcfg ];then #�������ӣ���home�¿���
					excute_shell_order "cp -rf $LINK_OTHER_TARGET_PATH/snmp_cfg.bin $LINK_TARGET_PATH$keep_snmpcfg"
					echo "`date` [APPLoad update] INFO: cp home $LINK_TARGET_PATH$keep_snmpcfg" >> /home/update/update.log
				else #���������ӣ�ֱ�ӿ���
					excute_shell_order "cp -rf $keep_snmpcfg $LINK_TARGET_PATH"
					echo "`date` [APPLoad update] INFO: cp current $LINK_TARGET_PATH$keep_snmpcfg" >> /home/update/update.log
				fi
				link_to_home $TARGET_PATH $LINK_TARGET_PATH
				cd -
				ChangeAppStartPath
				# ͬ���ļ���flash ִ��2��
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
	## �����ű����ݴӲ�֧��APP���ذ汾��֧��APP���ذ汾
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
		# emap_version.txt�ļ��Ǵ�V100R003��ʼ�ģ��ҵ���Ϊ��֧��
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
		echo "INFO: cp ${INPUTPATH}/so/libservice_1.1.1.so..." #libservice_1.1.1.so��5M����Ҫ��������
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
# dopra�� ������û�ж����£���Ϊ��C01��C02dopra������������������£������ܲ�������
# 2015/08/03:dopra���ݱ�����汾�ű���������
#if [ -e ${INPUTPATH}/libdopra_2.1.2.so ];then
#	echo "INFO: ${INPUTPATH}/libdopra_2.1.2.so..."
#	cp -rf ${INPUTPATH}/libdopra_2.1.2.so	/home/so_bin
#fi

# goahead�� ������û�и��£�����������ж�Ҫ�����£�
# 2015/08/03:goahead���ݱ�����汾�ű�����������update_so����so�⣬����ֱ��cp��

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

#add by KF70786 ����֧��EMAP SMU05A����
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

#add begin by linjingshan ���簲ȫ�޸ģ�����ʼ��Ĭ����������ɾ���������ļ�����ʽ
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
#add begin by linjingshan ���簲ȫ�޸ģ�����ʼ��Ĭ����������ɾ���������ļ�����ʽ
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

#add begin by linjingshan ���簲ȫ�޸ģ�wifi��GPRS��ʼ������ܴ洢���ļ���
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
#add begin by linjingshan ���簲ȫ�޸ģ�fsu�豸��ʼ������ܴ洢���ļ���
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
			
		#C00�汾��ͳ����־Ҳ����/home���棬��Ҫɾ��
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
				#����ǰһ�����ǹ���Ŀ¼�ѷź���koĿ¼�µ��ļ�������Ͳ��ڿ�����
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
				echo "INFO: cp ${INPUTPATH}/so/libservice_1.1.1.so..." #libservice_1.1.1.so��5M����Ҫ��������
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
		
		#add by KF70786 ����֧��EMAP SMU05A����
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
		
		#add begin by linjingshan ���簲ȫ�޸ģ�����ʼ��Ĭ����������ɾ���������ļ�����ʽ
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
		#add begin by linjingshan ���簲ȫ�޸ģ�wifi��GPRS��ʼ������ܴ洢���ļ���
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
		#add begin by linjingshan ���簲ȫ�޸ģ�fsu�豸��ʼ������ܴ洢���ļ���
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

#һ��������������һ��ҲҪ�����ƵĿ����������Ӳ���
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

