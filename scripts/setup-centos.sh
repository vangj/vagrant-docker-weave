#!/bin/bash

function disableFirewall {
	echo "disabling firewall"
	systemctl stop firewalld
	systemctl mask firewalld
	systemctl status firewalld
}

function setupHosts {
	echo "modifying /etc/hosts file"
	echo "10.211.55.125 dockerbox" >> /etc/hosts
}

function updateYum {
	yum -y update
}

function installDocker {
	echo "installing up docker"
	curl -sSL https://get.docker.com/ | sh
	systemctl enable docker.service
	systemctl start docker
	sudo usermod -aG docker vagrant
}

function installDockerCompose {
	echo "installing docker-compose"
	sudo curl -L https://github.com/docker/compose/releases/download/1.4.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	sudo chmod a+x /usr/local/bin/docker-compose
}

function installWeave {
	echo "installing weave"
	WEAVE=/usr/local/bin/weave
	sudo curl -L git.io/weave -o $WEAVE
	sudo chmod a+x $WEAVE
	$WEAVE launch && $WEAVE launch-dns && $WEAVE launch-proxy
	eval $($WEAVE proxy-env)
}

echo "setup centos"
disableFirewall
setupHosts
#updateYum
installDocker
installDockerCompose
installWeave