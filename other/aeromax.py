#!/bin/env python
#
#
import os
from optparse import OptionParser
offset=1
def call_shell(lo_str):
    cmd_run="/root/a.sh "+str(lo_str)
    try:
        os.system(cmd_run)
    except:
        print "para error"
if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option('-r','--replace',dest='replace',default='{}',help='add or replace port ip',metavar='replace')
    parser.add_option('-d','--delete',dest='delete',default='',help='delete port ip',metavar='delete')
    parser.add_option('-m','--ha_port',dest='haport',default='',help='haport',metavar='haport')
    (option,args)=parser.parse_args()
    if option.replace:
        for i in eval(option.replace).keys():
            port_nu=int(i)-offset
            port_ip=eval(option.replace)[i]
            port_string=str(port_nu)+' '+port_ip
	    call_shell(port_string)
    if option.delete:
        for i in option.delete.split(','):
            port_del=int(i)-offset
            call_shell(port_del)   
    if option.haport:
	for i in option.haport.split(','):
	    m_port=int(i)-offset
      	    call_shell(str(m_port)+' '+'zzzz')
