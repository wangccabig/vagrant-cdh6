#!/bin/sh

set -x

rm -rf /etc/yum.repos.d/*
cp /share/CentOS-Base.repo /etc/yum.repos.d/


systemctl stop firewalld		# 停止防火墙
systemctl disable firewalld 	# 禁用防火墙

