# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :otus123 => {
        :box_name => "centos/7",
        :ip_addr => '192.168.56.150'
  }
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|
  config.vm.synced_folder "./", "/vagrant"
      config.vm.define boxname do |box|

          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s

          box.vm.network "private_network", ip: boxconfig[:ip_addr]

          box.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--memory", "512"]
          end
          
          box.vm.provision "shell", inline: <<-SHELL
            mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
            cp /vagrant/logfiles.sh /home/vagrant/logfiles.sh
            cp /vagrant/access-4560-644067.log /home/vagrant/access-4560-644067.log
            cp /vagrant/mail.sh /home/vagrant/mail.sh
            yum -y install nano
            yum -y install wget
            yum -y install gcc
            yum -y install vim
            yum install cyrus-sasl-plain -y
            yum -y install mailx
            yum install cronie -y
            sudo service crond start
            timedatectl set-timezone Europe/Moscow
          SHELL
      end
  end
end	
