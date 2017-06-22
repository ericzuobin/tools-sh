#!/bin/bash
ip=`ifconfig em2 | grep "inet addr" | awk -F':' '{print $2}' | awk  '{print $1}'`
listen=`netstat -nutlp | grep $ip | wc -l`
if [ $listen -eq 1 ];then
    echo "NTP listen is ok!"
else
        /etc/init.d/ntpd restart

        if [ $? -eq 0 ];then
               echo "restart ok!"
        else

            echo "error: 21 ntpd  listen is error" | mail  -s  "21 ntpd is listen  error"    zuobin@lecai.com
fi

fi
######################################################

process=`ps -ef | grep ntpd.pid |grep -v grep |wc -l`

if [ $process -eq 1 ];then
    echo "ntp process is ok!"
else
    /etc/init.d/ntpd restart

         if [ $? -eq 0 ];then

                   echo "restart ok!"

        else

             echo "error: 21 ntpd  process is error" | mail  -s  "21 ntpd is process  error"     zuobin@lecai.com
