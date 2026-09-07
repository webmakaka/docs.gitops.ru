---
layout: page
title: Terraform Google Cloud
description: Terraform Google Cloud
keywords: Terraform Google Cloud
permalink: /tools/terraform/google-cloud/
---

# Terraform Google Cloud

Делаю:  
04.05.2019

В облаках google

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing, popular service providers as well as custom in-house solutions.

Configuration files describe to Terraform the components needed to run a single application or your entire datacenter. Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the described infrastructure. As the configuration changes, Terraform is able to determine what changed and create incremental execution plans which can be applied.

The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well as high-level components such as DNS entries, SaaS features, etc.

Key Features

Infrastructure as Code

Infrastructure is described using a high-level configuration syntax. This allows a blueprint of your datacenter to be versioned and treated as you would any other code. Additionally, infrastructure can be shared and re-used.

Execution Plans

Terraform has a "planning" step where it generates an execution plan. The execution plan shows what Terraform will do when you call apply. This lets you avoid any surprises when Terraform manipulates infrastructure.

Resource Graph

Terraform builds a graph of all your resources, and parallelizes the creation and modification of any non-dependent resources. Because of this, Terraform builds infrastructure as efficiently as possible, and operators get insight into dependencies in their infrastructure.

Change Automation

Complex changesets can be applied to your infrastructure with minimal human interaction. With the previously mentioned execution plan and resource graph, you know exactly what Terraform will change and in what order, avoiding many possible human errors.

<br/>

### [Install Terraform](/tools/terraform/setup/)

<br/>

### Build Infrastructure

    $ export GOOGLE_PROJECT=$(gcloud config get-value project)

    $ echo ${GOOGLE_PROJECT}

    $ vi instance.tf

```
resource "google_compute_instance" "default" {
  project      = "<GOOGLE_PROJECT>"
  name         = "terraform"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}
```

<br/>

    $ terraform init
    $ terraform plan
    $ terraform apply
    $ terraform show

<br/>

### Deploy Kubernetes Load Balancer Service with Terraform

    $ git clone https://github.com/GoogleCloudPlatform/terraform-google-examples.git

    $ cd terraform-google-examples/example-gke-k8s-service-lb

    $ cat main.tf
    $ cat k8s.tf

<br/>

```
$ cat > terraform.tfvars << 'EOF'
gke_username = "admin"
gke_password = "$(openssl rand -base64 16)"
EOF
```

<br/>

    $ terraform init
    $ terraform plan -out=tfplan
    $ terraform apply tfplan

<br/>

    $ gcloud container clusters get-credentials tf-gke-k8s --zone us-west1-b

    $ kubectl get nodes
    NAME                                        STATUS   ROLES    AGE     VERSION
    gke-tf-gke-k8s-default-pool-89218951-28x4   Ready    <none>   9m16s   v1.13.6-gke.5
    gke-tf-gke-k8s-default-pool-89218951-nxz8   Ready    <none>   9m16s   v1.13.6-gke.5
    gke-tf-gke-k8s-default-pool-89218951-whdp   Ready    <none>   9m16s   v1.13.6-gke.5

<br/>

    $ kubectl get nodes --namespace staging
    NAME                                        STATUS   ROLES    AGE   VERSION
    gke-tf-gke-k8s-default-pool-89218951-28x4   Ready    <none>   14m   v1.13.6-gke.5
    gke-tf-gke-k8s-default-pool-89218951-nxz8   Ready    <none>   14m   v1.13.6-gke.5
    gke-tf-gke-k8s-default-pool-89218951-whdp   Ready    <none>   14m   v1.13.6-gke.5

<br/>

    $ kubectl get svc --namespace staging
    NAME    TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
    nginx   LoadBalancer   10.7.243.246   35.199.150.232   80:32719/TCP   13m

<br/>

http://35.199.150.232/

<br/>

### HTTPS Content-Based Load Balancer with Terraform

https://www.qwiklabs.com/focuses/1206?parent=catalog

    $ terraform version
    Terraform v0.12.9

    $ git clone https://github.com/GoogleCloudPlatform/terraform-google-lb-http.git

    $ cd ~/terraform-google-lb-http/examples/multi-backend-multi-mig-bucket-https-lb

    $ terraform init

    $ export GOOGLE_PROJECT=$(gcloud config get-value project)

    $ terraform plan -out=tfplan -var project=${GOOGLE_PROJECT}

    $ terraform apply tfplan

    $ EXTERNAL_IP=$(terraform output | grep load-balancer-ip | cut -d = -f2 | xargs echo -n)

    $ echo https://${EXTERNAL_IP}
