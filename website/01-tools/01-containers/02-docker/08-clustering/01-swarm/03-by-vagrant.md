---
layout: page
title: Docker Swarm - кластер с использованием виртуалок с ubuntu в vagran
description: Docker Swarm - кластер с использованием виртуалок с ubuntu в vagran
keywords: devops, docker, Docker Swarm - кластер с использованием виртуалок с ubuntu в vagran
permalink: /devops/containers/docker/clustering/swarm/by-vagrant/
---

# Docker Swarm - кластер с использованием виртуалок с ubuntu в vagrant (с сохранением данных после перезагрузки)

По материалам видеокурса: Projects-in-Docker

Делаю:  
27.04.2018

Разворачиваю в swarm вот это приложение:  
https://github.com/webmakaka/Projects-in-Docker

Делаю с помощью <a href="//sysadm.ru/server/linux/virtual/vagrant/">Vagrant</a>, т.к. при использовании docker-machine я не смог установить внутри виртуалок пакеты для поднятия NFS (Network file system).

<br/>

    $ mkdir ~/docker-swarm-scripts
    $ cd ~/docker-swarm-scripts

<br/>

    -- вроде этот плагин д.б. установлен
    $ vagrant plugin install vagrant-hosts

    $ vi Vagrantfile

{% highlight text %}

Vagrant.require_version ">= 1.9.1"

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

config.vm.boot_timeout = 900

config.vm.provider :virtualbox do |v| # On VirtualBox, we don't have guest additions or a functional vboxsf # in CoreOS, so tell Vagrant that so it can be smarter.
v.check_guest_additions = false
v.functional_vboxsf = false
end

config.vm.provision :hosts do |provisioner|

      provisioner.add_host '192.168.56.101', ['manager1']
      provisioner.add_host '192.168.56.102', ['manager1']
      provisioner.add_host '192.168.56.103', ['worker1']
      provisioner.add_host '192.168.56.104', ['worker2']
      provisioner.add_host '192.168.56.105', ['service1']

    end

config.vm.define "manager1" do |myVm|

myVm.ssh.insert_key = true

# myVm.ssh.forward_agent = true

    myVm.vm.box = 'ubuntu/xenial64'
    myVm.vm.hostname = 'manager1'

    myVm.vm.network :private_network, ip: "192.168.56.101"
    myVm.vm.network :forwarded_port, guest: 22, host: 10122, id: "ssh"


    myVm.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 512]
      v.customize ["modifyvm", :id, "--name", "manager1"]
    end

end

config.vm.define "manager2" do |myVm|

    myVm.ssh.insert_key = true
    # myVm.ssh.forward_agent = true

    myVm.vm.box = 'ubuntu/xenial64'
    myVm.vm.hostname = 'manager2'

    myVm.vm.network :private_network, ip: "192.168.56.102"
    myVm.vm.network :forwarded_port, guest: 22, host: 10222, id: "ssh"

    myVm.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 512]
      v.customize ["modifyvm", :id, "--name", "manager2"]
    end

end

config.vm.define "worker1" do |myVm|

    myVm.ssh.insert_key = true
    # myVm.ssh.forward_agent = true


    myVm.vm.box = 'ubuntu/xenial64'

    myVm.vm.hostname = 'worker1'

    myVm.vm.network :private_network, ip: "192.168.56.103"
    myVm.vm.network :forwarded_port, guest: 22, host: 10322, id: "ssh"

    myVm.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 512]
      v.customize ["modifyvm", :id, "--name", "worker1"]
    end

end

config.vm.define "worker2" do |myVm|

    myVm.ssh.insert_key = true
    # myVm.ssh.forward_agent = true

    myVm.vm.box = 'ubuntu/xenial64'
    myVm.vm.hostname = 'worker2'

    myVm.vm.network :private_network, ip: "192.168.56.104"
    myVm.vm.network :forwarded_port, guest: 22, host: 10422, id: "ssh"

    myVm.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 512]
      v.customize ["modifyvm", :id, "--name", "worker2"]
    end

end

config.vm.define "service1" do |myVm|

    myVm.ssh.insert_key = true

    myVm.vm.box = 'ubuntu/xenial64'
    myVm.vm.hostname = 'service1'

    myVm.vm.network :private_network, ip: "192.168.56.105"
    myVm.vm.network :forwarded_port, guest: 22, host: 10522, id: "ssh"

    myVm.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 512]
      v.customize ["modifyvm", :id, "--name", "service1"]
    end

end

end

{% endhighlight %}

<br/>

    $ ssh-add ~/.vagrant.d/insecure_private_key

    $ vagrant box update
    $ vagrant up

<br/>
    
    $ vagrant status
    Current machine states:

    manager1                  running (virtualbox)
    manager2                  running (virtualbox)
    worker1                   running (virtualbox)
    worker2                   running (virtualbox)
    service1                  running (virtualbox)

<br/>

### На все виртуалки ставим docker

<a href="/devops/containers/docker/setup/ubuntu/">вот как</a>

    $ vagrant ssh manager1
    $ vagrant ssh manager2
    $ vagrant ssh worker1
    $ vagrant ssh worker2
    $ vagrant ssh service1

<br/>

    В hosts уже прописаны нужные ip и хосты


    # cat /etc/hosts
    127.0.0.1 localhost
    127.0.1.1 manager1
    192.168.56.101 manager1
    192.168.56.102 manager1
    192.168.56.103 worker1
    192.168.56.104 worker2
    192.168.56.105 service1

<br/>

### На service1 будет общий storage для базы mongodb

service1

    # apt-get install -y nfs-kernel-server nfs-common
    # mkdir -p /var/nfs/dbvol
    # chown -R nobody:nogroup /var/nfs/dbvol/
    # vi /etc/exports

    /var/nfs/dbvol 192.168.56.0/24(rw,sync,no_subtree_check,no_root_squash)

    # systemctl restart nfs-kernel-server

На остальных

    # apt-get install nfs-common
    # mount service1:/var/nfs/dbvol /mnt

Потом нужно будет сделать, чтобы при перезагрузке автоматически подгружалось!!!
(Нужно в fstab прописать)

<br/>
    
### Поднимаю docker swarm   
    
    
на manager1
    
    # docker swarm init --advertise-addr 192.168.56.101
    Swarm initialized: current node (pck91122unyeqzlce69869rbf) is now a manager.

    To add a worker to this swarm, run the following command:

        docker swarm join --token SWMTKN-1-23yl9oag2jgygvd1cwx896tbj7394dv26x2oe0744pb1k0o87l-7fuw4do1ndhuuesmbkqjjo7s2 192.168.56.101:2377

    To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

<br/>
    
    # docker swarm join-token manager
    To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-23yl9oag2jgygvd1cwx896tbj7394dv26x2oe0744pb1k0o87l-48cwztvn78r94d4ikn3zanhub 192.168.56.101:2377

<br/>

на manager2

    # docker swarm join --token SWMTKN-1-23yl9oag2jgygvd1cwx896tbj7394dv26x2oe0744pb1k0o87l-48cwztvn78r94d4ikn3zanhub 192.168.56.101:2377
    This node joined a swarm as a manager.

<br/>

на worker1 и worker2 и service1

        # docker swarm join --token SWMTKN-1-23yl9oag2jgygvd1cwx896tbj7394dv26x2oe0744pb1k0o87l-7fuw4do1ndhuuesmbkqjjo7s2 192.168.56.101:2377

<br/>

на manager1

    # docker node ls
    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    pck91122unyeqzlce69869rbf *   manager1            Ready               Active              Leader              18.03.1-ce
    at0lu6yn5q652d0nvbdxshui4     manager2            Ready               Active              Reachable           18.03.1-ce
    77lzy4lva3q2o80an7tvbyf0u     service1            Ready               Active                                  18.03.1-ce
    c5xhc96p68kjhqgsjliq2ub6c     worker1             Ready               Active                                  18.03.1-ce
    z6xvtc9xe82ah2phurlhap987     worker2             Ready               Active                                  18.03.1-ce

<br/>
    
Так swarm собственно сделан
    
    
<br/>
    
### Создание отдельной подсети для swarm
    
    
на manager1
    
    # docker network create --driver overlay blog_network
    
    # docker network ls
    
    
<br/>
    
### Делаю свой registry
    
Делаю несекьерный!!!

на manager1

заменить node.id на id service01

    # docker service create -d \
    --name registry \
    --network blog_network \
    -p 5000:5000 \
    --constraint 'node.id==77lzy4lva3q2o80an7tvbyf0u' \
    registry:2

Секьерный выглядил бы как-то так, но я не пробовал!

    $ docker run -d \
    --restart=always \
    --name registry \
    -v$(pwd)/certs:/certs \
    -e REGISTRY_HTTP=0.0.0.0:443 \
    -e REGISTRY_TLS_CERTIFICATE=/certs/domain.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    -p 443:443 registry:2

<br/>

    # docker service ls
    ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
    65qgiwkzpm8i        registry            replicated          1/1                 registry:2          *:5000->5000/tcp

<br/>

    # docker service ps registry
    ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
    e238xgz8wr51        registry.1          registry:2          service1            Running             Running 23 seconds ago

<br/>

### Настройка docker для работы с созданным registry

На всех:

```
$ sudo su -
```

<br/>

```
# vi /etc/docker/daemon.json

{
    "insecure-registries":["192.168.56.105:5000"]
}
```

<br/>

```
# vi /etc/default/docker

DOCKER_OPTS='--insecure-registry 192.168.56.105:5000'
```

<br/>

```
# systemctl restart docker
```

<br/>

### Делаю имиджи с приложениями

на manager1

    $ cd ~
    $ git clone https://github.com/webmakaka/Projects-in-Docker
    $ cd Projects-in-Docker/Docker\ Swarm/

    $ cd mydb/
    $ docker build -t 192.168.56.105:5000/mydb .

    $ cd ../myapp/
    $ docker build -t 192.168.56.105:5000/myapp .

    $ cd ../mywebserver/
    $ docker build -t 192.168.56.105:5000/mywebserver .


    $ docker push 192.168.56.105:5000/mydb
    $ docker push 192.168.56.105:5000/myapp
    $ docker push 192.168.56.105:5000/mywebserver


    # docker image ls
    REPOSITORY                        TAG                 IMAGE ID            CREATED              SIZE
    192.168.56.105:5000/mywebserver   latest              a20d6bb478c4        About a minute ago   147MB
    192.168.56.105:5000/myapp         latest              d3bb076351d7        2 minutes ago        786MB
    192.168.56.105:5000/mydb          latest              dc98fb051b5f        6 minutes ago        388MB
    mongo                             3                   a0f922b3f0a1        7 days ago           366MB
    nginx                             latest              b175e7467d66        2 weeks ago          109MB
    node                              latest              aa3e171e4e95        2 weeks ago          673MB

<br/>

### Запуск сервисов

manager1, manager2, service1

    $ docker volume create --driver local --name dbvol --opt type=nfs --opt device=:/var/nfs/dbvol --opt o=addr=192.168.56.105,rw,nolock

    # docker volume ls
    DRIVER              VOLUME NAME
    local               dbvol

<br/>

на manager1

    $ docker service create \
    --name db_server \
    --mount type=volume,source=dbvol,target=/data/db \
    --mount type=volume,source=dbvol,target=/data/configdb \
    --network blog_network \
    192.168.56.105:5000/mydb

<br/>

    $ docker service create -d \
    --name app_server \
    --replicas 7 \
    --network blog_network \
    192.168.56.105:5000/myapp

<br/>

    $ docker service create -d \
    --name=webserver \
    --replicas 9 \
    --network blog_network \
    --publish=8080:80/tcp \
    192.168.56.105:5000/mywebserver

<br/>
    
Можно подключиться к проекту:

    http://192.168.56.101:8080/#/
    http://192.168.56.102:8080/#/
    http://192.168.56.103:8080/#/
    http://192.168.56.104:8080/#/
    http://192.168.56.105:8080/#/

<br/>

Добавить данные в базу по следующему URL

    http://192.168.56.101:8080/create.html#/


    login: user
    password: pass

<br/>
    
Файлы должны создаться
    
    # ls /mnt/
    collection-0-3298519624874857131.wt  journal          WiredTiger
    collection-2-3298519624874857131.wt  _mdb_catalog.wt  WiredTigerLAS.wt
    diagnostic.data                      mongod.lock      WiredTiger.lock
    index-1-3298519624874857131.wt       sizeStorer.wt    WiredTiger.turtle
    index-3-3298519624874857131.wt       storage.bson     WiredTiger.wt

<br/>

### Провека, что данные не пропадают

У меня на самом деле как-то криво все получилось.
Сначала данные пропали. Потом появились.

на manager1

    $ docker service rm db_server
    $ docker service rm app_server
    $ docker service rm webserver

И заново запускаем сервисы

<br/>

### Можно тоже самое сделать с помощью .yml файла

https://github.com/webmakaka/Projects-in-Docker/blob/master/Docker%20Swarm/blog_swarm.yml
