# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_RAM = ENV['VAGRANT_RAM'] || 1024
VAGRANT_CORES = ENV['VAGRANT_CORES'] || 1

$script=<<SCRIPT
apt-get update && \
apt-get -y install docker.io && \
ln -sf /usr/bin/docker.io /usr/local/bin/docker && \
sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
SCRIPT

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.define :docker_vm do |t|
  end

  config.vm.provision "shell", inline: $script

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--memory", VAGRANT_RAM]
    vb.customize ["modifyvm", :id, "--cpus", VAGRANT_CORES]
  end

  config.vm.synced_folder "/Users/dario/git/mail-docker-container", "/mail/"
  config.vm.synced_folder "/Users/dario/git/mysql-docker-container", "/mysql"
end
