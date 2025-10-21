---
layout: page
title: Coreos Easy development/testing cluster
permalink: /devops/containers/coreos/example/03/
---


# Coreos Easy development/testing cluster


По материалам книги: "CoreOS-Essentials"

Блять, опять все на этот ебаный гугл завязано.


Вот это поставить пришлось:

    # apt-get install nfs-kernel-server

+ еще что-то при инсталляции записывается в

    /etc/exports




<br/>

    $ cd ~
    $ git clone https://github.com/sysadm-ru/coreos-essentials-book/
    $ cd coreos-essentials-book/Chapter5/Local_Development_VM/
    $ ./coreos-dev-install.sh

    $ cd ~/coreos-dev-env

    $ ls
    bin  fleet  share  vm  vm_halt.sh  vm_ssh.sh  vm_up.sh



    As a result, this is what we see:

    •	 Four folders, which consist of the following list:

    ° ° bin : docker , etcdctl and fleetctl files
    ° ° fleet : The nginx.service fleet unit is stored here
    ° ° share : This is shared folder between the host and VM
    ° ° vm : Vagrantfile, config.rb and user-data files

    •	 We also have three files:

    ° ° vm_halt.sh : This is used to shut down the CoreOS VM
    ° ° vm_ssh.sh : This is used to ssh to the CoreOS VM
    ° ° vm_up.sh : This is used to start the CoreOS VM, with the OS shell preset to the following:

    # Set the environment variable for the docker daemon
    export DOCKER_HOST=tcp://127.0.0.1:2375
    # path to the bin folder where we store our binary files
    export PATH=${HOME}/coreos-dev-env/bin:$PATH
    # set etcd endpoint
    export ETCDCTL_PEERS=http://172.19.20.99:2379
    # set fleetctl endpoint
    export FLEETCTL_ENDPOINT=http://172.19.20.99:2379
    export FLEETCTL_DRIVER=etcd
    export FLEETCTL_STRICT_HOST_KEY_CHECKING=false


<br/>

    $ cd ~/coreos-dev-env
    $ ./vm_up.sh


<br/>

    $ fleetctl list-machines
    MACHINE		IP		METADATA
    cf5d5876...	172.19.20.99	-


    $ cd fleet/

    $ fleetctl start nginx.service

    $ fleetctl status nginx.service
    active (running)


http://172.19.20.99/



    $ cat ~/coreos-dev-env/fleet/nginx.service
    [Unit]
    Description=nginx

    [Service]
    User=core
    TimeoutStartSec=0
    EnvironmentFile=/etc/environment
    ExecStartPre=-/usr/bin/docker rm nginx
    ExecStart=/usr/bin/docker run --rm --name nginx -p 80:80 \
     -v /home/core/share/nginx/html:/usr/share/nginx/html \
     nginx:latest
    #
    ExecStop=/usr/bin/docker stop nginx
    ExecStopPost=-/usr/bin/docker rm nginx

    Restart=always
    RestartSec=10s

    [X-Fleet]


<br/>

### Test/staging cluster setup


    $ cd coreos-essentials-book/chapter5/Test_Staging_Cluster


    Let's check "settings" file first:
    $ cat settings

    $ ./create_cluster_control.sh
    $ ./create_cluster_workers.sh
    $ ./install_fleetctl_and_scripts.sh
