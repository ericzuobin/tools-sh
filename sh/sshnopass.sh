#!/bin/bash
#传入ip，实现ssh无密码登陆
function Echo() {
    parameter=$1
    name=$2
    if [ $1 -ne 1 ]; then
            echo "Usage:  $2  ip.txt"
            echo "        please input ip.txt for freelogin and password next"
            exit 1
    fi      
}

function LocalSsh() {
    remote=$1
    echo "------------------------------------------------------------"
    echo "Begin to set Local-Remote free login!"
    ssh-keygen -t rsa -P ''
    scp /root/.ssh/id_rsa.pub  $1:/root/id_rsa.pub
    ssh $1 'cat /root/id_rsa.pub >> /root/.ssh/authorized_keys'
    ssh  $1 'chmod 600  /root/.ssh/authorized_keys'
    echo "Local-Remote free login set Ok!"
    echo "------------------------------------------------------------"
}

if [ $# -eq 1 ]; then
    num=`awk 'END{print NR}' $1`
    echo 'Set free login ip.txt:'

    for ((i=1;i<=$num;i++)); do
        ip=`cat $1 | sed -n ''$i'p'`
        echo $ip
        LocalSsh $ip
    done
else
    Echo $# $0
fi