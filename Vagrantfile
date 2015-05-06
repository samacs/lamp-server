# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu/trusty64'

  config.ssh.forward_agent = true

  config.vm.network 'private_network', ip: '192.168.50.5'
  config.vm.network 'forwarded_port', guest: 80, host: 8888
  config.vm.network 'forwarded_port', guest: 3306, host: 8889

  config.vm.synced_folder 'htdocs', '/var/www/html', type: 'nfs'

  config.vm.provision :shell, path: 'scripts/setup.sh'

  config.vm.provider :virtualbox do |v|
    v.name = 'DNotes Development Environment'
    v.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    v.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    v.memory = 2048
  end
end
