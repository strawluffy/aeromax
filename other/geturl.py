#!/usr/bin/env python
#-*- coding:utf8 -*-
'''
    脚本的作用是用于检测salt最新版本的url并与之前的url对比，如果匹配，就不下载，不匹配就下载

    20140429 修改  本次将从epel下载rpm,转换为从中国科技大学网站的epel源下载

    http://mirrors.ustc.edu.cn/epel/


	通过在变量rpm_for_download中输入相应的包名称，系统会自动下载红帽5和红帽6版本的32或者64位数的软件包。

	20140505 完成脚本的编写。
'''

import re
import urllib2
import os
import yaml
import send_email
import subprocess
import time
pkg_should_upgrade=[]
rpm_root='http://mirrors.ustc.edu.cn/epel/'
record_last_rpm_file="record.db"
rpm_for_download=['zeromq','salt','salt-api','salt-cloud','salt-master','salt-minion','cobbler','cobbler-web']

rhel_v=['5','6']
arch=['i386','x86_64']

def flush_record_db(rpm_dict):
	file=open(record_last_rpm_file,'w')
	yaml.dump(rpm_dict,file,default_flow_style=False)
	file.close()


def record_db_info(rpm_dict):
	'''
用于获取配置文件中的值，如果没有值，用获取的值进行刷新

	'''
	if not os.path.isfile(record_last_rpm_file):
		file=open(record_last_rpm_file,'w')
		yaml.dump(rpm_dict,file,default_flow_style=False)
		file.close()
	file=open(record_last_rpm_file,'r')
	myfile=yaml.load(file)
	return myfile

def get_rpm_info():
	'''
将当前获取到的包信息组合成字典

	'''

	aproject={}
	local_list=[]
	for x in rhel_v:
		aproject[x]={}
		for y in arch:
			aproject[x][y]={}
			url_pattern=rpm_root+x+'/'+y
			for i in urllib2.urlopen(url_pattern):
				for salt in rpm_for_download:
					# compat=re.compile(salt+'-\d+[\w\-\.]+rpm')
					if re.findall(r'"(%s-\d.*?)"' % salt,i):
						# b=list(set(re.findall(compat,i)))[0]
						# print x+' '+y+' '+str(re.findall(compat,i))
						# print '~~~~~~'
						aproject[x][y][salt]=re.findall(r'"(%s.*?)"' % salt,i)[0]
	return aproject
	print 'aprojectis %s' % aproject


def get_should_upgrade_rpm():
	'''
返回需要升级的rpm文件
	'''

	upgrade_rpm={}
	rpm_dict=get_rpm_info()
	myfile=record_db_info(rpm_dict)

	for x in rhel_v:
		upgrade_rpm[x]={}
		for y in arch:
			upgrade_rpm[x][y]={}
			for salt in rpm_for_download:
				if not rpm_dict[x][y][salt] == myfile[x][y][salt]:
					upgrade_rpm[x][y][salt]=rpm_dict[x][y][salt]
	flush_record_db(rpm_dict)
	return upgrade_rpm

def get_download(url_pattern,rpm):
	'''
下载rpm文件
	'''
	print '我们将下载：'+url_pattern+'/'+rpm
	get_rpm=urllib2.urlopen(url_pattern+'/'+rpm)
	local_file=open(rpm,'wb')
	local_file.write(get_rpm.read())
	local_file.close()

def get_last_version(salt_rpm):
	'''
拼接需要下载的url
	'''
	for salt in salt_rpm:
		if re.findall('el5\.noarch', salt):
			url_pattern=rpm_root+'5/x86_64'
			get_download(url_pattern,salt)
		elif re.findall('el5\.i386', salt):
			url_pattern=rpm_root+'5/i386'
			get_download(url_pattern,salt)
		elif re.findall('el5\.x86_64', salt):
			url_pattern=rpm_root+'5/x86_64'
			get_download(url_pattern,salt)
		elif re.findall('el6\.noarch', salt):
			url_pattern=rpm_root+'6/x86_64'
			get_download(url_pattern,salt)
		elif re.findall('el6\.i686', salt):
			url_pattern=rpm_root+'6/i386'
			get_download(url_pattern,salt)
		elif re.findall('el6\.x86_64', salt):
			url_pattern=rpm_root+'6/x86_64'
			get_download(url_pattern,salt)


def group_in_list(ldic):
	'''
将需要下载rpm字典拼接为字典
	'''
	for x,y in ldic.iteritems():
		if type(y) is dict:
			group_in_list(y)
		elif  y:
			pkg_should_upgrade.append(y)


def main():
	E_MAIL=''
	download_rpm_dict=get_should_upgrade_rpm()
	group_in_list(download_rpm_dict)
	download_rpm=list(set(pkg_should_upgrade))

	if len(download_rpm) == 0:
		file=open('/home/cuizz/aeromax/other/nodownload.log','a')
		print >> file,time.asctime()+' : 没有需要下载的rpm'
		file.close()
	else:
		get_last_version(download_rpm)
		E_MAIL=''
		for i in download_rpm:
					E_MAIL=i+"\n"+E_MAIL
		print E_MAIL
		msg=send_email.msg_interg("我们将要下载："+E_MAIL)
		send_email.send_email(send_email.from_addr,send_email.to_addrs,msg)
		subprocess.Popen('/bin/sh /var/www/cobbler/ks_mirror/rpm_temp/deploy.sh',shell=True) 


if __name__ == '__main__':
	main()
