---
layout: page
title: Logging with Stackdriver on Kubernetes Engine
description: Logging with Stackdriver on Kubernetes Engine
keywords: Logging with Stackdriver on Kubernetes Engine
permalink: /devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/logging-with-stackdriver-on-kubernetes-engine/
---

# [GSP483] Logging with Stackdriver on Kubernetes Engine

<br/>

Делаю:  
04.05.2019

https://www.qwiklabs.com/focuses/5539?parent=catalog

<br/>

![Logging with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/logging-with-stackdriver-on-kubernetes-engine/pic1.png 'Logging with Stackdriver on Kubernetes Engine'){: .center-image }

<br/>

### [Install Terraform](//docs.gitops.ru/terraform/setup//)

<br/>

    $ git clone https://github.com/GoogleCloudPlatform/gke-logging-sinks-demo
    $ cd gke-logging-sinks-demo

<br/>

    $ gcloud config set compute/region us-central1
    $ gcloud config set compute/zone us-central1-a

<br/>

### Deployment

There are three Terraform files provided with this lab example. The first one, main.tf, is the starting point for Terraform. It describes the features that will be used, the resources that will be manipulated, and the outputs that will result. The second file is provider.tf, which indicates which cloud provider and version will be the target of the Terraform commands--in this case GCP. The final file is variables.tf, which contains a list of variables that are used as inputs into Terraform. Any variables referenced in the main.tf that do not have defaults configured in variables.tf will result in prompts to the user at runtime.

    $ make create
    $ make validate

http://35.225.188.57:8080/

<br/>

### Generating Logs

To get the URL for the application page, perform the following steps:

1. In the GCP console, from the Navigation menu, go to the Networking section and click on Network services.
2. On the default Load balancing page, click on the TCP load balancer that was set up.
3. On the Load balancer details page the top section labeled Frontend.
4. Copy the IP:Port URL value. Open a new browser and paste the URL. The browser should return a screen that looks similar to the following:

Тот же самый линк вывела команда make validate

<br/>

### Logs in Stackdriver

Stackdriver --> Logging

filter --> GKE Container > stackdriver-logging > default

![Logging with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/logging-with-stackdriver-on-kubernetes-engine/pic2.png 'Logging with Stackdriver on Kubernetes Engine'){: .center-image }

<br/>

### Viewing Log Exports

The Terraform configuration built out two Log Export Sinks. To view the sinks perform the following steps:

1. you should still be on the Stackdriver -> Logging page.

2. In the left navigation menu, click on the Exports menu option.

3. This will bring you to the Exports page. You should see two Sinks in the list of log exports.

4. You can edit/view these sinks by clicking on the context menu (three dots) to the right of a sink and selecting the Edit sink option.

5. Additionally, you could create additional custom export sinks by clicking on the Create Export option in the top of the navigation window.

![Logging with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/logging-with-stackdriver-on-kubernetes-engine/pic3.png 'Logging with Stackdriver on Kubernetes Engine'){: .center-image }

<br/>

### Logs in Cloud Storage

The Terraform configuration created a Cloud Storage Bucket named stackdriver-gke-logging- to which logs will be exported for medium to long-term archival.

Navigation menu --> Storage --> stackdriver-gke-logging-<random-Id>

![Logging with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/logging-with-stackdriver-on-kubernetes-engine/pic4.png 'Logging with Stackdriver on Kubernetes Engine'){: .center-image }

<br/>

### Logs in BigQuery

The Terraform configuration will create a BigQuery DataSet named gke_logs_dataset. This dataset will be setup to include all Kubernetes Engine related logs for the last hour.

Navigation menu --> BigQuery --> gke_logs_dataset

Query Table -->

        SELECT * FROM `qwiklabs-gcp-b7f64a64ea05a0e9.gke_logs_dataset.fluentd_gcp_scaler_20190604`

![Logging with Stackdriver on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices/logging-with-stackdriver-on-kubernetes-engine/pic5.png 'Logging with Stackdriver on Kubernetes Engine'){: .center-image }
