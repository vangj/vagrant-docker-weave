Vagrant.configure(2) do |config|
	config.vm.define "dockerbox" do |node|
		node.vm.box = "centos/7"
		node.vm.provider "virtualbox" do |v|
		  v.name = "dockerbox"
		  v.customize ["modifyvm", :id, "--memory", "8192"]
		end
		node.vm.network :private_network, ip: "10.211.55.125"
		node.vm.network :forwarded_port, guest: 22, host: 1235
		node.vm.hostname = "dockerbox"
		node.vm.provision "shell", path: "scripts/setup-centos.sh"
	end
end
