---
layout: page
title: Docker Swarm
description: Docker Swarm
keywords: devops, docker, Docker Swarm
permalink: /devops/containers/docker/clustering/swarm/packt-publishing-docker-swarm/
---

# [Packt Publishing] Docker Swarm [August 31, 2017]

https://www.packtpub.com/virtualization-and-cloud/docker-swarm-video

https://bitbucket.org/sysadm-ru/docker-swarm

<br/>

    $ vi create-machine.sh

<br/>

    #!/bin/bash

    for i in 1 2 3; do
        docker-machine create -d virtualbox swarm-$i
    done

<br/>
    $ ./create-machine.sh
<br/>

    $ docker-machine ls
    NAME       ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
    docker01   -        virtualbox   Stopped                                       Unknown
    swarm-1    -        virtualbox   Running   tcp://192.168.99.100:2376           v18.03.0-ce
    swarm-2    -        virtualbox   Running   tcp://192.168.99.101:2376           v18.03.0-ce
    swarm-3    -        virtualbox   Running   tcp://192.168.99.102:2376           v18.03.0-ce

<br/>
    
    $ eval $(docker-machine env swarm-1)

<br/>
    
    $ docker-machine ls
    NAME       ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
    docker01   -        virtualbox   Stopped                                       Unknown       
    swarm-1    *        virtualbox   Running   tcp://192.168.99.100:2376           v18.03.0-ce   
    swarm-2    -        virtualbox   Running   tcp://192.168.99.101:2376           v18.03.0-ce   
    swarm-3    -        virtualbox   Running   tcp://192.168.99.102:2376           v18.03.0-ce

<br/>

    $ docker swarm init --advertise-addr $(docker-machine ip swarm-1)
    Swarm initialized: current node (q3ily6egm1c0hrxk8low98pzp) is now a manager.

    To add a worker to this swarm, run the following command:

        docker swarm join --token SWMTKN-1-5rgkkx0xvk64ualyps3a6mri1yegqcr8ez3efjtvprufte4khq-53g7mshjqb7j7ndhf6vgjpiuw 192.168.99.100:2377

    To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

<br/>

    $ docker swarm join-token manager
    To add a manager to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-5rgkkx0xvk64ualyps3a6mri1yegqcr8ez3efjtvprufte4khq-9pj7dzx7gyivpw17jdytga6k9 192.168.99.100:2377

<br/>

    $ docker swarm join-token worker
    To add a worker to this swarm, run the following command:

        docker swarm join --token SWMTKN-1-5rgkkx0xvk64ualyps3a6mri1yegqcr8ez3efjtvprufte4khq-53g7mshjqb7j7ndhf6vgjpiuw 192.168.99.100:2377

<br/>

    $ JOIN_TOKEN=$(docker swarm join-token -q worker)

    $ echo $JOIN_TOKEN
    SWMTKN-1-5rgkkx0xvk64ualyps3a6mri1yegqcr8ez3efjtvprufte4khq-53g7mshjqb7j7ndhf6vgjpiuw

<br/>

    $ docker node ls
    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    q3ily6egm1c0hrxk8low98pzp *   swarm-1             Ready               Active              Leader              18.03.0-ce

<br/>
    
    $ eval $(docker-machine env swarm-2)
    
<br/>

    $ docker swarm join --token $JOIN_TOKEN \
    --advertise-addr $(docker-machine ip swarm-2) \
    $(docker-machine ip swarm-1):2377
    This node joined a swarm as a worker.

<br/>
    
    $ eval $(docker-machine env swarm-3)

<br/>

    $ docker swarm join --token $JOIN_TOKEN \
    --advertise-addr $(docker-machine ip swarm-3) \
    $(docker-machine ip swarm-1):2377
    This node joined a swarm as a worker.

<br/>
    
    $ eval $(docker-machine env swarm-1)
    
<br/>
    
    $ docker node ls
    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    q3ily6egm1c0hrxk8low98pzp *   swarm-1             Ready               Active              Leader              18.03.0-ce
    go1vgq9rumqrwrmtn66ub369l     swarm-2             Ready               Active                                  18.03.0-ce
    pesbvmk28czffuobuh87tp43y     swarm-3             Ready               Active                                  18.03.0-ce

<br/>

### 07 - Docker Security

    $ docker swarm ca --rotate
    desired root digest: sha256:b51f2f3edd2df188bb23cb6473a6202f24aebeb68627ad33352a  rotated TLS certificates:  3/3 nodes
      rotated CA certificates:   3/3 nodes
    -----BEGIN CERTIFICATE-----
    MIIBazCCARCgAwIBAgIUJg1PFIjy3RvRbzOguf+ebtKmizEwCgYIKoZIzj0EAwIw
    EzERMA8GA1UEAxMIc3dhcm0tY2EwHhcNMTgwNDA0MDQ1MDAwWhcNMzgwMzMwMDQ1
    MDAwWjATMREwDwYDVQQDEwhzd2FybS1jYTBZMBMGByqGSM49AgEGCCqGSM49AwEH
    A0IABNrh42cwdOKgb5S45exuNLd2xdjysikvEgVHXRMc2cPmhy3wTAtMKzKJ1GPO
    pUGn+fyEWr4OKWj34yctWO1EGMWjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMB
    Af8EBTADAQH/MB0GA1UdDgQWBBR/uwKuvk0PsnKevp/rKdzCOUT57TAKBggqhkjO
    PQQDAgNJADBGAiEA7rmf7B0tp3jwXztIdB1bYP2fkXiTz6bfXTL9u1gDu+QCIQDe
    /HKj8rEFINzSlJYQVneGvchkznQ4NDSKUhNvhjNfnw==
    -----END CERTIFICATE-----

<br/>

### 08 - Docker Routing Mesh

https://github.com/dockersamples/docker-swarm-visualizer

<br/>

    $ docker service create \
      --name=viz \
      --publish=8080:8080/tcp \
      --constraint=node.role==manager \
      --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
      dockersamples/visualizer

<br/>

http://192.168.99.100:8080/
http://192.168.99.101:8080/
http://192.168.99.102:8080/

<br/>

      $ docker service ls
      ID                  NAME                MODE                REPLICAS            IMAGE                             PORTS
      e4o6s31cgivl        viz                 replicated          1/1                 dockersamples/visualizer:latest   *:8080->8080/tcp

<br/>

\$ docker service rm viz

<br/>

    $ docker service create \
    --name=docker-routing-mesh \
    --publish=8080:8080/tcp \
    albertogviana/docker-routing-mesh:1.0.0


    http://192.168.99.100:8080/
    http://192.168.99.101:8080/
    http://192.168.99.102:8080/

<br/>

    $ docker service ls
    ID                  NAME                  MODE                REPLICAS            IMAGE                                     PORTS
    0dcxgqz9fr6e        docker-routing-mesh   replicated          1/1                 albertogviana/docker-routing-mesh:1.0.0   *:8080->8080/tcp

<br/>

### 09 - Docker Overlay Network

-   Overlay
-   Ingress
-   docker_gwbridge

<br/>

    $ vi create-machine.sh

<br/>

    #!/bin/bash

    for i in 1 2 3; do
        docker-machine create -d virtualbox swarm-$i
    done

    eval "$(docker-machine env swarm-1)"

    docker swarm init --advertise-addr $(docker-machine ip swarm-1)

    JOIN_TOKEN=$(docker swarm join-token -q worker)

    for i in 2 3; do
        eval "$(docker-machine env swarm-$i)"

        docker swarm join --token $JOIN_TOKEN \
            --advertise-addr $(docker-machine ip swarm-$i) \
            $(docker-machine ip swarm-1):2377
    done

    eval "$(docker-machine env swarm-1)"
    docker service create \
      --name=visualizer \
      --publish=8000:8080/tcp \
      --constraint=node.role==manager \
      --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
      dockersamples/visualizer

<br/>

    $ vi destroy-machine.sh

<br/>

    #!/bin/bash

    for i in 1 2 3; do
        docker-machine rm -f swarm-$i
    done

<br/>

    $ source ./destroy-machine.sh
    $ source ./create-machine.sh

    $ docker network create -d overlay routing-mesh

    $ docker network ls
    NETWORK ID          NAME                DRIVER              SCOPE
    49be6295c6da        bridge              bridge              local
    4169c98a5e4d        docker_gwbridge     bridge              local
    fa8eef979e09        host                host                local
    m8aswtk85cyn        ingress             overlay             swarm
    71903bbb4029        none                null                local
    v7sv84mc0jby        routing-mesh        overlay             swarm


    $ docker service create \
    --name=docker-routing-mesh \
    --publish=8080:8080/tcp \
    --network routing-mesh \
    albertogviana/docker-routing-mesh:1.0.0


    $ docker service ls
    ID                  NAME                  MODE                REPLICAS            IMAGE                                     PORTS
    54833yozxiz4        docker-routing-mesh   replicated          1/1                 albertogviana/docker-routing-mesh:1.0.0   *:8080->8080/tcp
    ni6iagdgbwi9        visualizer            replicated          1/1                 dockersamples/visualizer:latest           *:8000->8080/tcp

<br/>
    
    $ curl http://$(docker-machine ip swarm-1):8080
    $ curl http://$(docker-machine ip swarm-2):8080
    $ curl http://$(docker-machine ip swarm-3):8080
    
    The hostname is fee870e9d748!

http://192.168.99.102:8000/

<br/>

### 10 - Deploy and Scaling Service

    $ source ./destroy-machine.sh

<br/>

    $ vi create-machine.sh

<br/>

    #!/bin/bash

    for i in 1 2 3; do
        docker-machine create -d virtualbox swarm-$i
    done

    eval "$(docker-machine env swarm-1)"

    docker swarm init --advertise-addr $(docker-machine ip swarm-1)

    JOIN_TOKEN=$(docker swarm join-token -q worker)

    for i in 2 3; do
        eval "$(docker-machine env swarm-$i)"

        docker swarm join --token $JOIN_TOKEN \
            --advertise-addr $(docker-machine ip swarm-$i) \
            $(docker-machine ip swarm-1):2377
    done

    eval "$(docker-machine env swarm-1)"
    docker service create \
      --name=visualizer \
      --publish=8000:8080/tcp \
      --constraint=node.role==manager \
      --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
      dockersamples/visualizer

<br/>

    $ source ./create-machine.sh

<br/>

    $ docker network create -d overlay --opt encrypted routing-mesh

<br/>

    $ docker service create \
    --name=docker-routing-mesh \
    --publish=8080:8080/tcp \
    --network routing-mesh \
    --reserve-memory 20m \
    albertogviana/docker-routing-mesh:1.0.0

<br/>

    $ docker service ls
    ID                  NAME                  MODE                REPLICAS            IMAGE                                     PORTS
    ithsrx5vi559        docker-routing-mesh   replicated          1/1                 albertogviana/docker-routing-mesh:1.0.0   *:8080->8080/tcp
    stq5f08vvljx        visualizer            replicated          1/1                 dockersamples/visualizer:latest           *:8000->8080/tcp

<br/>

    -- в 1 консоли
    $ docker service scale docker-routing-mesh=3
    docker-routing-mesh scaled to 3
    overall progress: 3 out of 3 tasks
    1/3: running   [==================================================>]
    2/3: running   [==================================================>]
    3/3: running   [==================================================>]
    verify: Service converged

<br/>
    
    $ docker service ls
    ID                  NAME                  MODE                REPLICAS            IMAGE                                     PORTS
    ithsrx5vi559        docker-routing-mesh   replicated          3/3                 albertogviana/docker-routing-mesh:1.0.0   *:8080->8080/tcp
    stq5f08vvljx        visualizer            replicated          1/1                 dockersamples/visualizer:latest           *:8000->8080/tcp

<br/>
    
    -- во второй консоли
    $ while true; do curl http://$(docker-machine ip swarm-1):8080; sleep 1; echo ""; done

<br/>

    $ docker service scale docker-routing-mesh=10

<br/>

### 11 - Docker Secret

    $ source ./destroy-machine.sh

<br/>

    $ vi create-machine.sh

<br/>

    #!/bin/bash

    docker-machine create -d virtualbox swarm-1

    eval "$(docker-machine env swarm-1)"

    docker swarm init --advertise-addr $(docker-machine ip swarm-1)

    docker service create \
      --name=visualizer \
      --publish=8000:8080/tcp \
      --constraint=node.role==manager \
      --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
      dockersamples/visualizer

<br/>

    $ source ./create-machine.sh

<br/>

    $ echo "This is a secret running on docker swarm" | docker secret create my_secret_data -

<br/>

    $ docker secret ls
    ID                          NAME                DRIVER              CREATED                  UPDATED
    ho49q5ip7wykavrzxhb3o5lxy   my_secret_data                          Less than a second ago   Less than a second ago

<br/>
    
    $ docker service create --name redis --secret my_secret_data redis:alpine
    
    $ docker service ps redis
    ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE                    ERROR               PORTS
    lx0yufpwybh6        redis.1             redis:alpine        swarm-1             Running             Running less than a second ago

<br/>

    $ docker ps
    CONTAINER ID        IMAGE                             COMMAND                  CREATED             STATUS                   PORTS               NAMES
    df143ea84481        redis:alpine                      "docker-entrypoint.s…"   44 seconds ago      Up About a minute        6379/tcp            redis.1.lx0yufpwybh6o2nhjpkuj9d61
    c7b56a4eb455        dockersamples/visualizer:latest   "npm start"              2 minutes ago       Up 3 minutes (healthy)   8080/tcp            visualizer.1.3c2fb3abtxkt32hzad8t4lf1s

<br/>
    
    $ docker ps --filter name=redis -q
    df143ea84481

<br/>

    $ docker exec $(docker ps --filter name=redis -q) ls -l /run/secrets
    total 4
    -r--r--r--    1 root     root            41 Apr  5 04:02 my_secret_data

<br/>

    $ docker exec $(docker ps --filter name=redis -q) cat /run/secrets/my_secret_data
    This is a secret running on docker swarm

<br/>

    == не может удалить
    $ docker secret rm my_secret_data
    Error response from daemon: rpc error: code = InvalidArgument desc = secret 'my_secret_data' is in use by the following service: redis


    $ docker service rm redis

    --ок
    $ docker secret rm my_secret_data

<br/>

    $ vi default.conf

<br/>

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;
        #access_log  /var/log/nginx/host.access.log  main;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }

<br/>

    $ docker secret create default.conf default.conf

<br/>

    $ docker secret ls
    ID                          NAME                DRIVER              CREATED                  UPDATED
    b6cvu6o0ex9fbk9g7sacu0hzy   default.conf                            Less than a second ago   Less than a second ago

<br/>

    $ docker service create \
      --name=nginx \
      --secret source=default.conf,target=/etc/nginx/conf.d/default.conf \
      --publish=80:80 \
      nginx:latest \
      sh -c "exec nginx -g 'daemon off;'"

  <br/>
  
      $ docker service ps nginx
        ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE                    ERROR               PORTS
        2jveijo6s6jz        nginx.1             nginx:latest        swarm-1             Running             Running less than a second ago

<br/>

    $ curl http://$(docker-machine ip swarm-1):80

<br/>

## 03-RUNNING MY APPLICATION

<br/>

### 12 - Build My Web Application Dockerfile

    $ docker build -t albertogviana/names-demo .

<br/>

### 13 - Deploy My Services

    $ source ./destroy-machine.sh

<br/>

    $ vi create-machine.sh

<br/>

    #!/bin/bash

    for i in 1 2 3; do
        docker-machine create -d virtualbox swarm-$i
    done

    eval "$(docker-machine env swarm-1)"

    docker swarm init --advertise-addr $(docker-machine ip swarm-1)

    JOIN_TOKEN=$(docker swarm join-token -q worker)

    for i in 2 3; do
        eval "$(docker-machine env swarm-$i)"

        docker swarm join --token $JOIN_TOKEN \
            --advertise-addr $(docker-machine ip swarm-$i) \
            $(docker-machine ip swarm-1):2377
    done

    eval "$(docker-machine env swarm-1)"
    docker service create \
      --name=visualizer \
      --publish=8000:8080/tcp \
      --constraint=node.role==manager \
      --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
      dockersamples/visualizer

<br/>

    $ source ./create-machine.sh

<br/>

    $ eval "$(docker-machine env swarm-1)"
    $ docker network create -d overlay --opt encrypted names-demo

    $ docker service create --name mongodb --network names-demo mongo:3.2.15

    $ docker service ps mongodb
    ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE                    ERROR               PORTS
    tsrk1qx52cqe        mongodb.1           mongo:3.2.15        swarm-3             Running             Running less than a second ago

<br/>

    $ docker service create --name names-demo --network names-demo -e DB=mongodb -p 8080:8080 albertogviana/names-demo

    $ docker service ps names-demo
    ID                  NAME                IMAGE                             NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
    pfh6wvva755a        names-demo.1        albertogviana/names-demo:latest   swarm-2             Running             Running 10 seconds ago

<br/>
    
    $ curl -i -X POST -d '{"firstname": "Alberto", "lastname": "Viana"}' -H "Accept: application/json" http://$(docker-machine ip swarm-1):8080/person/add
    
    $ curl -i -H "Accept: application/json" http://$(docker-machine ip swarm-1):8080/person
    
    HTTP/1.1 200 OK
    Date: Thu, 05 Apr 2018 05:17:55 GMT
    Content-Length: 63
    Content-Type: text/plain; charset=utf-8

    [
      {
        "firstname": "Alberto",
        "lastname": "Viana"
      }
    ]

<br/>

    $ docker service scale names-demo=5

<br/>

    $ docker service ps names-demo
    ID                  NAME                IMAGE                             NODE                DESIRED STATE       CURRENT STATE                    ERROR               PORTS
    pfh6wvva755a        names-demo.1        albertogviana/names-demo:latest   swarm-2             Running             Running 9 minutes ago
    nbkch622wcy8        names-demo.2        albertogviana/names-demo:latest   swarm-1             Running             Running less than a second ago
    ve622210ey4i        names-demo.3        albertogviana/names-demo:latest   swarm-1             Running             Running less than a second ago
    p5by5v3p0s6a        names-demo.4        albertogviana/names-demo:latest   swarm-3             Running             Running less than a second ago
    j4uqz1r15r3j        names-demo.5        albertogviana/names-demo:latest   swarm-2             Running             Running less than a second ago

<br/>
    
    $ curl -i -H "Accept: application/json" http://$(docker-machine ip swarm-1):8080/health
    HTTP/1.1 200 OK
    Content-Type: application/json
    Date: Thu, 05 Apr 2018 05:24:18 GMT
    Content-Length: 33

    {"version":"1.0.0","status":"OK"}

<br/>

### 14 - Using Docker Secret with My Service

    $ source ./destroy-machine.sh

<br/>

    $ vi create-machine.sh

https://bitbucket.org/sysadm-ru/docker-swarm/raw/5a6c5470315ebcec34d5d90eaf54418566e6adb5/4.3/create-machine.sh

    $ source ./create-machine.sh

<br/>

    $ vi config.yml


    config:
      database: mongodb

https://bitbucket.org/sysadm-ru/docker-swarm/src/5a6c5470315ebcec34d5d90eaf54418566e6adb5/4.3/config.yml?at=master&fileviewer=file-view-default

<br/>

    $ eval "$(docker-machine env swarm-1)"

    $ docker node ls

    $ docker network create -d overlay --opt encrypted names-demo

    $ docker service create --name mongodb --network names-demo mongo:3.2.15

    $ docker secret create config.yml config.yml

<br/>
    
    $ docker secret ls
    ID                          NAME                DRIVER              CREATED                  UPDATED
    vcs31totjzquxyovqj5sirjjf   config.yml                              Less than a second ago   Less than a second ago

<br/>

    $ docker service ls
    ID                  NAME                MODE                REPLICAS            IMAGE                             PORTS
    t3yfna9akr2m        mongodb             replicated          1/1                 mongo:3.2.15
    j61pli5tt3to        visualizer          replicated          1/1                 dockersamples/visualizer:latest   *:8000->8080/tcp

<br/>

    $ docker service create --name names-demo --network names-demo -p 8080:8080 --secret config.yml albertogviana/names-demo:2.0.0

<br/>

    $ docker service ps names-demo

<br/>

    $ docker service ps names-demo
    ID                  NAME                IMAGE                            NODE                DESIRED STATE       CURRENT STATE                    ERROR               PORTS
    a1dfxzc8t2t4        names-demo.1        albertogviana/names-demo:2.0.0   swarm-3             Running             Running less than a second ago

<br/>

    $ curl -i -X POST -d '{"firstname": "Alberto", "lastname": "Viana"}' -H "Accept: application/json" http://$(docker-machine ip swarm-1):8080/person/add

    $ curl -i -H "Accept: application/json" http://$(docker-machine ip swarm-1):8080/person

    [
      {
        "firstname": "Alberto",
        "lastname": "Viana"
      }
    ]

<br/>

    $ eval "$(docker-machine env swarm-3)"

<br/>

    $ docker ps
    CONTAINER ID        IMAGE                            COMMAND             CREATED             STATUS                   PORTS               NAMES
    5b3db2864740        albertogviana/names-demo:2.0.0   "names-demo"        7 minutes ago       Up 7 minutes (healthy)   8080/tcp            names-demo.1.a1dfxzc8t2t4ean8prope3i4o

<br/>
    
    
    $ docker exec -it names-demo.1.a1dfxzc8t2t4ean8prope3i4o ls /run/secrets
    
    config.yml
    
<br/>
    
    $ docker exec -it names-demo.1.a1dfxzc8t2t4ean8prope3i4o cat /run/secrets/config.yml
    
    config:
      database: mongodb

<br/>

### 15 - Rolling Updates

    $ source ./destroy-machine.sh

<br/>

    $ vi create-machine.sh

https://bitbucket.org/sysadm-ru/docker-swarm/raw/5a6c5470315ebcec34d5d90eaf54418566e6adb5/4.4/create-machine.sh

    $ source ./create-machine.sh

<br/>

    $ vi config.yml

    config:
      database: mongodb

https://bitbucket.org/sysadm-ru/docker-swarm/raw/5a6c5470315ebcec34d5d90eaf54418566e6adb5/4.4/config.yml

<br/>

    $ eval "$(docker-machine env swarm-1)"

    $ docker node ls

    $ docker network create -d overlay --opt encrypted names-demo

    $ docker service create --name mongodb --network names-demo mongo:3.2.15

    $ docker secret create config.yml config.yml

<br/>

    $ docker service create --name names-demo \
    --network names-demo \
    --replicas 3 \
    -p 8080:8080 \
    --rollback-max-failure-ratio 0.5 \
    --update-delay 10s \
    --update-parallelism 1 \
    --secret config.yml \
    albertogviana/names-demo:2.0.0

<br/>
    
    $ docker service ls
    ID                  NAME                MODE                REPLICAS            IMAGE                             PORTS
    uhlwzvsv2fsj        mongodb             replicated          1/1                 mongo:3.2.15                      
    moeele4mv70q        names-demo          replicated          3/3                 albertogviana/names-demo:2.0.0    *:8080->8080/tcp
    p1gggbm21bm8        visualizer          replicated          1/1                 dockersamples/visualizer:latest   *:8000->8080/tcp

http://192.168.99.100:8000/

    -- во второй консоли
    $ while true; do curl http://$(docker-machine ip swarm-1):8080/health; sleep 1; echo "\n"; done

    {"version":"2.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}\n

<br/>
    
    $ docker service update \
    --update-failure-action rollback \
    --rollback-parallelism 2 \
    --image albertogviana/names-demo:3.0.0 \
    names-demo

<br/>

    {"version":"2.0.0","status":"OK"}\n
    {"version":"3.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}\n
    {"version":"3.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}\n
    {"version":"3.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}\n
    {"version":"3.0.0","status":"OK"}\n

<br/>

    $ docker service ps names-demo
    ID                  NAME                IMAGE                            NODE                DESIRED STATE       CURRENT STATE                     ERROR               PORTS
    fdj3s0niyy4e        names-demo.1        albertogviana/names-demo:3.0.0   swarm-3             Running             Running 14 seconds ago
    7iy5xy3amlql         \_ names-demo.1    albertogviana/names-demo:2.0.0   swarm-3             Shutdown            Shutdown 26 seconds ago
    xi60et91ch3h        names-demo.2        albertogviana/names-demo:3.0.0   swarm-2             Running             Running less than a second ago
    uq6mbxb0ac1h         \_ names-demo.2    albertogviana/names-demo:2.0.0   swarm-2             Shutdown            Shutdown less than a second ago
    ziiuglvhstbj        names-demo.3        albertogviana/names-demo:3.0.0   swarm-1             Running             Running less than a second ago
    x33j77hgir55         \_ names-demo.3    albertogviana/names-demo:2.0.0   swarm-1             Shutdown            Shutdown less than a second ago

<br/>

    $ docker secret create config2.yml config.yml

    $ docker secret ls
    ID                          NAME                DRIVER              CREATED                  UPDATED
    2onrpuukz4427uw9z79n9zh73   config2.yml                             Less than a second ago   Less than a second ago
    swcnij08yzgrvha9kgrh940q0   config.yml                              18 minutes ago           18 minutes ago

<br/>

    $ docker service update \
    --secret-add source=config2.yml,target=/run/secrets/config.yml \
    --secret-rm config.yml \
    names-demo

<br/>

    $ curl -i -X POST -d '{"firstname": "Alberto", "lastname": "Viana"}' -H "Accept: application/json" http://$(docker-machine ip swarm-1):8080/person/add

    $ curl -i -H "Accept: application/json" http://$(docker-machine ip swarm-1):8080/person

    [
      {
        "firstname": "Alberto",
        "lastname": "Viana"
      }
    ]

<br/>

    $ docker service update \
    --update-failure-action rollback \
    --rollback-parallelism 2 \
    --image albertogviana/names-demo:error \
    names-demo

    overall progress: rolling back update: 3 out of 3 tasks
    1/3: running   [>                                                  ]
    2/3: running   [>                                                  ]
    3/3: running   [>                                                  ]
    rollback: update rolled back due to failure or early termination of task 0qsdbfhndsp7n05wb0ow00hl7
    verify: Service converged

<br/>

    $ docker service ps names-demo
    ID                  NAME                IMAGE                            NODE                DESIRED STATE       CURRENT STATE                     ERROR               PORTS
    ikusdn09yexj        names-demo.1        albertogviana/names-demo:3.0.0   swarm-3             Running             Running 3 minutes ago
    fdj3s0niyy4e         \_ names-demo.1    albertogviana/names-demo:3.0.0   swarm-3             Shutdown            Shutdown 3 minutes ago
    7iy5xy3amlql         \_ names-demo.1    albertogviana/names-demo:2.0.0   swarm-3             Shutdown            Shutdown 8 minutes ago
    r1rzlk2d0o8g        names-demo.2        albertogviana/names-demo:3.0.0   swarm-2             Running             Running less than a second ago
    paralsqqyu6p         \_ names-demo.2    albertogviana/names-demo:error   swarm-2             Shutdown            Shutdown less than a second ago
    aehss1gts2zx         \_ names-demo.2    albertogviana/names-demo:3.0.0   swarm-2             Shutdown            Shutdown less than a second ago
    xi60et91ch3h         \_ names-demo.2    albertogviana/names-demo:3.0.0   swarm-2             Shutdown            Shutdown 3 minutes ago
    uq6mbxb0ac1h         \_ names-demo.2    albertogviana/names-demo:2.0.0   swarm-2             Shutdown            Shutdown 7 minutes ago
    qn4mafasx93c        names-demo.3        albertogviana/names-demo:3.0.0   swarm-1             Running             Running 3 minutes ago
    ziiuglvhstbj         \_ names-demo.3    albertogviana/names-demo:3.0.0   swarm-1             Shutdown            Shutdown 4 minutes ago
    x33j77hgir55         \_ names-demo.3    albertogviana/names-demo:2.0.0   swarm-1             Shutdown            Shutdown 7 minutes ago

<br/>

    $ curl -i -H "Accept: application/json" http://$(docker-machine ip swarm-1):8080/person
    HTTP/1.1 200 OK
    Date: Fri, 06 Apr 2018 01:29:38 GMT
    Content-Length: 63
    Content-Type: text/plain; charset=utf-8

    [
      {
        "firstname": "Alberto",
        "lastname": "Viana"
      }

<br/>

## 04-DOCKER STACK

<br/>

## 17 - Building Our Docker Stack File

    $ source ./destroy-machine.sh

<br/>

    $ vi create-machine.sh

https://bitbucket.org/sysadm-ru/docker-swarm/raw/5a6c5470315ebcec34d5d90eaf54418566e6adb5/5.2/create-machine.sh

    $ source ./create-machine.sh

<br/>

    $ vi docker-routing-mesh.yml

    https://bitbucket.org/sysadm-ru/docker-swarm/raw/d382b2f2b6cce1ca285dacf14807128f279b9c47/4.2/docker-routing-mesh.yml

<br/>

    $ eval "$(docker-machine env swarm-1)"

    $ docker network create -d overlay --opt encrypted routing-mesh

    $ docker stack deploy -c docker-routing-mesh.yml routing


    $ docker stack ls
    NAME                SERVICES
    routing             1

<br/>
    
    $ docker stack ps --no-trunc routing
    ID                          NAME                            IMAGE                                                                                                             NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
    m08ku6jbi7yan7wx0zbftht7p   routing_docker-routing-mesh.1   albertogviana/docker-routing-mesh:1.0.0@sha256:87e5c74f8042848893440b24a33ea0e3494b9da475987b0e704f0d3262bce3cd   swarm-1             Running             Running 54 seconds ago                       
    yonj3df443ocial1ec9v1cv0o   routing_docker-routing-mesh.2   albertogviana/docker-routing-mesh:1.0.0@sha256:87e5c74f8042848893440b24a33ea0e3494b9da475987b0e704f0d3262bce3cd   swarm-3             Running             Running 54 seconds ago                       
    8a1sbn9207mumj25o70sv4sbg   routing_docker-routing-mesh.3   albertogviana/docker-routing-mesh:1.0.0@sha256:87e5c74f8042848893440b24a33ea0e3494b9da475987b0e704f0d3262bce3cd   swarm-2             Running             Running 54 seconds ago

<br/>

    $ while true; do curl http://$(docker-machine ip swarm-1):8080/health; sleep 1; echo "\n"; done

<br/>

    $ vi docker-routing-mesh-2.0.0.yml

https://bitbucket.org/sysadm-ru/docker-swarm/raw/d382b2f2b6cce1ca285dacf14807128f279b9c47/4.2/docker-routing-mesh-2.0.0.yml

    $ docker stack deploy -c docker-routing-mesh-2.0.0.yml routing

    $ docker stack services routing
    ID                  NAME                          MODE                REPLICAS            IMAGE                                     PORTS
    tr32b8mtfza2        routing_docker-routing-mesh   replicated          3/3                 albertogviana/docker-routing-mesh:2.0.0   *:8080->8080/tcp

<br/>

    $ docker stack ps --no-trunc routing
    ID                          NAME                                IMAGE                                                                                                             NODE                DESIRED STATE       CURRENT STATE                     ERROR               PORTS
    j3pqyrhzem980gpf8979kutva   routing_docker-routing-mesh.1       albertogviana/docker-routing-mesh:2.0.0@sha256:d7d9e186a63a825e4631a4c59515a22d25e8b33013bf8f13c5d0291f9d241555   swarm-1             Running             Running less than a second ago
    m08ku6jbi7yan7wx0zbftht7p    \_ routing_docker-routing-mesh.1   albertogviana/docker-routing-mesh:1.0.0@sha256:87e5c74f8042848893440b24a33ea0e3494b9da475987b0e704f0d3262bce3cd   swarm-1             Shutdown            Shutdown less than a second ago
    uhgomxdvu1ky5holdshau7e2u   routing_docker-routing-mesh.2       albertogviana/docker-routing-mesh:2.0.0@sha256:d7d9e186a63a825e4631a4c59515a22d25e8b33013bf8f13c5d0291f9d241555   swarm-3             Ready               Ready less than a second ago
    yonj3df443ocial1ec9v1cv0o    \_ routing_docker-routing-mesh.2   albertogviana/docker-routing-mesh:1.0.0@sha256:87e5c74f8042848893440b24a33ea0e3494b9da475987b0e704f0d3262bce3cd   swarm-3             Shutdown            Running less than a second ago
    q8tcy8ncy8q66xpuq505i7af7   routing_docker-routing-mesh.3       albertogviana/docker-routing-mesh:2.0.0@sha256:d7d9e186a63a825e4631a4c59515a22d25e8b33013bf8f13c5d0291f9d241555   swarm-2             Running             Running 12 seconds ago
    8a1sbn9207mumj25o70sv4sbg    \_ routing_docker-routing-mesh.3   albertogviana/docker-routing-mesh:1.0.0@sha256:87e5c74f8042848893440b24a33ea0e3494b9da475987b0e704f0d3262bce3cd   swarm-2             Shutdown            Shutdown 23 seconds ago

<br/>

    $ while true; do curl http://$(docker-machine ip swarm-1):8080/health; sleep 1; echo "\n"; done

<br/>
    
    {"version":"2.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}\n
    {"version":"2.0.0","status":"OK"}^C

<br/>

    $ docker stack services routing
    ID                  NAME                          MODE                REPLICAS            IMAGE                                     PORTS
    tr32b8mtfza2        routing_docker-routing-mesh   replicated          3/3                 albertogviana/docker-routing-mesh:2.0.0   *:8080->8080/tcp

<br/>

    $ docker service ls
    ID                  NAME                          MODE                REPLICAS            IMAGE                                     PORTS
    tr32b8mtfza2        routing_docker-routing-mesh   replicated          3/3                 albertogviana/docker-routing-mesh:2.0.0   *:8080->8080/tcp
    lwhhap2uri31        visualizer                    replicated          1/1                 dockersamples/visualizer:latest           *:8000->8080/tcp

<br/>

### 18 - Deploying Our Application

    $ source ./destroy-machine.sh

<br/>

    $ vi create-machine.sh

https://bitbucket.org/sysadm-ru/docker-swarm/raw/d382b2f2b6cce1ca285dacf14807128f279b9c47/4.3/create-machine.sh

    $ source ./create-machine.sh

<br/>

    $ eval "$(docker-machine env swarm-1)"

    $ vi api-2.0.0.yml

    https://bitbucket.org/sysadm-ru/docker-swarm/raw/d382b2f2b6cce1ca285dacf14807128f279b9c47/4.3/api-2.0.0.yml

    $ vi config.yml

    https://bitbucket.org/sysadm-ru/docker-swarm/raw/5a6c5470315ebcec34d5d90eaf54418566e6adb5/5.3/config.yml



    $ docker network create -d overlay --opt encrypted names-demo

    $ docker secret create config.yml config.yml


    $ docker stack deploy -c api-2.0.0.yml api

    $ docker stack ls
    NAME                SERVICES
    api                 2


    $ docker stack services api
    ID                  NAME                MODE                REPLICAS            IMAGE                            PORTS
    o6a3mr3vqz8j        api_mongodb         replicated          1/1                 mongo:3.2.15
    tytvj4gcy4x6        api_names-demo      replicated          3/3                 albertogviana/names-demo:2.0.0   *:8080->8080/tcp

<br/>

    $ docker stack ps --no-trunc api
    ID                          NAME                   IMAGE                                                                                                    NODE                DESIRED STATE       CURRENT STATE            ERROR                       PORTS
    sk6nfdwknh136s852cd9bq2n9   api_names-demo.1       albertogviana/names-demo:2.0.0@sha256:687aa89eb3ab0abffee9f2eb1f56401da0c3a8fd16a75b4fc096f05f20a3c411   swarm-2             Running             Running 35 seconds ago
    y8uh8cb6joymzhtyljpfvjrr4   api_mongodb.1          mongo:3.2.15@sha256:ef3277c7221e8512a1657ad90dfa2ad13ae2e35aacce6cd7defabbbdcf67ca76                     swarm-2             Running             Running 37 seconds ago
    5z5iobp353v1qcbqdguxhw5zr   api_names-demo.1       albertogviana/names-demo:2.0.0@sha256:687aa89eb3ab0abffee9f2eb1f56401da0c3a8fd16a75b4fc096f05f20a3c411   swarm-2             Shutdown            Failed 52 seconds ago    "task: non-zero exit (2)"
    bm8ti6iimkdg3mtsgai68j88x   api_names-demo.2       albertogviana/names-demo:2.0.0@sha256:687aa89eb3ab0abffee9f2eb1f56401da0c3a8fd16a75b4fc096f05f20a3c411   swarm-3             Running             Running 25 seconds ago
    9druq4pyetxw7lqq58dblnual    \_ api_names-demo.2   albertogviana/names-demo:2.0.0@sha256:687aa89eb3ab0abffee9f2eb1f56401da0c3a8fd16a75b4fc096f05f20a3c411   swarm-3             Shutdown            Failed 41 seconds ago    "task: non-zero exit (2)"
    arnbd2jjyzxovkc5eq2kkr2dk    \_ api_names-demo.2   albertogviana/names-demo:2.0.0@sha256:687aa89eb3ab0abffee9f2eb1f56401da0c3a8fd16a75b4fc096f05f20a3c411   swarm-3             Shutdown            Failed 57 seconds ago    "task: non-zero exit (2)"
    slsv8ax36qi9k61bqm0fzepau   api_names-demo.3       albertogviana/names-demo:2.0.0@sha256:687aa89eb3ab0abffee9f2eb1f56401da0c3a8fd16a75b4fc096f05f20a3c411   swarm-1             Running             Running 27 seconds ago
    cnpaqpvjw27e0eg886lq86b36    \_ api_names-demo.3   albertogviana/names-demo:2.0.0@sha256:687aa89eb3ab0abffee9f2eb1f56401da0c3a8fd16a75b4fc096f05f20a3c411   swarm-1             Shutdown            Failed 43 seconds ago    "task: non-zero exit (2)"

<br/>

    $ docker stack ps api
    ID                  NAME                   IMAGE                            NODE                DESIRED STATE       CURRENT STATE                ERROR                       PORTS
    sk6nfdwknh13        api_names-demo.1       albertogviana/names-demo:2.0.0   swarm-2             Running             Running about a minute ago
    y8uh8cb6joym        api_mongodb.1          mongo:3.2.15                     swarm-2             Running             Running about a minute ago
    5z5iobp353v1        api_names-demo.1       albertogviana/names-demo:2.0.0   swarm-2             Shutdown            Failed about a minute ago    "task: non-zero exit (2)"
    bm8ti6iimkdg        api_names-demo.2       albertogviana/names-demo:2.0.0   swarm-3             Running             Running about a minute ago
    9druq4pyetxw         \_ api_names-demo.2   albertogviana/names-demo:2.0.0   swarm-3             Shutdown            Failed about a minute ago    "task: non-zero exit (2)"
    arnbd2jjyzxo         \_ api_names-demo.2   albertogviana/names-demo:2.0.0   swarm-3             Shutdown            Failed about a minute ago    "task: non-zero exit (2)"
    slsv8ax36qi9        api_names-demo.3       albertogviana/names-demo:2.0.0   swarm-1             Running             Running about a minute ago
    cnpaqpvjw27e         \_ api_names-demo.3   albertogviana/names-demo:2.0.0   swarm-1             Shutdown            Failed about a minute ago    "task: non-zero exit (2)"

<br/>

    $ while true; do curl http://$(docker-machine ip swarm-1):8080/health; sleep 1; echo "\n"; done

    {"version":"2.0.0","status":"OK"}\n

<br/>

    $ vi api-3.0.0.yml

    https://bitbucket.org/sysadm-ru/docker-swarm/raw/5a6c5470315ebcec34d5d90eaf54418566e6adb5/5.3/api-3.0.0.yml


    $ docker secret create config2.yml config.yml

    $ docker stack deploy -c api-3.0.0.yml api

    $ docker stack ps api
    ID                  NAME                   IMAGE                            NODE                DESIRED STATE       CURRENT STATE                 ERROR                       PORTS
    vs0mlqtqh09j        api_names-demo.1       albertogviana/names-demo:3.0.0   swarm-2             Running             Running 51 seconds ago
    sk6nfdwknh13         \_ api_names-demo.1   albertogviana/names-demo:2.0.0   swarm-2             Shutdown            Shutdown about a minute ago
    y8uh8cb6joym        api_mongodb.1          mongo:3.2.15                     swarm-2             Running             Running 17 minutes ago
    5z5iobp353v1        api_names-demo.1       albertogviana/names-demo:2.0.0   swarm-2             Shutdown            Failed 17 minutes ago         "task: non-zero exit (2)"
    t90x08cpgtl3        api_names-demo.2       albertogviana/names-demo:3.0.0   swarm-3             Running             Running 27 seconds ago
    bm8ti6iimkdg         \_ api_names-demo.2   albertogviana/names-demo:2.0.0   swarm-3             Shutdown            Shutdown 37 seconds ago
    9druq4pyetxw         \_ api_names-demo.2   albertogviana/names-demo:2.0.0   swarm-3             Shutdown            Failed 17 minutes ago         "task: non-zero exit (2)"
    arnbd2jjyzxo         \_ api_names-demo.2   albertogviana/names-demo:2.0.0   swarm-3             Shutdown            Failed 17 minutes ago         "task: non-zero exit (2)"
    b3i9j96ktone        api_names-demo.3       albertogviana/names-demo:3.0.0   swarm-1             Running             Running 2 seconds ago
    slsv8ax36qi9         \_ api_names-demo.3   albertogviana/names-demo:2.0.0   swarm-1             Shutdown            Shutdown 13 seconds ago
    cnpaqpvjw27e         \_ api_names-demo.3   albertogviana/names-demo:2.0.0   swarm-1             Shutdown            Failed 17 minutes ago         "task: non-zero exit (2)"

<br/>

    $ docker stack services api
    ID                  NAME                MODE                REPLICAS            IMAGE                            PORTS
    o6a3mr3vqz8j        api_mongodb         replicated          1/1                 mongo:3.2.15
    tytvj4gcy4x6        api_names-demo      replicated          3/3                 albertogviana/names-demo:3.0.0   *:8080->8080/tcp

<br/>

    $ while true; do curl http://$(docker-machine ip swarm-1):8080/health; sleep 1; echo "\n"; done

    {"version":"3.0.0","status":"OK"}

<br/>

    $ vi api-error.yml

    https://bitbucket.org/sysadm-ru/docker-swarm/raw/5a6c5470315ebcec34d5d90eaf54418566e6adb5/5.3/api-error.yml


    $ docker stack deploy -c api-error.yml api


    $ docker stack ps api
    ID                  NAME                   IMAGE                            NODE                DESIRED STATE       CURRENT STATE                    ERROR                       PORTS
    vs0mlqtqh09j        api_names-demo.1       albertogviana/names-demo:3.0.0   swarm-2             Running             Running 5 minutes ago
    sk6nfdwknh13         \_ api_names-demo.1   albertogviana/names-demo:2.0.0   swarm-2             Shutdown            Shutdown 5 minutes ago
    y8uh8cb6joym        api_mongodb.1          mongo:3.2.15                     swarm-2             Running             Running 22 minutes ago
    5z5iobp353v1        api_names-demo.1       albertogviana/names-demo:2.0.0   swarm-2             Shutdown            Failed 22 minutes ago            "task: non-zero exit (2)"
    qrwrg9dmnf1f        api_names-demo.2       albertogviana/names-demo:3.0.0   swarm-3             Running             Running less than a second ago
    olohjybqvwan         \_ api_names-demo.2   albertogviana/names-demo:error   swarm-3             Shutdown            Complete 10 seconds ago
    bkxmrgbc9osm         \_ api_names-demo.2   albertogviana/names-demo:error   swarm-3             Shutdown            Complete 16 seconds ago
    t90x08cpgtl3         \_ api_names-demo.2   albertogviana/names-demo:3.0.0   swarm-3             Shutdown            Shutdown 30 seconds ago
    bm8ti6iimkdg         \_ api_names-demo.2   albertogviana/names-demo:2.0.0   swarm-3             Shutdown            Shutdown 5 minutes ago
    9dz76d8sh0uu        api_names-demo.3       albertogviana/names-demo:3.0.0   swarm-1             Running             Running less than a second ago
    sg7kgm7gvbxc         \_ api_names-demo.3   albertogviana/names-demo:error   swarm-1             Shutdown            Shutdown 11 seconds ago
    cok6ftwcxdi9         \_ api_names-demo.3   albertogviana/names-demo:error   swarm-1             Shutdown            Complete 14 seconds ago
    slsv8ax36qi9         \_ api_names-demo.3   albertogviana/names-demo:2.0.0   swarm-1             Shutdown            Shutdown 4 minutes ago
    cnpaqpvjw27e         \_ api_names-demo.3   albertogviana/names-demo:2.0.0   swarm-1             Shutdown            Failed 22 minutes ago            "task: non-zero exit (2)"

<br/>

    $ docker stack rm api

<br/>

## 05-MANAGING NODES

<br/>

### 19 - Docker Nodes

    $ source ./destroy-machine.sh

<br/>

    $ vi create-machine.sh

https://bitbucket.org/sysadm-ru/docker-swarm/raw/d382b2f2b6cce1ca285dacf14807128f279b9c47/5.1/create-machine.sh

    $ source ./create-machine.sh

<br/>

    $ eval "$(docker-machine env swarm-1)"

<br/>

    $ docker service create \
      --name=visualizer \
      --publish=8000:8080/tcp \
      --constraint=node.role==manager \
      --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
      dockersamples/visualizer

<br/> 
      
     $  docker service ps visualizer
     ID                  NAME                IMAGE                             NODE                DESIRED STATE       CURRENT STATE                    ERROR               PORTS
     15m11mtcqe3l        visualizer.1        dockersamples/visualizer:latest   swarm-1             Running             Running less than a second ago

http://192.168.99.102:8000/

    $ docker node inspect self | jq .

    "Spec": {
         "Availability": "active",
         "Role": "manager",
         "Labels": {}
       },

<br/>

    $ docker node update --label-add type=app swarm-1
    $ docker node update --label-add type=app swarm-2
    $ docker node update --label-add type=db swarm-3

<br/>
    
    $ vi config.yml

https://bitbucket.org/sysadm-ru/docker-swarm/raw/d382b2f2b6cce1ca285dacf14807128f279b9c47/5.1/config.yml

    $ docker secret create config.yml config.yml
    $ docker network create -d overlay --opt encrypted names-demo

    $ vi api-3.0.0.yml

    $ docker stack deploy -c api-3.0.0.yml api

    $ docker node ls
    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    r8off1aij9u29qt06des6x1l6 *   swarm-1             Ready               Active              Leader              18.03.0-ce
    e0z1ruvfxqig5giv3zdjz6768     swarm-2             Ready               Active                                  18.03.0-ce
    i1swprldp4z3pdgtstql5gsaz     swarm-3             Ready               Active                                  18.03.0-ce

<br/>

    $ docker node update --availability=drain swarm-1

на первой ноде ничего не работает

    $ docker node ls
    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    r8off1aij9u29qt06des6x1l6 *   swarm-1             Ready               Drain               Leader              18.03.0-ce
    e0z1ruvfxqig5giv3zdjz6768     swarm-2             Ready               Active                                  18.03.0-ce
    i1swprldp4z3pdgtstql5gsaz     swarm-3             Ready               Active                                  18.03.0-ce

<br/>

    $ docker stack ps -f desired-state=running api
    ID                  NAME                IMAGE                            NODE                DESIRED STATE       CURRENT STATE            ERROR               PORTS
    is781lgc9wdm        api_names-demo.1    albertogviana/names-demo:3.0.0   swarm-2             Running             Running 3 minutes ago
    wb7nbx6ccypg        api_mongodb.1       mongo:3.2.15                     swarm-3             Running             Running 3 minutes ago
    3nmlf6xzmune        api_names-demo.2    albertogviana/names-demo:3.0.0   swarm-2             Running             Running 3 minutes ago
    s549raygq0vz        api_names-demo.3    albertogviana/names-demo:3.0.0   swarm-2             Running             Running 21 seconds ago

<br/>

    $ docker service scale api_names-demo=4

<br/>

    $  docker stack ps -f desired-state=running api
    ID                  NAME                IMAGE                            NODE                DESIRED STATE       CURRENT STATE                    ERROR               PORTS
    is781lgc9wdm        api_names-demo.1    albertogviana/names-demo:3.0.0   swarm-2             Running             Running 4 minutes ago
    wb7nbx6ccypg        api_mongodb.1       mongo:3.2.15                     swarm-3             Running             Running 4 minutes ago
    3nmlf6xzmune        api_names-demo.2    albertogviana/names-demo:3.0.0   swarm-2             Running             Running 4 minutes ago
    s549raygq0vz        api_names-demo.3    albertogviana/names-demo:3.0.0   swarm-2             Running             Running 2 minutes ago
    uheakqtpjxeu        api_names-demo.4    albertogviana/names-demo:3.0.0   swarm-2             Running             Running less than a second ago

<br/>

    $ docker node update --availability=active swarm-1

<br/>

    $ docker node ls
    ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
    r8off1aij9u29qt06des6x1l6 *   swarm-1             Ready               Active              Leader              18.03.0-ce
    e0z1ruvfxqig5giv3zdjz6768     swarm-2             Ready               Active                                  18.03.0-ce
    i1swprldp4z3pdgtstql5gsaz     swarm-3             Ready               Active                                  18.03.0-ce

<br/>

### 20 - Docker System

    $ source ./destroy-machine.sh

<br/>

    $ vi create-machine.sh

https://bitbucket.org/sysadm-ru/docker-swarm/raw/d382b2f2b6cce1ca285dacf14807128f279b9c47/5.2/create-machine.sh

    $ source ./create-machine.sh

<br/>

    $ eval "$(docker-machine env swarm-1)"

<br/>

    $ docker system df
    TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
    Images              6                   0                   1.081GB             1.081GB (100%)
    Containers          0                   0                   0B                  0B
    Local Volumes       1                   0                   0B                  0B
    Build Cache                                                 0B                  0B

<br/>

    $ docker system df -v
    Images space usage:

    REPOSITORY                 TAG                 IMAGE ID            CREATED ago         SIZE                SHARED SIZE         UNIQUE SiZE         CONTAINERS
    nginx                      alpine              2dea9e73d89e        3 days ago ago      18MB                4.148MB             13.86MB             0
    golang                     alpine              41bf3e9b9f3c        7 days ago ago      375.6MB             4.148MB             371.5MB             0
    dockersamples/visualizer   latest              5c35feab1b02        7 weeks ago ago     153.6MB             3.966MB             149.7MB             0
    jenkins                    alpine              2ad007d33253        5 months ago ago    223.1MB             0B                  223.1MB             0
    albertogviana/names-demo   3.0.0               7b44dde204c1        8 months ago ago    19.21MB             3.966MB             15.24MB             0
    mongo                      3.2.15              52781d69f85e        8 months ago ago    299.4MB             0B                  299.4MB             0

    Containers space usage:

    CONTAINER ID        IMAGE               COMMAND             LOCAL VOLUMES       SIZE                CREATED ago         STATUS              NAMES

    Local Volumes space usage:

    VOLUME NAME         LINKS               SIZE
    my-volume           0                   0B

    Build cache usage: 0B

<br/>
    
    -- запускаю в одной консоли и смотрю, что произойдет при создании сервиса
    $ docker system events
    
    
    -- выполняю в другой консоли
    
    $ eval "$(docker-machine env swarm-1)
    
    -- создаю сервис
    $ docker service create \
      --name=visualizer \
      --publish=8000:8080/tcp \
      --constraint=node.role==manager \
      --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
      dockersamples/visualizer

<br/>

      $ docker system df
      TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
      Images              6                   1                   1.081GB             931.2MB (86%)
      Containers          1                   1                   150B                0B (0%)
      Local Volumes       1                   0                   0B                  0B
      Build Cache                                                 0B                  0B

<br/>

    $ docker service rm visualizer

    $ docker system prune -a
