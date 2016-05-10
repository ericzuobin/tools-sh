#!/bin/bash
#根据accesslog，屏蔽频繁访问的IP
nginx_home=/etc/nginx/
log_path=/var/log/nginx/

tail -n50000 $log_path/access.log \
|awk '{print $1,$12}' \
|grep -i -v -E "google|yahoo|baidu|msnbot|FeedSky|sogou" \
|awk '{print $1}'|sort|uniq -c|sort -rn \
|awk '{if($1>1000) print "deny "$2 ";"}' >> $nginx_home/conf/blockip.conf

#去掉重复ip
sort $nginx_home/conf/blockip.conf | uniq -c \
|awk '{print "deny "$3}' > $nginx_home/conf/blockip.conf

/usr/bin/systemctl reload nginx