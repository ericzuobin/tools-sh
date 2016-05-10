# coding: utf-8
import time
import urllib2
import thread
import socket
import random
import hashlib
import sys
reload(sys)
sys.setdefaultencoding('utf8')


def gen_xml(msgid):
	agentid = '10004'
	command = '6101'
	timestamp = str(time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time())))
	lottype = '601'
	playtype = '60101'
	money = '4.00'
	codetype = '2001'
	#code = '4001→(60101)[3,1]/4002→(60105)[3]'
	code = '4001→[3,1]/4002→[3]'
	lastabbdate = '20150416'
	lastmatchid = '4002'
	zhushu = '1'
	multiple = '1'
	ticketcount = '1'
	ticketsn = str(time.strftime('%y%m%d%H%M%S',time.localtime(time.time()))) + str('%04d'%random.randint(0,9999))
        #ticketsn = '12345678'
	messageid = str(msgid)
	password = '1234567890ABCDEF'
	# dataitem = '<dataitem ticketsn="%s" playtype="%s" code="%s" zhushu="%s" money="%s" multiple="%s" expand="">' % (
	# 	ticketsn, playtype, code, zhushu, money, multiple)
	dataitem = '<dataitem ticketsn="%s" playtype="%s" codetype="%s" code="%s" lastabbdate="%s" lastmatchid="%s" zhushu="%s" money="%s" multiple="%s" expand="" />' % (
		ticketsn, playtype, codetype, code, lastabbdate, lastmatchid, zhushu, money, multiple)
	# body = '<body><lottype>%s</lottype><periodical>%s</periodical><money>%s</money><ticketcount>%s</ticketcount><datalist>%s</datalist></body>' % (
	# 	lottype, periodical, money, ticketcount, dataitem)
	body = '<body><lottype>%s</lottype><money>%s</money><ticketcount>%s</ticketcount><datalist>%s</datalist></body>' % (
		lottype, money, ticketcount, dataitem)
	key = command + agentid + messageid + timestamp + password + body
	# key = unicode(key, encoding='utf-8')
    #print key 
	key = hashlib.md5(key).hexdigest()
	head = '<head><command>%s</command><agentid>%s</agentid><messageid>%s</messageid><timestamp>%s</timestamp><key>%s</key></head>' % (
		command, agentid, messageid, timestamp, key)
	msg = 'msg=<?xml version="1.0" encoding="utf-8"?><message>%s%s</message>' % (head, body)
	print 'post:'
	print msg
	return msg


def post_xml(tid, msgid):
	i = 0
	while i < 1:
		data = gen_xml(msgid)
		time_start = int(time.time())
		try:
			request = urllib2.Request("http://172.16.22.184:8080/venus/LotteryOrderTCServlet", data)
			print "reply: \n" + urllib2.urlopen(request).read()
			urllib2.urlopen(request)
		except urllib2.HTTPError, e:
			print e
		except urllib2.OpenerDirector.error, e:
			print e
		except:
			print "timeout"
		time_stop = int(time.time())
		if time_stop - time_start > 10:
			print "thread: %d, post: %d, start_time: %s, stop_time: %s on post" % (tid, i, time_start, time_stop)
		i += 1
	thread.exit_thread()


def main():
	i = 0
	tid = 1
	msgid = 1
	while i < tid:
		thread.start_new_thread(post_xml, (tid, msgid))
		i += 1
		time.sleep(3)


if __name__ == '__main__':
	socket.setdefaulttimeout(20)
	# gen_xml(1)
	main()
