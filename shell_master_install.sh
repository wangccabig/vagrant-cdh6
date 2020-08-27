#!/bin/sh

set -x

# set ntdp ------------------start------------------

timedatectl set-ntp no
timedatectl set-timezone Asia/Shanghai
date

cat > /etc/ntp.conf <<EOF
restrict 0.0.0.0 mask 0.0.0.0 nomodify notrap     # 允许内网其他机器同步时间
server 127.127.1.0     #外部时间服务器不可用时，以本地时间作为时间服务
fudge  127.127.1.0 stratum 10
EOF

service ntpd restart
systemctl disable chronyd.service
# start on boot
systemctl enable ntpd.service
ntpstat
systemctl status ntpd.service
# set ntdp ------------------end------------------

# set yum repo ---------------start---------------
yum -y install httpd createrepo

systemctl start httpd
systemctl enable httpd

mkdir -p /var/www/html/cloudera-repos
cp /share/cloudera-repos/* /var/www/html/cloudera-repos/

cd /var/www/html/cloudera-repos
createrepo .


cat > /etc/yum.repos.d/cloudera-manager.repo <<EOF
[cloudera-manager]
name=Cloudera Manager 6.0.1
baseurl=http://cdh-master/cloudera-repos/
gpgcheck=0
enabled=1

EOF
# set yum repo ---------------end---------------

# install mysql server---------start------------

yum remove -y mariadb*
#cd 
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
yum localinstall -y mysql-community-release-el7-5.noarch.rpm
sed -i "s/http/https/g" /etc/yum.repos.d/mysql-community.repo
yum install -y mysql-server
#rpm -Uvh /share/mysql/*.rpm --nodeps --force

cat > /etc/my.cnf <<EOF
[mysqld]

log-error=/var/log/mysqld.log
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
transaction-isolation = READ-COMMITTED
# Disabling symbolic-links is recommended to prevent assorted security risks;
# to do so, uncomment this line:
symbolic-links = 0

key_buffer_size = 32M
max_allowed_packet = 32M
thread_stack = 256K
thread_cache_size = 64
query_cache_limit = 8M
query_cache_size = 64M
query_cache_type = 1

max_connections = 550
#expire_logs_days = 10
#max_binlog_size = 100M

#log_bin should be on a disk with enough free space.
#Replace '/var/lib/mysql/mysql_binary_log' with an appropriate path for your
#system and chown the specified folder to the mysql user.
log_bin=/var/lib/mysql/mysql_binary_log

#In later versions of MySQL, if you enable the binary log and do not set
#a server_id, MySQL will not start. The server_id must be unique within
#the replicating group.
server_id=1

binlog_format = mixed

read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 4G
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_log_file_size = 512M

[mysqld_safe]

pid-file=/var/run/mysqld/mysqld.pid

sql_mode=STRICT_ALL_TABLES

EOF

# create db
systemctl start mysqld
mysql -uroot < /share/init_db.sql


# install mysql server--------- end ------------

# config cdh agent   --------- start ------------
sudo yum install -y cloudera-manager-daemons cloudera-manager-agent cloudera-manager-server

mkdir -p /usr/share/java/
cp /share/mysql-connector-java-5.1.47-bin.jar /usr/share/java/mysql-connector-java.jar

/opt/cloudera/cm/schema/scm_prepare_database.sh mysql scm scm 'MyNewPass4!.'
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql amon amon 'MyNewPass4!.'
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql rman rman 'MyNewPass4!.'
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql hue hue 'MyNewPass4!.'
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql metastore metastore 'MyNewPass4!.'
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql sentry sentry 'MyNewPass4!.'
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql nav nav 'MyNewPass4!.'
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql navms navms 'MyNewPass4!.'
/opt/cloudera/cm/schema/scm_prepare_database.sh mysql oozie oozie 'MyNewPass4!.'

# config cdh agent   --------- end ------------

systemctl start cloudera-scm-server
