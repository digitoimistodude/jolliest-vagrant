# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: "10.1.2.3"
  #config.vm.network "public_network", ip: "10.1.2.4", bridge: "en0: Wi-Fi (AirPort)"
  config.vm.synced_folder "~/Projects", "/var/www", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp,actimeo=2']

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "4096", "--ioapic", "on"]
    v.customize ["modifyvm", :id, "--cpus", "4"]
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  config.vm.provision :shell, :path => "provision.sh"

end