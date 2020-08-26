#!/bin/sh

set -x

# set ntdp ------------------start------------------
cat > /etc/ntp.conf <<EOF
server cdh-master  #<--该IP是NTP主机端的IP
restrict cdh-master nomodify notrap noquery   # 允许上层时间服务器主动修改本机时间
EOF

ntpdate -u cdh-master				    # 强制同步时间
service ntpd restart					# 重启时钟同步服务
systemctl disable chronyd.service		# 禁用chronyd服务
systemctl enable ntpd.service			# 开机启动
ntpstat									# 查看同步状态

# set ntdp ------------------end------------------

# set yum repo ---------------start---------------



# set yum repo --------------- end ---------------