#!/bin/bash
#自己搭建的测试jenkins发布到自己虚拟机的一个脚本！
#在jenkins中 使用ssh root执行即可
#配置环境
job_home="/var/lib/jenkins/jobs/yygengine/workspace"
targetFile=$job_home/target/ROOT.war
proc_name="dev-engine"
base_home="/conf/yyg-engine"
bak_home=$base_home/ROOT
deploy_file="pengine-1.0-SNAPSHOT.war"
tomcat_base="/opt/deploy"
tomcat_version="apache-tomcat-7.0.68"

#检查是否Compile完成
if [ -f $job_home/target/$deploy_file ];then
  echo "Compile Success,File Exits!"
else
  echo "Compile error! Exit! File Not Exits!"
  exit
fi

#备份之前的打包
myFile=$bak_home/ROOT.war
if [ -f "$myFile" ]; then
 mv $bak_home/ROOT.war $bak_home/ROOT-$(date +%Y%m%d-%H%M%S).war
fi

cp $job_home/target/$deploy_file $bak_home/ROOT.war

if [ -f $bak_home/ROOT.war ]; then
  echo "BackUp Success!!!"
else
  echo "BackUp Failed! Exit!"
  exit
fi

#关闭程序
$tomcat_base/$proc_name/$tomcat_version/bin/shutdown.sh -force

if [ $? -eq 0 ];then
     echo $proc_name" shutdown success ..."
else
     echo $proc_name" shutdown failed ..."
fi

#再次确保程序关闭成功
engine_pids=`ps -ef | grep java | grep apache-tomcat | grep $proc_name | awk '{print $2}'`
if [[ -z $engine_pids ]];then
    echo "The "$proc_name" is not running ! "
else
echo $proc_name " pids:" ${engine_pids[@]}
     echo "------kill the task!------"
     for id in ${engine_pids[*]}
     do
       echo ${id}
       thread=`ps -mp ${id}|wc -l`
       echo "threads number: "${thread}
       kill -9 ${id}
       echo "kill -9" ${id}

       if [ $? -eq 0 ];then
            echo "task is killed ..."
       else
            echo "kill task failed "
       fi
     done
fi

#替换新war
echo "Begin to replace the war! "
rm -rf $tomcat_base/$proc_name/ROOT/*
if [ $? -eq 0 ];then
     echo $tomcat_base/$proc_name/ROOT/ deleted!
else
     echo $tomcat_base/$proc_name/ROOT/ delete failed!
     exit
fi

cp $bak_home/ROOT.war $tomcat_base/$proc_name/ROOT/

if [ $? -eq 0 ];then
     echo Copy ROOT.war to $tomcat_base/$proc_name/ROOT/ success!
else
     echo Copy ROOT.war to $tomcat_base/$proc_name/ROOT/ failed!
     exit
fi

unzip -qq $tomcat_base/$proc_name/ROOT/ROOT.war -d $tomcat_base/$proc_name/ROOT/

if [ $? -eq 0 ];then
     echo Unpack ROOT.war to $tomcat_base/$proc_name/ROOT/ success!
else
     echo Unpack ROOT.war to $tomcat_base/$proc_name/ROOT/ failed!
     exit
fi

rm $tomcat_base/$proc_name/ROOT/ROOT.war

#替换配置文件
echo "Begin to comfigure the "$proc_name
rm -rf $tomcat_base/$proc_name/ROOT/WEB-INF/classes/engine.properties
cp /conf/yyg-engine/engine.properties $tomcat_base/$proc_name/ROOT/WEB-INF/classes/engine.properties
#配置软连接
rm -rf $tomcat_base/$proc_name/ROOT/WEB-INF/classes/deploy/*.xml
ln -s $tomcat_base/$proc_name/ROOT/WEB-INF/classes/deploy-virtual-ticket/deploy-virtual-ticket.xml $tomcat_base/$proc_name/ROOT/WEB-INF/classes/deploy/applicationContext-virtual-ticket.xml
ln -s $tomcat_base/$proc_name/ROOT/WEB-INF/classes/deploy-scanner.xml $tomcat_base/$proc_name/ROOT/WEB-INF/classes/deploy/applicationContext-scanner.xml

if [ $? -eq 0 ];then
     echo Comfigure success!
else
     echo Comfigure failed!
     exit
fi


#启动程序
echo "Begine to start the "$proc_name" !!! "
$tomcat_base/$proc_name/$tomcat_version/bin/startup.sh

#确保启动成功
start_engine_pids=`ps -ef | grep java | grep apache-tomcat | grep $proc_name | awk '{print $2}'`
if [[ -z $start_engine_pids ]];then
    echo "Start failed !!!! Notice!!! "
else
echo $proc_name " started! pids:"
     echo ${start_engine_pids[@]}
fi
echo "Jenkins shell End !!! "
