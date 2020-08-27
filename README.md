# vagrant-cdh6

## 版本
- VitrualBox 6.1.12r139181
- Vagrant 2.2.9

## 一、安装vagrant插件
```shell
vagrant plugin install vagrant-disksize
```

## 二、启动虚拟机
```shell
vagrant up
```

## 三、进入cdh-master节点查看日志
```shell
vagrant ssh cdh-master
sudo tail -f /var/log/cloudera-scm-server/cloudera-scm-server.log
```
等待查看到```Started Jetty server.```日志打印出来后，说明服务启动成功，可以通过浏览器访问Cloudera Manager WEB界面了。此时间较长。

## 四、宿主机执行命令
```shell
ssh -CfNg -L 7180:192.168.12.57:7180 vagrant@192.168.12.57
>>输入密码vagrant
```

## 五、访问安装页面

浏览器输入```http://宿主机ip:7180```访问