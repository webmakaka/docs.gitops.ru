---
layout: page
title: Tracing with Stackdriver on Kubernetes Engine
description: Tracing with Stackdriver on Kubernetes Engine
keywords: Tracing with Stackdriver on Kubernetes Engine
permalink: /devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/tracing-with-stackdriver-on-kubernetes-engine/
---

# [GSP484] Tracing with Stackdriver on Kubernetes Engine

<br/>

Делаю:  
04.05.2019

https://www.qwiklabs.com/focuses/5159?parent=catalog

![Tracing with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/tracing-with-stackdriver-on-kubernetes-engine/pic1.png 'Tracing with Stackdriver on Kubernetes Engine'){: .center-image }

<br/>

### [Install Terraform](//docs.gitops.ru/terraform/setup//)

<br/>

    $ git clone https://github.com/GoogleCloudPlatform/gke-tracing-demo
    $ cd gke-tracing-demo

<br/>

    $ gcloud config set compute/region us-central1
    $ gcloud config set compute/zone us-central1-a

<br/>

### Running Terraform

    $ cd terraform
    $ terraform init
    $ ../scripts/generate-tfvars.sh
    $ gcloud config list

<br/>

### Deployment

    $ terraform plan
    $ terraform apply

<br/>

### Create Stackdriver workspace

GCP --> Monitoring

<br/>

### Deploy demo application

    $ kubectl apply -f tracing-demo-deployment.yaml

    // не отработала
    $ echo http://$(kubectl get svc tracing-demo -n default -ojsonpath='{.status.loadBalancer.ingress[0].ip}')
    http://35.226.121.116

    http://35.226.121.116/?string=CustomMessage

<br/>

Stackdriver --> Trace > Trace list.

![Tracing with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/tracing-with-stackdriver-on-kubernetes-engine/pic2.png 'Tracing with Stackdriver on Kubernetes Engine'){: .center-image }

<br/>

### Pulling Pub/Sub Messages

    $ gcloud pubsub subscriptions pull --auto-ack --limit 10 tracing-demo-cli

    ┌───────────────┬─────────────────┬────────────┐
    │      DATA     │    MESSAGE_ID   │ ATTRIBUTES │
    ├───────────────┼─────────────────┼────────────┤
    │ CustomMessage │ 570469273059920 │            │
    │ CustomMessage │ 570470527732853 │            │
    │ Hello World   │ 570470803702509 │            │
    └───────────────┴─────────────────┴────────────┘

<br/>

### Monitoring and Logging

Stackdriver --> Resources > Metrics Explorer --> GKE Container

![Tracing with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/tracing-with-stackdriver-on-kubernetes-engine/pic3.png 'Tracing with Stackdriver on Kubernetes Engine'){: .center-image }

![Tracing with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/tracing-with-stackdriver-on-kubernetes-engine/pic4.png 'Tracing with Stackdriver on Kubernetes Engine'){: .center-image }
