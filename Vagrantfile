# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Configuration parameters
managerRam = 6144                     # Ram in MB for the Cludera Manager Node
nodeRam = 4096                        # Ram in MB for each DataNode
nodeCount = 3                         # Number of DataNodes to create
privateNetworkIp = "10.10.51.5"       # Starting IP range for the private network between nodes
resizeDisk = 40                       # Size in GB for the secondary virtual HDD
now = Time.now.strftime("%Y-%m-%d %H:%M:%S")  # now

# Do not edit below this line
# --------------------------------------------------------------
privateSubnet = privateNetworkIp.split(".")[0...3].join(".")
privateStartingIp = privateNetworkIp.split(".")[3].to_i

# Create hosts data
  hosts = "#{privateSubnet}.#{privateStartingIp} cdh-master cdh-master\n"
  nodeCount.times do |i|
    id = i+1
    hosts << "#{privateSubnet}.#{privateStartingIp + id} cdh-node#{id} cdh-node#{id}\n"
  end

$hosts_data = <<SCRIPT
#!/bin/bash
cat > /etc/hosts <<EOF
127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

#{hosts}
EOF
SCRIPT


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "centos/7"
  
  config.vm.define "cdh-master" do |master|
    master.vm.network :public_network, :bridge => 'eth0'
    master.vm.network :private_network, ip: "#{privateSubnet}.#{privateStartingIp}", :netmask => "255.255.255.0", virtualbox__intnet: "cdhnetwork"
    master.vm.hostname = "cdh-master"


    master.vm.provider "vmware_fusion" do |v|
	  v.name = "cdh-master"
	  v.memory = "#{managerRam}"
    end
    master.disksize.size = "#{resizeDisk}GB"
    master.vm.synced_folder "./share_folder", "/share"
	
	master.vm.provision "shell", inline: "/bin/sh /vagrant/shell_mount_disk.sh #{resizeDisk - 10}"
	master.vm.provision "shell", inline: $hosts_data
	master.vm.provision "shell", path: "shell_yum_install.sh"
	master.vm.provision "shell", inline: "bin/sh /vagrant/shell_master_install.sh #{now}"
	
  end
  
  nodeCount.times do |i|
    id = i+1
    config.vm.define "cdh-node#{id}" do |node|
      node.vm.network :private_network, ip: "#{privateSubnet}.#{privateStartingIp + id}", :netmask => "255.255.255.0", virtualbox__intnet: "cdhnetwork"
      node.vm.hostname = "cdh-node#{id}"
	  
      node.vm.provider "vmware_fusion" do |v|
      v.vmx["memsize"]  = "#{nodeRam}"
      end
      node.vm.provider :virtualbox do |v|
        v.name = node.vm.hostname.to_s
        v.memory = "#{managerRam}"
      end
	  node.disksize.size = "#{resizeDisk}GB"
	  node.vm.synced_folder "./share_folder", "/share"
	  
	  node.vm.provision "shell", inline: "/bin/sh /vagrant/shell_mount_disk.sh #{resizeDisk - 10}"
	  node.vm.provision "shell", inline: $hosts_data
	  node.vm.provision "shell", path: "shell_yum_install.sh"
	  node.vm.provision "shell", path: "shell_node_install.sh"
    end
	
  end
end
