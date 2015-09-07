vagrant+docker+weave
====================

#Introduction
A Vagrant project to get you started with learning Docker. The Vagrant
virtual machine (VM) is built using [CentOS 7](https://atlas.hashicorp.com/centos/boxes/7).
The following components are installed in the CentOS VM.

1. [Docker v1.8.1](https://www.docker.com/)
2. [docker-compose v1.4.0](https://docs.docker.com/compose/)
3. [Weave v1.0.3](http://weave.works/)

#Getting Started
1. [Download and install VirtualBox](https://www.virtualbox.org/wiki/Downloads). This project is tested using VirtualBox v5.0.2.
2. [Download and install Vagrant](http://www.vagrantup.com/downloads.html). This project is tested using Vagrant  v1.7.4.
3. Git clone this project, and change directory (cd) into this project (directory).
4. Run ```vagrant up``` to create the VM.
5. Run ```vagrant ssh``` to get into the VM.
6. Run ```vagrant suspend``` to save the state of the VM.
7. Run ```vagrant destroy``` when you want to destroy and get rid of the VM.

Note, the password for the _vagrant_ account is _vagrant_ and this account has __sudo__ permission.

#Try this
Try using Weave.

1. open up a console and ssh into this VM ```ssh vagrant@10.211.55.125```
2. create a new container ```docker run --rm --name ex1 -it busybox:latest```
3. open up another console and ssh into this VM ```ssh vagrant@10.211.55.125```
4. create another container ```docker run --rm --name ex2 -it busybox:latest```

Prove to yourself that the container __ex1__ can see the container __ex2__, and vice-versa by doing a ping. For example, in __ex1__, ```ping -c 2 ex2```, and in __ex2__, ```ping -c 2 ex1```.

#Try this too
Try creating an elasticsearch cluster.

```
docker pull elasticsearch:1.5.2
docker run -d --name=es1 -p 9200:9200 -p 9300:9300 elasticsearch:1.5.2 elasticsearch -Des.cluster.name=test
docker exec es1 plugin -i elasticsearch/marvel/latest
docker restart es1
docker run -d --name=es2 elasticsearch:1.5.2 elasticsearch -Des.cluster.name=test
docker run -d --name=es3 elasticsearch:1.5.2 elasticsearch -Des.cluster.name=test
```

1. [Check the cluster health](http://10.211.55.125:9200/_cluster/health?pretty=true)
2. [View stats via Marvel](http://10.211.55.125:9200/_plugin/marvel)

#Finally, try this
Try creating an elasticsearch cluster with mounted points to persist data. Assuming you've ssh'd into the VM, first, create the locations where we will persist data.

```
mkdir /home/vagrant/es1
mkdir /home/vagrant/es2
mkdir /home/vagrant/es3
````

Second, bring up the elasticsearch nodes with the mounted data points.

```
docker run -d -v /home/vagrant/es1:/usr/share/elasticsearch/data --name=es1 -p 9200:9200 -p 9300:9300 elasticsearch:1.5.2 elasticsearch -Des.cluster.name=test
docker exec es1 plugin -i elasticsearch/marvel/latest
docker restart es1
docker run -d -v /home/vagrant/es2:/usr/share/elasticsearch/data --name=es2 elasticsearch:1.5.2 elasticsearch -Des.cluster.name=test
docker run -d -v /home/vagrant/es3:/usr/share/elasticsearch/data --name=es3 elasticsearch:1.5.2 elasticsearch -Des.cluster.name=test
```

Third, add some data.

```
curl -XPUT 'http://localhost:9200/app' -d '
{
 "mappings" : {
  "customer" : {
   "properties" : {
    "fname" : {"type": "string", "index" : "not_analyzed" },
    "lname" : {"type": "string", "index" : "not_analyzed" }
   }
  }
 }
}'


curl -XPUT 'http://localhost:9200/app/customer/1' -d '
{
    "fname" : "john",
	"lname" : "doe"
}'

curl -XPUT 'http://localhost:9200/app/customer/2' -d '
{
    "fname" : "jane",
	"lname" : "smith"
}'

curl 'http://localhost:9200/app/customer/_search?pretty=true' -d '
{
	"query": {
		"match_all": { }
	}
}'
```

Fourth, destroy the docker containers.

```
docker stop es1 es2 es3
docker rm es1 es2 es3
```

Fifth, bring the docker containers back on (exactly as in the second step).

```
docker run -d -v /home/vagrant/es1:/usr/share/elasticsearch/data --name=es1 -p 9200:9200 -p 9300:9300 elasticsearch:1.5.2 elasticsearch -Des.cluster.name=test
docker exec es1 plugin -i elasticsearch/marvel/latest
docker restart es1
docker run -d -v /home/vagrant/es2:/usr/share/elasticsearch/data --name=es2 elasticsearch:1.5.2 elasticsearch -Des.cluster.name=test
docker run -d -v /home/vagrant/es3:/usr/share/elasticsearch/data --name=es3 elasticsearch:1.5.2 elasticsearch -Des.cluster.name=test
```

Sixth, prove to yourself your data wasn't lost.

```
curl 'http://localhost:9200/app/customer/_search?pretty=true' -d '
{
	"query": {
		"match_all": { }
	}
}'
```

#Copyright Stuff
Copyright 2015 Jee Vang

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
