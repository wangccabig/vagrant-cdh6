#!/bin/sh

set -x

# set ntdp ------------------start------------------
cat > /etc/ntp.conf <<EOF
server cdh-master  #<--该IP是NTP主机端的IP
restrict cdh-master nomodify notrap noquery   # 允许上层时间服务器主动修改本机时间
EOF

ntpdate -u cdh-master
service ntpd restart
systemctl disable chronyd.service
systemctl enable ntpd.service

# set ntdp ------------------end------------------
