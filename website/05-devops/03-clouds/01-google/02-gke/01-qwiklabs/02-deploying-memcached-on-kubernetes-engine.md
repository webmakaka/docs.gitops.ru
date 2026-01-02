---
layout: page
title: Deploying Memcached on Kubernetes Engine
description: Deploying Memcached on Kubernetes Engine
keywords: Deploying Memcached on Kubernetes Engine
permalink: /devops/clouds/google/gke/qwiklabs/deploying-memcached-on-kubernetes-engine/
---

# [GSP116] Deploying Memcached on Kubernetes Engine

<br/>

Делаю:  
01.08.2019

https://www.qwiklabs.com/focuses/615?parent=catalog

<br/>

## Overview

In this lab you'll learn how to deploy a cluster of distributed Memcached servers on Kubernetes Engine using Kubernetes, Helm, and Mcrouter. Memcached is one of the most popular open source, multi-purpose caching systems. It usually serves as a temporary store for frequently used data to speed up web applications and lighten database loads.

<br/>

### Objectives

- Learn about some characteristics of Memcached's distributed architecture.
- Deploy a Memcached service to Kubernetes Engine using Kubernetes and Helm.
- Deploy Mcrouter, an open source Memcached proxy, to improve the system's performance.

<br/>

### Memcached's characteristics

Memcached has two main design goals:

- Simplicity: Memcached functions like a large hash table and offers a simple API to store and retrieve arbitrarily shaped objects by key.
- Speed: Memcached holds cache data exclusively in random-access memory (RAM), making data access extremely fast.

Memcached is a distributed system that allows its hash table capacity to scale horizontally across a pool of servers. Each Memcached server operates in complete isolation from the other servers in the pool. Therefore, the routing and load balancing between the servers must be done at the client level. Memcached clients apply a consistent hashing scheme to appropriately select the target servers. This scheme guarantees the following conditions:

- The same server is always selected for the same key.
- Memory usage is evenly balanced between the servers.
- A minimum number of keys are relocated when the pool of servers is reduced or expanded.

The following diagram illustrates at a high level the interaction between a Memcached client and a distributed pool of Memcached servers.

![Deploying Memcached on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/deploying-memcached-on-kubernetes-engine/pic1.png 'Deploying Memcached on Kubernetes Engine'){: .center-image }

<br/>

## Deploying a Memcached service

A simple way to deploy a Memcached service to Kubernetes Engine is to use a Helm chart.

In Cloud Shell, create a new Kubernetes Engine cluster of three nodes:

    $ gcloud container clusters create demo-cluster --num-nodes 3 --zone us-central1-f

This deployment will take between five and ten minutes to complete. You may see a warning about default scopes that you can safely ignore as it has no impact on this lab.

<br/>

    // Download the Helm binary archive:
    $ cd ~
    $ wget https://kubernetes-helm.storage.googleapis.com/helm-v2.6.0-linux-amd64.tar.gz
    $ mkdir helm-v2.6.0
    $ tar zxfv helm-v2.6.0-linux-amd64.tar.gz -C helm-v2.6.0

    // Add the Helm binary's directory to your PATH environment variable
    $ export PATH="$(echo ~)/helm-v2.6.0/linux-amd64:$PATH"

This command makes the Helm binary discoverable from any directory during the current Cloud Shell session. To make this configuration persist across multiple sessions, add the command to your Cloud Shell user's ~/.bashrc file.

<br/>

    // Create a service account with the cluster admin role for Tiller, the Helm server:
    $ kubectl create serviceaccount --namespace kube-system tiller
    $ kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

<br/>

    // Initialize Tiller in your cluster, and update information of available charts:
    $ helm init --service-account tiller
    $ helm repo update

<br/>

    // Install a new Memcached Helm chart release with three replicas, one for each node
    $ helm install stable/memcached --name mycache --set replicaCount=3

<br/>

The Memcached Helm chart uses a StatefulSet controller. One benefit of using a StatefulSet controller is that the pods' names are ordered and predictable. In this case, the names are mycache-memcached-{0..2}. This ordering makes it easier for Memcached clients to reference the servers.

    $ kubectl get pods
    NAME                  READY   STATUS    RESTARTS   AGE
    mycache-memcached-0   1/1     Running   0          40s
    mycache-memcached-1   1/1     Running   0          28s
    mycache-memcached-2   1/1     Running   0          21s

<br/>

### Discovering Memcached service endpoints

The Memcached Helm chart uses a headless service. A headless service exposes IP addresses for all of its pods so that they can be individually discovered.

Verify that the deployed service is headless:

    $ kubectl get service mycache-memcached -o jsonpath="{.spec.clusterIP}" ; echo

The output None confirms that the service has no clusterIP and that it is therefore headless.

In this lab the service creates a DNS record for a hostname of the form:

    [SERVICE_NAME].[NAMESPACE].svc.cluster.local

In this lab the service name is mycache-memcached. Because a namespace was not explicitly defined, the default namespace is used, and therefore the entire hostname is mycache-memcached.default.svc.cluster.local. This hostname resolves to a set of IP addresses and domains for all three pods exposed by the service. If, in the future, some pods get added to the pool, or old ones get removed, kube-dns will automatically update the DNS record.

It is the client's responsibility to discover the Memcached service endpoints. To do that:

Retrieve the endpoints' IP addresses:

    $ kubectl get endpoints mycache-memcached
    NAME                ENDPOINTS                                         AGE
    mycache-memcached   10.40.0.9:11211,10.40.1.3:11211,10.40.2.5:11211   2m43s

Notice that each Memcached pod has a separate IP address. These IP addresses might differ for your own server instances. Each pod listens to port 11211, which is Memcached's default port.

Test the deployment by opening a telnet session with one of the running Memcached servers on port 11211:

    $ kubectl run -it --rm alpine --image=alpine:3.6 --restart=Never telnet mycache-memcached-0.mycache-memcached.default.svc.cluster.local 11211

This will open a session to the telnet interface with no obvious prompt. Don't mind the If you don't see a command prompt, try pressing enter--you can start plugging in commands right away (even if the formatting looks a little off.)

At the telnet prompt run these commands using the Memcached ASCII protocol to confirm that telnet is actually connected to a Memcached server instance. As this is a telnet session, enter each set of commands and wait for the response to avoid getting commands and responses mixed on the console.

Store the key:

    set mykey 0 0 5
    hello

Press Enter and you will see the response:

    STORED

Retrieve the key:

    get mykey

Press Enter and you will see the response:

    VALUE mykey 0 5
    hello
    END

Quit the telnet session:

    quit

Press Enter to close the session if it does not automatically exit.

<br/>

## Implementing the service discovery logic

You are now ready to implement the basic service discovery logic shown in the following diagram.

![Deploying Memcached on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/deploying-memcached-on-kubernetes-engine/pic2.png 'Deploying Memcached on Kubernetes Engine'){: .center-image }

At a high level, the service discovery logic consists of the following steps:

1. The application queries kube-dns for the DNS record of mycache-memcached.default.svc.cluster.local.
2. The application retrieves the IP addresses associated with that record.
3. The application instantiates a new Memcached client and provides it with the retrieved IP addresses.
4. The Memcached client's integrated load balancer connects to the Memcached servers at the given IP addresses.

<br/>

### Implement the service discovery logic

You now implement this service discovery logic by using Python.

Deploy a new Python-enabled pod in your cluster and start a shell session inside the pod:

    $ kubectl run -it --rm python --image=python:3.6-alpine --restart=Never sh

Once you get a shell prompt (/ #) install the pymemcache library:

    pip install pymemcache

Start a Python interactive console by running the python command.

    python

```
import socket
from pymemcache.client.hash import HashClient
_, _, ips = socket.gethostbyname_ex('mycache-memcached.default.svc.cluster.local')
servers = [(ip, 11211) for ip in ips]
client = HashClient(servers, use_pooling=True)
client.set('mykey', 'hello')
client.get('mykey')
```

The output that results from the last command:

    b'hello'

The b prefix signifies a bytes literal, which is the format in which Memcached stores data.

Exit the Python console:

    exit()

Exit the pod's shell session by pressing Control+D.

<br/>

## Enabling connection pooling

As your caching needs grow, and the pool scales up to dozens, hundreds, or thousands of Memcached servers, you might run into some limitations. In particular, the large number of open connections from Memcached clients might place a heavy load on the servers, as the following diagram shows.

![Deploying Memcached on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/deploying-memcached-on-kubernetes-engine/pic3.png 'Deploying Memcached on Kubernetes Engine'){: .center-image }

To reduce the number of open connections, you must introduce a proxy to enable connection pooling, as in the following diagram.

![Deploying Memcached on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/deploying-memcached-on-kubernetes-engine/pic4.png 'Deploying Memcached on Kubernetes Engine'){: .center-image }

Mcrouter (pronounced "mick router"), a powerful open source Memcached proxy, enables connection pooling. Integrating Mcrouter is seamless, because it uses the standard Memcached ASCII protocol. To a Memcached client, Mcrouter behaves like a normal Memcached server. To a Memcached server, Mcrouter behaves like a normal Memcached client.

<br/>

### Deploy Mcrouter

To deploy Mcrouter, run the following commands in Cloud Shell.

Delete the previously installed mycache Helm chart release:

    $ helm delete mycache --purge

Deploy new Memcached pods and Mcrouter pods by installing a new Mcrouter Helm chart release:

    $ helm install stable/mcrouter --name=mycache --set memcached.replicaCount=3

Check the status of the sample application deployment:

    $ kubectl get pods
    NAME                     READY   STATUS      RESTARTS   AGE
    mycache-mcrouter-4jjrw   1/1     Running     0          55s
    mycache-mcrouter-8s29s   1/1     Running     0          55s
    mycache-mcrouter-n6xpz   1/1     Running     0          55s
    mycache-memcached-0      1/1     Running     0          55s
    mycache-memcached-1      1/1     Running     0          24s
    mycache-memcached-2      1/1     Running     0          11s
    python                   0/1     Completed   0          3m42s

Repeat the kubectl get pods command periodically until all 3 of the mycache-mcrouter pods report a STATUS of Running and a READY state of 1/1. This may take a couple of minutes. Three mycache-memcached pods are also started by this command and they will initialize first, however you must wait for the mycache-mcrouter pods to be fully ready before proceeding or the pod ip-addresses will not be configured.

Once you see the READY state of 1/1 the mycache-mcrouter proxy pods are now ready to accept requests from client applications.

Test this setup by connecting to one of the proxy pods. Use the telnet command on port 5000, which is Mcrouter's default port.

    $ MCROUTER_POD_IP=$(kubectl get pods -l app=mycache-mcrouter -o jsonpath="{.items[0].status.podIP}")

    $ kubectl run -it --rm alpine --image=alpine:3.6 --restart=Never telnet $MCROUTER_POD_IP 5000

This will open a session to the telnet interface with no obvious prompt. It'll be ready right away.

In the telnet prompt, run these commands to test the Mcrouter configuration:

Store a key:

    set anotherkey 0 0 15
    Mcrouter is fun

Press Enter and you will see the response:

    STORED

Retrieve the key:

    get anotherkey

Press Enter and you will see the response:

```
VALUE anotherkey 0 15
Mcrouter is fun
END
```

Quit the telnet session.

    quit

You have now deployed a proxy that enables connection pooling.

<br/>

## Reducing latency

To increase resilience, it is common practice to use a cluster with multiple nodes. This lab uses a cluster with three nodes. However, using multiple nodes also brings the risk of increased latency caused by heavier network traffic between nodes.

<br/>

### Colocating proxy pods

You can reduce the latency risk by connecting client application pods only to a Memcached proxy pod that is on the same node. The following diagram illustrates this configuration which shows the topology for the interactions between application pods, Mcrouter pods, and Memcached pods across a cluster of three nodes.

![Deploying Memcached on Kubernetes Engine](/img/devops/clouds/google/gke/qwiklabs/deploying-memcached-on-kubernetes-engine/pic5.png 'Deploying Memcached on Kubernetes Engine'){: .center-image }

In a production environment, you would create this configuration as follows:

1. Ensure that each node contains one running proxy pod. A common approach is to deploy the proxy pods with a DaemonSet controller. As nodes are added to the cluster, new proxy pods are automatically added to them. As nodes are removed from the cluster, those pods are garbage-collected. In this lab, the Mcrouter Helm chart that you deployed earlier uses a DaemonSet controller by default. So this step is already complete.

2. Set a hostPort value in the proxy container's Kubernetes parameters to make the node listen to that port and redirect traffic to the proxy. In this lab, the Mcrouter Helm chart uses this parameter by default for port 5000. So this step is also already complete.

3. Expose the node name as an environment variable inside the application pods by using the spec.env entry and selecting the spec.nodeName fieldRef value. See more about this method in the Kubernetes documentation. You will perform this step in the next section.

<br/>

### Configure Application Pods to Expose the Kubernetes Node Name as an Environment Variable

Deploy some sample application pods with the NODE_NAME environment variable configured to contain the Kubernetes node name by entering the following in the Google Cloud Shell:

<br/>

```yaml
cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: sample-application-py
spec:
  replicas: 5
  template:
    metadata:
      labels:
        app: sample-application-py
    spec:
      containers:
        - name: python
          image: python:3.6-alpine
          command: [ "sh", "-c"]
          args:
          - while true; do sleep 10; done;
          env:
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
EOF
```

<br/>

Enter the following command to check the status of the sample application-py deployment:

    $ kubectl get pods
    NAME                                     READY   STATUS      RESTARTS   AGE
    mycache-mcrouter-4jjrw                   1/1     Running     0          5m59s
    mycache-mcrouter-8s29s                   1/1     Running     0          5m59s
    mycache-mcrouter-n6xpz                   1/1     Running     0          5m59s
    mycache-memcached-0                      1/1     Running     0          5m59s
    mycache-memcached-1                      1/1     Running     0          5m28s
    mycache-memcached-2                      1/1     Running     0          5m15s
    python                                   0/1     Completed   0          8m46s
    sample-application-py-5c8554d54c-95n2l   1/1     Running     0          73s
    sample-application-py-5c8554d54c-h9w4d   1/1     Running     0          73s
    sample-application-py-5c8554d54c-pqgkw   1/1     Running     0          73s
    sample-application-py-5c8554d54c-wwqxl   1/1     Running     0          73s
    sample-application-py-5c8554d54c-zfb8w   1/1     Running     0          73s

Repeat the kubectl get pods command until all 5 of the sample-application pods report a Status of Running and a READY state of 1/1. This may take a minute or two.

Verify that the node name is exposed to each pod, by looking inside one of the sample application pods:

    $ POD=$(kubectl get pods -l app=sample-application-py -o jsonpath="{.items[0].metadata.name}")

    $ kubectl exec -it $POD -- sh -c 'echo $NODE_NAME'

You will see the node's name in the output in the following form:

    gke-demo-cluster-default-pool-77337a9c-7nd6

<br/>

### Connecting the pods

The sample application pods are now ready to connect to the Mcrouter pod that runs on their respective mutual nodes at port 5000, which is Mcrouter's default port.

Use the node name that was outputted when you ran the previous command (kubectl exec -it $POD -- sh -c 'echo $NODE_NAME) and use it in the following to initiate a connection for one of the pods by opening a telnet session:

    $ kubectl run -it --rm alpine --image=alpine:3.6 --restart=Never telnet gke-demo-cluster-default-pool-77337a9c-7nd6 5000

Remember, telnet prompts aren't obvious, so you can start plugging commands in right away. In the telnet prompt, run these commands:

    $ get anotherkey

This command outputs the value of this key that we set on the memcached cluster using Mcrouter in the previous section:

    VALUE anotherkey 0 15
    Mcrouter is fun
    END

Quit the telnet session.

    quit

Finally, to demonstrate using code, open up a shell on one of the application nodes and prepare an interactive Python session.

    $ kubectl exec -it $POD -- sh
    / # pip install pymemcache
    / # python

On the Python command line, enter the following Python commands that set and retrieve a key value using the NODE_NAME environment variable to locate the Mcrouter node from the application's environment. This variable was set in the sample application configuration.

```
import os
from pymemcache.client.base import Client

NODE_NAME = os.environ['NODE_NAME']
client = Client((NODE_NAME, 5000))
client.set('some_key', 'some_value')
result = client.get('some_key')
result

```

You will see output similar to:

    b'some_value'

Finally retrieve the key value you set earlier:

    >>> result = client.get('anotherkey')

    >>> result

You will see output similar to:

    b'Mcrouter is fun'

Exit the Python interactive console

    exit()

Then press Control+D to close the shell to the sample application pod.
