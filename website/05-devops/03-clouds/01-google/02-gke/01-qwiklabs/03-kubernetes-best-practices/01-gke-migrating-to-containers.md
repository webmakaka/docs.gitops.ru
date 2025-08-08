---
layout: page
title: GKE Migrating to Containers
description: GKE Migrating to Containers
keywords: GKE Migrating to Containers
permalink: /devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/gke-migrating-to-containers/
---

# [GSP475] GKE Migrating to Containers

<br/>

Делаю:  
30.05.2019

https://www.qwiklabs.com/focuses/5155?parent=catalog

<br/>

### [Install Terraform](//docs.gitops.ru/terraform/setup//)

<br/>

### Install ApacheBench

    $ sudo apt-get install -y apache2-utils

<br/>

### Prepare

    $ git clone https://github.com/GoogleCloudPlatform/gke-migration-to-containers.git
    $ cd gke-migration-to-containers

    $ gcloud config set compute/region us-central1
    $ gcloud config set compute/zone us-central1-a

    // The setup of this demo does take up to 15 minutes
    $ make create

The make create command calls the create.sh script which performs following tasks:

1. Packages the deployable Prime-flask application, making it ready to be copied to Google Cloud Storage.
2. Creates the container image via Google Cloud Build and pushes it to the private Container Registry (GCR) for your project.
3. Generates an appropriate configuration for Terraform.
4. Executes Terraform which creates the scenarios outlined above.

<br/>

### Exploring Prime-Flask Environments

    // Run the following to go into the vm-webserver machine that has the application running on host OS:
    // Type "Y" when asked if you want to continue. Press Enter twice to not use a passphrase.
    $ gcloud compute ssh vm-webserver --zone us-central1-a

    $ ps aux
    $ exit

    // Run the following to go into the cos-vm machine, where you have docker running the container.
    $ gcloud compute ssh cos-vm --zone us-central1-a

    $ sudo docker exec -it $(sudo docker ps |awk '/prime-flask/ {print $1}') ps aux

    $ exit

<br/>

    $ gcloud container clusters get-credentials prime-server-cluster
    $ kubectl get pods

<br/>

### Validation

\$ make validate

<br/>

### Load Testing

    // IP address and port from your validation output
    // ab -c 120 -t 60  http://<IP_ADDRESS>/prime/10000
    $ ab -c 120 -t 60  http://35.244.253.26/prime/10000

    This is ApacheBench, Version 2.3 <$Revision: 1757674 $>
    Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
    Licensed to The Apache Software Foundation, http://www.apache.org/

    Benchmarking 35.244.253.26 (be patient)
    Completed 5000 requests
    Finished 7019 requests


    Server Software:        gunicorn/19.9.0
    Server Hostname:        35.244.253.26
    Server Port:            80

    Document Path:          /prime/10000
    Document Length:        48 bytes
    Concurrency Level:      120
    Time taken for tests:   60.001 seconds
    Complete requests:      7019
    Failed requests:        0
    Total transferred:      1445914 bytes
    HTML transferred:       336912 bytes
    Requests per second:    116.98 [#/sec] (mean)
    Time per request:       1025.801 [ms] (mean)
    Time per request:       8.548 [ms] (mean, across all concurrent requests)
    Transfer rate:          23.53 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:        0    0   0.8      0      10
    Processing:   123 1016  84.3   1009    1629
    Waiting:      123 1016  84.3   1008    1629
    Total:        129 1016  83.8   1009    1630

    Percentage of the requests served within a certain time (ms)
      50%   1009
      66%   1023
      75%   1033
      80%   1042
      90%   1076
      95%   1094
      98%   1211
      99%   1239
    100%   1630 (longest request)

 <br/>

    $ kubectl scale --replicas 3 deployment/prime-server

    $ ab -c 120 -t 60  http://<IP_ADDRESS>/prime/10000

По идее, количество Failed requests должно было быть > 0 а при увеличении количесвтва node их должно было стать 0. Впрочем их изначально у меня было 0.

<br/>

### Tear Down

    $ make teardown
