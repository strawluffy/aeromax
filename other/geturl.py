#!/usr/bin/env python
#-*- coding:utf8 -*-
'''
    脚本的作用是用于检测salt最新版本的url并与之前的url对比，如果匹配，就不下载，不匹配就下载
'''

import re
import urllib2
import os
import yaml
import send_email

salt_rpm_root='http://dl.fedoraproject.org/pub/epel/6/x86_64/'
record_last_rpm_file="record.db"
urlpattern=['salt','salt-api','salt-cloud','salt-master','salt-minion']

def flush_record_db(rpm_dict):
	file=open(record_last_rpm_file,'w')
	yaml.dump(rpm_dict,file)
	file.close()


def record_db_info(rpm_dict):
	'''
用于获取配置文件中的值，如果没有值，用获取的值进行刷新

	'''
	if not os.path.isfile(record_last_rpm_file):
		file=open(record_last_rpm_file,'w')
		yaml.dump(rpm_dict,file)
		file.close()
	file=open(record_last_rpm_file,'r')
	myfile=yaml.load(file)
	return myfile

def epel_rpm_info():
	'''
将当前获取到的包信息组合成字典

	'''

	rpm_dict={}
	salt_rpm=[]
	for salt in urlpattern:
		openurl=urllib2.urlopen(salt_rpm_root+'repoview/'+salt+'.html')
		temp_url=openurl.readlines()
		for i in temp_url:
			if re.findall(r'(salt.*rpm)"',i):
				salt_rpm.extend(re.findall(r'(salt.*rpm)"',i))
	for i in range(5):
			rpm_dict[urlpattern[i]]=salt_rpm[i]
	return rpm_dict


def get_should_upgrade_salt():
	'''
返回需要升级的rpm文件
	'''

	upgrade_rpm={}
	rpm_dict=epel_rpm_info()
	myfile=record_db_info(rpm_dict)

	for i in rpm_dict:
		if not rpm_dict[i] == myfile[i]:
			upgrade_rpm[i]=rpm_dict[i]

	flush_record_db(rpm_dict)
	return upgrade_rpm


def get_last_version(salt_rpm):
	
	for salt in salt_rpm:
		print '我们将下载：'+salt_rpm[salt]
		get_rpm=urllib2.urlopen(salt_rpm_root+salt_rpm[salt])
		local_file=open(salt_rpm[salt],'wb')
		local_file.write(get_rpm.read())
		local_file.close()

def main():
	E_MAIL=''
	download_rpm=get_should_upgrade_salt()
	if len(download_rpm) == 0:
		print '没有需要下载的rpm'
	else:
		get_last_version(download_rpm)
		for i in download_rpm:
			E_MAIL+=download_rpm[i]
		msg=send_email.msg_interg("我们将要下载："+E_MAIL)
		send_email.send_email(send_email.from_addr,send_email.to_addrs,msg)

if __name__ == '__main__':
	main()