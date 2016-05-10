#!/usr/local/bin/python

from pyDes import *
import time
import base64
import hashlib
import random
import os
import urllib2
import thread
import  socket


def hexStringToByte(s):
    result = ''
    i=0
    while(i<len(s)):
        tmp = s[i:i+2]
        result += tmp.decode('hex')
        i += 2
    return result

def gen_xml(no, i):
    list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
    merchant='10007'
    key='1234567890123456'
    command='100000'
    lottery_type='52'
    play_type='5215'
    phaseno='2015044'
    content='0,1,2,3,4,5'
    multiple='1'
    amount='12'
    requestid=merchant+str(time.strftime('%y%m%d%H%M%S',time.localtime(time.time())))+str('%07d'%random.randint(0, 9999999))
    timestamp=str(time.time()).split('.')[0]
    signature=hashlib.md5(command+timestamp+merchant+key).hexdigest()
    orderid=str(time.strftime('%y%m%d%H%M%S',time.localtime(time.time()))) + str('%04d'%random.randint(0, 9999))

    message=b'<?xml version="1.0" encoding="UTF-8"?><message><merchant>'+merchant+'</merchant><realname>weizhi</realname><idcard>234102193410020318</idcard><mobile>18610105738</mobile><orderlist><order><lotterytype>' + lottery_type + '</lotterytype><phaseno>'+phaseno+'</phaseno><orderid>'+orderid+'</orderid><playtype>' + play_type + '</playtype><content>'+ content +'</content><addition>0</addition><multiple>'+ multiple +'</multiple><amount>'+amount+'</amount></order></orderlist></message>'

#    cmd='java -cp "/opt/script/opsScrpits/nx/venus_tools/classes/:/opt/script/opsScrpits/nx/venus_tools/lib/commons-codec.jar" com/lecai/test/DESCoder \'' + message + '\' ' + key
#    message = os.popen(cmd).readlines()[0].rstrip()

    k=des(hexStringToByte(key), ECB, pad=None, padmode=PAD_PKCS5)
    message_encoded = k.encrypt(message)
    message_encoded = base64.b64encode(message_encoded)

    s='<?xml version="1.0" encoding="UTF-8"?><content><head><version>1</version><merchant>'+merchant+'</merchant><command>'+command+'</command><encrypttype>1</encrypttype><compresstype>0</compresstype><custom></custom><timestamp>'+timestamp+'</timestamp><requestid>'+requestid+'</requestid></head><body>'+message_encoded +'</body><signature>'+signature+'</signature></content>'
    print "post:"
    print s
    print message
    return s

def post_xml(no, n):
    global lock
    i = 0 
    while(i<n):
        data = gen_xml(no, i)
        time_start = int(time.time())
        try:
#            request = urllib2.Request("http://172.16.3.81:9121/LotteryOrderServlet", data)
#            request = urllib2.Request("http://test.venus.lehecai.com:9121/LotteryOrderServlet", data)
            request = urllib2.Request("http://172.16.22.184:8080/venus/LotteryOrderServlet", data)
            print "reply: \n" + urllib2.urlopen(request).read()
            urllib2.urlopen(request)
        except urllib2.HTTPError, e:
            print e
        except urllib2.OpenerDirector.error, e:
            print e
        except: 
            print "timeout"
        time_stop = int(time.time())
        if time_stop-time_start > 10:
            print "thread: %d, post: %d, start_time: %s, stop_time: %s on post" % ( no, i, time_start, time_stop )
        i+=1
    lock -= 1
    thread.exit_thread() 
    
def main():
    global lock
    i = 0
    thread_n = 1
    post_n = 1
    while(i<thread_n):
        thread.start_new_thread(post_xml, (i, post_n))
        lock += 1
        i+=1
    while(lock != 0):
        time.sleep(3)

def test():
    data = gen_xml()
#    request = urllib2.Request("http://172.16.3.81:9121/LotteryOrderServlet", data)
#    request = urllib2.Request("http://test.venus.lehecai.com:9121/LotteryOrderServlet", data)
    request = urllib2.Request("http://172.16.22.184:8080/venus/LotteryOrderServlet", data)
    result = urllib2.urlopen(request) 


if  __name__ == "__main__":
    lock = 0
    socket.setdefaulttimeout(20)
    main()
#   test()
