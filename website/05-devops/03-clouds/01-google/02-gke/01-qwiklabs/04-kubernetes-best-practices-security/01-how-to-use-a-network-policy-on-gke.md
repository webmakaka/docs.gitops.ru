---
layout: page
title: How to Use a Network Policy on Google Kubernetes Engine
description: How to Use a Network Policy on Google Kubernetes Engine
keywords: How to Use a Network Policy on Google Kubernetes Engine
permalink: /devops/clouds/google/gke/qwiklabs/kubernetes-best-practices-security/how-to-use-a-network-policy-on-gke/
---

# [GSP480] How to Use a Network Policy on Google Kubernetes Engine

<br/>

Делаю:  
07.06.2019

https://www.qwiklabs.com/focuses/5572?parent=catalog

<br/>

### Architecture

You will define a private Kubernetes cluster. Since the cluster is private, neither the API nor the worker nodes will be accessible from the internet. Instead, you will define a bastion host and use a firewall rule to enable access to it. The bastion's IP address is defined as an authorized network for the cluster, which grants it access to the API.

Within the cluster, provision three workloads:

1. hello-server: this is a simple HTTP server with an internally-accessible endpoint
2. hello-client-allowed: this is a single pod that repeatedly attempts to access hello-server. The pod is labeled such that the Network Policy will allow it to connect to hello-server.
3. hello-client-blocked: this runs the same code as hello-client-allowed but the pod is labeled such that the Network Policy will not allow it to connect to hello-server.

<br/>

![How to Use a Network Policy on Google Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices-security/how-to-use-a-network-policy-on-gke/pic1.png 'How to Use a Network Policy on Google Kubernetes Engine'){: .center-image }

<br/>

### [Install Terraform](//docs.gitops.ru/terraform/setup//)

<br>

### Lab setup

    $ gcloud config set compute/region us-central1
    $ gcloud config set compute/zone us-central1-a

    $ git clone https://github.com/GoogleCloudPlatform/gke-network-policy-demo.git
    $ cd gke-network-policy-demo

<br/>

    // To ensure the appropriate APIs are enabled and to generate the terraform/terraform.tfvars file based on your gcloud defaults
    $ make setup-project

<br/>

    $ make tf-apply

<br/>

![How to Use a Network Policy on Google Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/kubernetes-best-practices-security/how-to-use-a-network-policy-on-gke/pic2.png 'How to Use a Network Policy on Google Kubernetes Engine'){: .center-image }

<br/>

### Validation

    // Verify that networkPolicyConfig.disabled is false and networkPolicy.provider is CALICO
    $ gcloud container clusters describe gke-demo-cluster | grep  -A2 networkPolicy


    $ kubectl get nodes

    $ gcloud compute ssh gke-demo-bastion

    $ kubectl get nodes
    NAME                                              STATUS   ROLES    AGE     VERSION
    gke-gke-demo-cluster-default-pool-33953d73-26hr   Ready    <none>   8m11s   v1.13.6-gke.5
    gke-gke-demo-cluster-default-pool-33953d73-2z71   Ready    <none>   8m11s   v1.13.6-gke.5
    gke-gke-demo-cluster-default-pool-33953d73-bl2s   Ready    <none>   8m12s   v1.13.6-gke.5

    $ kubectl apply -f ./manifests/hello-app/

    $ kubectl get pods
    NAME                                    READY   STATUS    RESTARTS   AGE
    hello-client-allowed-f9ff7b8d8-5v6rc    1/1     Running   0          13s
    hello-client-blocked-758677d884-mpwgc   1/1     Running   0          13s
    hello-server-c7665786b-xjcgh            1/1     Running   0          13s

<br>

### Confirming default access to the hello server

    $ kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=hello)
    $ kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=not-hello)

Все работает, т.к. мы еще ничего ненастраивали.

<br>

### Restricting access with a Network Policy

Now you will block access to the hello-server pod from all pods that are not labeled with app=hello.

    $ kubectl apply -f ./manifests/network-policy.yaml
    $ kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=not-hello)

Теперь нет.

<br>

### Restricting namespaces with Network Policies

    $ kubectl delete -f ./manifests/network-policy.yaml

You'll now modify the network policy to only allow traffic from a designated namespace, then you'll move the hello-allowed pod into that new namespace.

    $ kubectl create -f ./manifests/network-policy-namespaced.yaml
    $ kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=hello)


    // Finally, deploy a second copy of the hello-clients app into the new namespace.
    $ kubectl -n hello-apps apply -f ./manifests/hello-app/hello-client.yaml

    // Доступ есть
    $ kubectl logs --tail 10 -f -n hello-apps $(kubectl get pods -oname -l app=hello -n hello-apps)

Both clients are able to connect successfully because as of Kubernetes 1.10.x NetworkPolicies do not support restricting access to pods within a given namespace. You can whitelist by pod label, namespace label, or whitelist the union (i.e. OR) of both. But you cannot yet whitelist the intersection (i.e. AND) of pod labels and namespace labels.

    $ exit

<br>

### Teardown

    $ make teardown
