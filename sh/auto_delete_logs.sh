#!/bin/bash

#扫描的base路径
p_prefix='/opt/deploy/'
#日志后缀路径
p_suffix='/logdir/suffix/'
#查找需要自动删除的项目根地址
log_sites=(`ls $p_prefix | grep 'app_base'`)
log_time=`date +%F`
#log过期时间
expireday=30

for p in ${log_sites[@]}
do
    echo $p
    #具体的路径
    dir=$p_prefix$p$p_suffix
    if [ -d $dir ];then
        echo "`hostname`: $dir found"
        find $dir -name "*.log" -mtime +$expireday | xargs rm -f
    fi
done
