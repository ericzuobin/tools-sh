#!/bin/bash
#删除指定的tomcat程序！
proc_name="dev-engine"
engine_pids=`ps -ef | grep java | grep apache-tomcat | grep $proc_name | awk '{print $2}'`
if [[ -z $engine_pids ]];then
    echo "The engine is not running ! "
else
echo $proc_name " pids:"
     echo ${engine_pids[@]}
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