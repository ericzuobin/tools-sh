#!/usr/bin/python

import MySQLdb
import datetime
import sys

def update_status(status):
    fh = open('/tmp/tencent_order.status','w')
    fh.write(str(status))
    fh.close()

conn = MySQLdb.connect(host='172.16.3.52', passwd='123456', port=1231, user='root', db='v_ticket')
cursor = conn.cursor(MySQLdb.cursors.DictCursor)
cursor.execute('select * from lottery_order  where merchant_code = 10014 order by id desc limit 1')
res = cursor.fetchone()

receive_time = res['receive_time']

today = datetime.date.today()
year = str(today).split('-')[0]
month = str(today).split('-')[1]
day = str(today).split('-')[2]

begin_datetime = datetime.datetime.strptime(year+'-'+month+'-'+day+' 19:30:00', "%Y-%m-%d %H:%M:%S")
end_datetime = datetime.datetime.strptime(year+'-'+month+'-'+day+' 22:00:00', "%Y-%m-%d %H:%M:%S")

print receive_time
print datetime.datetime.now()
print begin_datetime
print end_datetime

for weekday in (2, 4, 7):
    if  datetime.date.isoweekday(today) == weekday and datetime.datetime.now() > begin_datetime and datetime.datetime.now() < end_datetime:
        print 'not running time range'
        sys.exit(1)


if datetime.datetime.now() - receive_time > datetime.timedelta(minutes=10):
    update_status(1)
else:
    update_status(0)
