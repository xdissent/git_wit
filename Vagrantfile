Vagrant::Config.run do |config|
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  config.vm.network :hostonly, "192.168.33.99"
  config.vm.provision :shell, :inline => "sudo -u vagrant -i /bin/bash /vagrant/vagrant.sh"
end
