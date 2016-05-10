#!/bin/bash

SH_HOME="/home/sahinn/github/access-log"
ACCESS_LOG='/var/log/nginx'
KEY='111111'

cd $SH_HOME

year=`date +"%Y"`
myPath=$year

if [ ! -d $myPath ];
 then 
   mkdir $myPath   
fi
cd $myPath 

month=`date +"%m"`
monthPath=$month

if [ ! -d $monthPath ];
 then
   mkdir $monthPath
fi
cd $monthPath

day=`date +"%d"`

if [ -f access.log ];
 then
   rm -rf access.log
fi

cp $ACCESS_LOG/access.log .

if [ -f access.log ];
 then
   if [ ! -f access-$year-$month-$day.log ]
	then
	  mv access.log access-$year-$month-$day.log
        else 
	  rm -rf access.log
	  echo 'access-$year-$month-$day.log exits,do nothing!'
	  exit
   fi
fi

if [ -f access-$year-$month-$day.log ]
 then 
  zip -P $KEY access-$year-$month-$day.log.zip access-$year-$month-$day.log
  rm -rf access-$year-$month-$day.log
 else 
  echo 'exit'
  exit 
fi

git add access-$year-$month-$day.log.zip
git commit -m "access-$year-$month-$day.log"
git push -u origin master

rm access-$year-$month-$day.log.zip
