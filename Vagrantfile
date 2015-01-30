# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network "forwarded_port", host: 80, guest: 80, auto_correct: true
  config.vm.network "private_network", ip: "10.1.2.3"
    config.ssh.forward_agent = true
  config.vm.network "public_network", ip: "192.168.0.242", bridge: "en6: USB Ethernet"
  config.vm.synced_folder "~/Projects", "/var/www", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp,actimeo=2']

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "4096", "--ioapic", "on"]
    v.customize ["modifyvm", :id, "--cpus", "4"]
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
  end

  config.vm.provision :shell, :path => "provision.sh"

  config.trigger.after [:provision, :up, :reload] do
      system('echo "
              rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 80 -> 127.0.0.1 port 8080  
              rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 443 -> 127.0.0.1 port 8443  
              " | sudo pfctl -f - > /dev/null 2>&1; echo "==> Fowarding Ports: 80 -> 8080, 443 -> 8443"')  
  end

  config.trigger.after [:halt, :destroy] do
    system("sudo pfctl -f /etc/pf.conf > /dev/null 2>&1; echo '==> Removing Port Forwarding'")
  end

end
