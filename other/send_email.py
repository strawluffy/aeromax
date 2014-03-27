#!/usr/bin/env python
#coding: utf-8

import smtplib

from email.MIMEText import MIMEText
from email.MIMEImage import MIMEImage
from email.MIMEMultipart import MIMEMultipart

user='redmine'
password='1234'
from_addr='redmine@ait.cn'
to_addrs='cuizhongzheng@ait.cn'
msg_1='''
<!DOCTYPE html>
<html>
  <head>
    <title>Bootstrap 101 Template</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link rel="stylesheet" href="http://cdn.bootcss.com/twitter-bootstrap/3.0.3/css/bootstrap.min.css">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="http://cdn.bootcss.com/html5shiv/3.7.0/html5shiv.min.js"></script>
        <script src="http://cdn.bootcss.com/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>

'''
msg_2='''
	<div class="col-md-8">
	<h3>大家好：</h3>
		  <div class="col-md-6 col-md-offset-1">


    </br>
    <div class="alert alert-success">测试服务器已经完成，配置如下：</div>
    <table class="table table-bordered" border="1">
	  <tr>
	    <th>配置项</th>
	    <th>详细信息</th>
	  </tr>
	  <tr>
	    <td>服务器IP</td>
	    <td>172.18.26.18</td>
	  </tr>
	  <tr>
	    <td>用户名</td>
	    <td>root</td>
	  </tr>
	  	  <tr>
	    <td>密码</td>
	    <td>rootroot</td>
	  </tr>
	  	  </tr>
	  	  <tr>
	    <td>宿主服务器IP地址</td>
	    <td>rootroot</td>
	  </tr>
	</table>

		  </div>
	</div>
	</br>
	</br>
	</br>
'''
msg_3='''
	</br>
	<img src="cid:image2">
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="http://cdn.bootcss.com/jquery/1.10.2/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="http://cdn.bootcss.com/twitter-bootstrap/3.0.3/js/bootstrap.min.js"></script>
  </body>
</html>

'''
def msg_root(msg1=msg_1,msg2=msg_2,msg3=msg_3):
	return msg1+msg2+msg3
	
def msg_interg(msg):
	MULT_root=MIMEMultipart('related')
	MULT_root['from']=from_addr
	MULT_root['to']=to_addrs
	MULT_root['Subject']='Subject'

	SEC_root=MIMEMultipart('alternative')
	MULT_root.attach(SEC_root)

	send_msg=MIMEText(msg_root(msg2=msg),'html')
	SEC_root.attach(send_msg)

	file_2=open('2.png','rb')
	send_img2=MIMEImage(file_2.read())
	send_img2.add_header('Content-ID','<image2>')
	MULT_root.attach(send_img2)
	return MULT_root

def send_email(from_addr,to_addrs,msg):
	l_send=smtplib.SMTP('mail.ait.cn')
	l_send.login(user, password)
	l_send.sendmail(from_addr, to_addrs, msg.as_string())
	l_send.quit()

def main():
	msg=msg_interg('a')
	send_email(from_addr,to_addrs,msg)



if __name__ == '__main__':
	main()