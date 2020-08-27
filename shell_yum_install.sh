#!/bin/sh

set -x

rm -rf /etc/yum.repos.d/*
cp /share/CentOS-Base.repo /etc/yum.repos.d/


systemctl stop firewalld		# 停止防火墙
systemctl disable firewalld 	# 禁用防火墙

yum install -y ntp ntpdate


# set java home --------------start---------------
yum localinstall -y /share/cloudera-repos/oracle-j2sdk1.8-1.8.0+update141-1.x86_64.rpm
cat >> /etc/profile <<EOF

# JAVA_HOME
export JAVA_HOME=/usr/java/jdk1.8.0_141-cloudera
export PATH=$JAVA_HOME/bin:$PATH 
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar 
EOF

source /etc/profile
# set java home --------------end---------------