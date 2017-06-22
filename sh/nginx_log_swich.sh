#!/bin/bash
node_id=node`hostname | sed 's/webserver//'`
logs_path="/opt/App/nginx/logs"
app=(`ls $logs_path | grep '\.log' | sed -r 's/\.(access|error)\.log//' | sort | uniq `)
logs_keep_days=90
logs_keep_path=${logs_path}/dailylog

for name in ${app[@]}
do
if [ ! -d ${logs_keep_path}/$name ]
then
    mkdir -p ${logs_keep_path}/$name
fi
if [ $name == "access.log" -o $name == "error.log" ]
then
    mv ${logs_path}/$name ${logs_keep_path}/$name/$name.$node_id.$(date -d "yesterday" +"%Y%m%d").log
    rm -f ${logs_keep_path}/$name/$name.$node_id.$(date -d "${logs_keep_days} days ago" +"%Y%m%d").log
else
    mv ${logs_path}/$name.access.log ${logs_keep_path}/$name/$name.access.$node_id.$(date -d "yesterday" +"%Y%m%d").log
    mv ${logs_path}/$name.error.log ${logs_keep_path}/$name/$name.error.$node_id.$(date -d "yesterday" +"%Y%m%d").log
    if [ -d ${logs_keep_path}/$name ];then
        rm -f ${logs_keep_path}/$name/$name.access.$node_id.$(date -d "${logs_keep_days} days ago" +"%Y%m%d").log
        rm -f ${logs_keep_path}/$name/$name.error.$node_id.$(date -d "${logs_keep_days} days ago" +"%Y%m%d").log
    fi
fi
done
kill -USR1 `cat $logs_path/nginx.pid`
