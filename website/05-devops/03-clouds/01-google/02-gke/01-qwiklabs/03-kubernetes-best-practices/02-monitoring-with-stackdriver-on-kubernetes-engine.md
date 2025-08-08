---
layout: page
title: Monitoring with Stackdriver on Kubernetes Engine
description: Monitoring with Stackdriver on Kubernetes Engine
keywords: Monitoring with Stackdriver on Kubernetes Engine
permalink: /devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/monitoring-with-stackdriver-on-kubernetes-engine/
---

# [GSP497] Monitoring with Stackdriver on Kubernetes Engine

<br/>

Делаю:  
04.05.2019

https://www.qwiklabs.com/focuses/5157?parent=catalog

<br/>

### Overview

Stackdriver Kubernetes Monitoring is a new Stackdriver feature that more tightly integrates with GKE to better show you key stats about your cluster and the workloads and services running in it. Included in the new feature is functionality to import, as native Stackdriver metrics, metrics from pods with Prometheus endpoints. This allows you to use Stackdriver native alerting functionality with your Prometheus metrics without any additional workload.

<br/>

### Architecture

This lab will create a Kubernetes Engine cluster that has a sample application deployed to it. The logging and metrics for the cluster are loaded into Stackdriver Logging by default. In the tutorial a Stackdriver Monitoring account will be setup to view the metrics captured.

![Monitoring with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/monitoring-with-stackdriver-on-kubernetes-engine/pic1.png 'Monitoring with Stackdriver on Kubernetes Engine'){: .center-image }

<br/>

### [Install Terraform](//docs.gitops.ru/terraform/setup//)

<br/>

    $ gcloud config set compute/region us-central1
    $ gcloud config set compute/zone us-central1-a

    $ git clone https://github.com/GoogleCloudPlatform/gke-monitoring-tutorial.git

    $ cd gke-monitoring-tutorial

<br/>

### Configure Authentication

    $ gcloud auth application-default login

Copy the URL that is returned in the output, then paste it into a new browser window.

Select the login credentials for this lab, and click Allow.

Copy the code provided and paste it into the Cloud Shell prompt.

<br/>

### Create Stackdriver workspace

GCP --> Monitoring

![Monitoring with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/monitoring-with-stackdriver-on-kubernetes-engine/pic2.png 'Monitoring with Stackdriver on Kubernetes Engine'){: .center-image }

Нужно дождаться когда прогрузится, прежде чем переходить на следующий шаг. Первый раз не дождался. Была ошибка. (Впрочем может быть не из-за этого)

<br/>

### Deploying the cluster

    $ make create

This will:

1. Read your project & zone configuration to generate a couple config files:
   ./terraform/terraform.tfvars for Terraform variables
   ./manifests/prometheus-service-sed.yaml for the Prometeus policy to be created in Stackdriver
2. Run terraform init to prepare Terraform to create the infrastructure
3. Run terraform apply to actually create the infrastructure & Stackdriver alert policy

If you need to override any of the defaults in the Terraform variables file, simply replace the desired value(s) to the right of the equals sign(s). Be sure your replacement values are still double-quoted.

If no errors are displayed then after a few minutes you should see your Kubernetes Engine cluster in the GCP Console.

<br/>

    $ make validate

<br/>

![Monitoring with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/monitoring-with-stackdriver-on-kubernetes-engine/pic3.png 'Monitoring with Stackdriver on Kubernetes Engine'){: .center-image }

<br/>

    $ kubectl get pods
    NAME                          READY   STATUS    RESTARTS   AGE
    prometheus-8466bbdffc-9jnfc   1/1     Running   0          5m10s

<br/>

### Teardown

    $ make teardown
