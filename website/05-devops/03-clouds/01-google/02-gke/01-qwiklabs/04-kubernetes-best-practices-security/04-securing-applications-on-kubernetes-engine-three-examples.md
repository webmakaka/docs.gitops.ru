---
layout: page
title: Securing Applications on Kubernetes Engine - Three Examples
description: Securing Applications on Kubernetes Engine - Three Examples
keywords: Securing Applications on Kubernetes Engine - Three Examples
permalink: /devops/clouds/google/gke/qwiklabs/kubernetes-best-practices-security/securing-applications-on-kubernetes-engine-three-examples/
---

# [GSP482] Securing Applications on Kubernetes Engine - Three Examples

<br/>

Делаю:  
08.06.2019

https://www.qwiklabs.com/focuses/5541?parent=catalog

<br/>

### Overview

In this lab you will learn how Kubernetes Engine security features can be used to grant varying levels of privilege to applications based on their particular requirements.

When configuring security, applications should be granted the smallest set of privileges that still allows them to operate correctly. When applications have more privileges than they need, they are more dangerous when compromised. In a Kubernetes cluster, these privileges can be grouped into the following broad levels:

- Host access: describes what permissions an application has on it's host node, outside of its container. This is controlled via Pod and Container security contexts, as well as app armor profiles.
- Network access: describes what other resources or workloads an application can access via the network. This is controlled with NetworkPolicies.
- Kubernetes API access: describes which API calls an application is allowed to make against. API access is controlled using the Role Based Access Control (RBAC) model via Role and RoleBinding definitions.

<br/>

### Architecture

The lab uses three applications to illustrate the scenarios described above:

Hardened Web Server (nginx)
Creates an nginx deployment whose pods have their host-level access restricted by an AppArmor profile and whose network connectivity is restricted by a NetworkPolicy.

System Daemonset (AppArmor Loader)
Creates a daemonset responsible for loading (installing) the AppArmor profile applied to the nginx pods on each node. Loading profiles requires more privileges than can be provided via Capabilities, so it's containers are given full privileges via their SecurityContexts.

Simplified Kubernetes Controller (Pod Labeler)
The pod-labeler deployment creates a single pod that watches all other pods in the default namespace and periodically labels them. This requires access to the Kubernetes API server, which is configured via RBAC using a ServiceAccount, Role, and RoleMapping.

<br/>

### [Install Terraform](//docs.gitops.ru/terraform/setup//)

<br>

### Lab setup

    $ gcloud config set compute/region us-central1
    $ gcloud config set compute/zone us-central1-a

    $ git clone https://github.com/GoogleCloudPlatform/gke-security-scenarios-demo

    $ cd gke-security-scenarios-demo

    $ make setup-project
    $ make create

<br/>

    $ gcloud compute instances list
    NAME                                                 ZONE           MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
    gke-gke-security-demo-ss-default-pool-d00fbffd-2m6z  us-central1-a  n1-standard-1               10.0.96.3                   RUNNING
    gke-gke-security-demo-ss-default-pool-d00fbffd-9xft  us-central1-a  n1-standard-1               10.0.96.4                   RUNNING
    gke-gke-security-demo-ss-default-pool-d00fbffd-tfsv  us-central1-a  n1-standard-1               10.0.96.5                   RUNNING
    gke-tutorial-bastion                                 us-central1-a  f1-micro                    10.0.96.2    35.239.16.227  RUNNING

<br/>

    $ gcloud compute ssh gke-tutorial-bastion

<br/>

### Set up Nginx

    $ kubectl apply -f manifests/nginx.yaml

```
$ cat  manifests/nginx.yaml
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Create an nginx deployment whose containers are restricted by the k8s-nginx AppArmor
# policy
apiVersion: apps/v1
# https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      annotations:
        # This specifies the AppArmor policy that should be applied
        # Any policy referenced must first be loaded on each node in the cluster
        container.apparmor.security.beta.kubernetes.io/nginx: localhost/k8s-nginx
      labels:
        app: nginx
    spec:
      # Do not mount a service account token, since these pods do not access the Kubernetes API
      automountServiceAccountToken: false
      containers:
      - name: nginx
        image: gcr.io/pso-examples/nginx-demo:v1.0.1
        ports:
        - containerPort: 8000

---
# Expose nginx as an externally accessible service on port 80
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx-lb
spec:
  externalTrafficPolicy: Cluster
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8000
  selector:
    app: nginx
  sessionAffinity: None
  type: LoadBalancer
status:
  loadBalancer: {}

---
# See https://kubernetes.io/docs/concepts/services-networking/network-policies/
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  # Name the network policy
  name: nginx-from-external
spec:

  # Define this as an ingress rule which allows us to restrict access to a set of pods.
  policyTypes:
  - Ingress

  # Defines the set of pods to which this policy applies
  # In this case, we apply the policy to pods labeled as app=nginx
  podSelector:
    matchLabels:
      app: nginx

  # Restrict ingress to port 8000 only
  ingress:
  - ports:
    - port: 8000
    from: []

```

<br/>

    $ kubectl get pods
    NAME                    READY   STATUS    RESTARTS   AGE
    nginx-64c7c7666-99mld   0/1     Blocked   0          5s
    nginx-64c7c7666-rpxg9   0/1     Blocked   0          6s
    nginx-64c7c7666-tg585   0/1     Blocked   0          6s

<br/>

You should see that while the pods have been created, they're in a Blocked state. The nginx pods are blocked because the manifest includes an AppArmor profile that doesn't exist on the nodes:

    $ kubectl describe pod -l app=nginx

<br/>

### Set up AppArmor-loader

In order to resolve this, the relevant AppArmor profile must be loaded. Because you don't know on which nodes the nginx pods will be allocated, you must deploy the AppArmor profile to all nodes. The way you'll deploy this, ensuring all nodes are covered, is via a daemonset https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/#what-is-a-daemonset.

The included apparmor-loader.yaml is a highly privileged manifest, as it needs to write a file onto each node. The contents of that file are in the configmap included in the same.

<br/>

    $ kubectl apply -f manifests/apparmor-loader.yaml

    $ cat manifests/apparmor-loader.yaml

```
# The apparmor-loader DaemonSet will create an AppArmor profile as
# defined in the configmap below.
apiVersion: v1
kind: Namespace
metadata:
  name: apparmor
---
apiVersion: v1
# https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#create-a-configmap
kind: ConfigMap
metadata:
  name: apparmor-profiles
  namespace: apparmor
data:
  # Filename k8s-nginx maps to the definition of the nginx profile.
  k8s-nginx: |-
    #include <tunables/global>

    # From https://github.com/jfrazelle/bane/blob/master/docker-nginx-sample
    profile k8s-nginx flags=(attach_disconnected,mediate_deleted) {
      #include <abstractions/base>

      network inet tcp,
      network inet udp,
      network inet icmp,

      deny network raw,

      deny network packet,

      file,
      umount,

      deny /bin/** wl,
      deny /boot/** wl,
      deny /dev/** wl,
      deny /etc/** wl,
      deny /home/** wl,
      deny /lib/** wl,
      deny /lib64/** wl,
      deny /media/** wl,
      deny /mnt/** wl,
      deny /opt/** wl,
      deny /proc/** wl,
      deny /root/** wl,
      deny /sbin/** wl,
      deny /srv/** wl,
      deny /tmp/** wl,
      deny /sys/** wl,
      deny /usr/** wl,

      audit /** w,

      /var/run/nginx.pid w,

      /usr/sbin/nginx ix,

      deny /bin/dash mrwklx,
      deny /bin/sh mrwklx,
      deny /usr/bin/top mrwklx,


      capability chown,
      capability dac_override,
      capability setuid,
      capability setgid,
      capability net_bind_service,

      deny @{PROC}/{*,**^[0-9*],sys/kernel/shm*} wkx,
      deny @{PROC}/sysrq-trigger rwklx,
      deny @{PROC}/mem rwklx,
      deny @{PROC}/kmem rwklx,
      deny @{PROC}/kcore rwklx,
      deny mount,
      deny /sys/[^f]*/** wklx,
      deny /sys/f[^s]*/** wklx,
      deny /sys/fs/[^c]*/** wklx,
      deny /sys/fs/c[^g]*/** wklx,
      deny /sys/fs/cg[^r]*/** wklx,
      deny /sys/firmware/efi/efivars/** rwklx,
      deny /sys/kernel/security/** rwklx,
    }

---
# The example DaemonSet demonstrating how the profile loader can be deployed onto a cluster to
# automatically load AppArmor profiles from a ConfigMap.

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: apparmor-loader
  # Namespace must match that of the ConfigMap.
  namespace: apparmor
spec:
  selector:
    matchLabels:
      daemon: apparmor-loader
  template:
    metadata:
      name: apparmor-loader
      labels:
        daemon: apparmor-loader
    spec:
      # Do not mount a service account token, since these pods do not access the Kubernetes API
      automountServiceAccountToken: false
      containers:
      - name: apparmor-loader
        image: gcr.io/google-containers/apparmor-loader:0.2
        args:
          # Tell the loader to pull the /profiles directory every 30 seconds.
          - -poll
          - 30s
          - /profiles
        securityContext:
          # The loader requires root permissions to actually load the profiles.
          privileged: true
        volumeMounts:
        - name: sys
          mountPath: /sys
          readOnly: true
        - name: apparmor-includes
          mountPath: /etc/apparmor.d
          readOnly: true
        - name: profiles
          mountPath: /profiles
          readOnly: true
      volumes:
      # The /sys directory must be mounted to interact with the AppArmor module.
      - name: sys
        hostPath:
          path: /sys
      # The /etc/apparmor.d directory is required for most apparmor include templates.
      - name: apparmor-includes
        hostPath:
          path: /etc/apparmor.d
      # Map in the profile data.
      - name: profiles
      # Map in the profile data.
      - name: profiles
        configMap:
          name: apparmor-profiles
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: apparmor
  name: deny-apparmor-communication
spec:
  podSelector:
    matchLabels:
  ingress:
  - from:
    - podSelector: {}
```

<br/>

    // быстрее удалить
    $ kubectl delete pods -l app=nginx

    $ kubectl get pods

    $ kubectl get services

http://35.225.76.205/

<br/>

### Set up Pod-labeler

    $ kubectl get pods --show-labels
    NAME                    READY   STATUS    RESTARTS   AGE   LABELS
    nginx-64c7c7666-84hgc   1/1     Running   0          45s   app=nginx,pod-template-hash=64c7c7666
    nginx-64c7c7666-flhlt   1/1     Running   0          45s   app=nginx,pod-template-hash=64c7c7666
    nginx-64c7c7666-tf8l8   1/1     Running   0          45s   app=nginx,pod-template-hash=64c7c7666

<br/>

    $ kubectl apply -f manifests/pod-labeler.yaml

    $ cat manifests/pod-labeler.yaml

```
# This manifest deploys a sample application that accesses the Kubernetes API
# It also create a Role RoleBinding and ServiceAccount so you can manage
# API access with RBAC.

# Create a custom role in the default namespace that grants access to
# list pods
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pod-labeler
  namespace: default
rules:
- apiGroups: [""] # "" refers to the core API group
  resources: ["pods"]
  verbs: ["list","patch"]

---
# Create a ServiceAccount that will be bound to the role above
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-labeler
  namespace: default

---
# Binds the pod-labeler ServiceAccount to the pod-labeler Role
# Any pod using the pod-labeler ServiceAccount will be granted
# API permissions based on the pod-labeler role.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pod-labeler
  namespace: default
subjects:
  # List of service accounts to bind
- kind: ServiceAccount
  name: pod-labeler
roleRef:
  # The role to bind
  kind: Role
  name: pod-labeler
  apiGroup: rbac.authorization.k8s.io

---
# Deploys a single pod to run the pod-labeler code
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-labeler
  namespace: default
spec:
  replicas: 1

  # Control any pod labeled with app=pod-labeler
  selector:
    matchLabels:
      app: pod-labeler

  template:
    # Ensure created pods are labeled with app=pod-labeler to match the deployment selector
    metadata:
      labels:
        app: pod-labeler

    spec:
      serviceAccount: pod-labeler

      # Pod-level security context to define the default UID and GIDs under which to
      # run all container processes. We use 9999 for all IDs since it is unprivileged
      # and known to be unallocated on the node instances.
      securityContext:
        runAsUser: 9999
        runAsGroup: 9999
        fsGroup: 9999

      containers:
      - image: gcr.io/pso-examples/pod-labeler:0.1.5
        name: pod-labeler

```

<br/>

    $ kubectl get pods --show-labels
    NAME                         READY   STATUS    RESTARTS   AGE     LABELS
    nginx-64c7c7666-84hgc        1/1     Running   0          2m10s   app=nginx,pod-template-hash=64c7c7666,updated=1559958391.6
    nginx-64c7c7666-flhlt        1/1     Running   0          2m10s   app=nginx,pod-template-hash=64c7c7666,updated=1559958391.61
    nginx-64c7c7666-tf8l8        1/1     Running   0          2m10s   app=nginx,pod-template-hash=64c7c7666,updated=1559958391.62
    pod-labeler-5df9db46-vz6tz   1/1     Running   0          59s     app=pod-labeler,pod-template-hash=5df9db46,updated=1559958391.63

And you'll see that the pods have an additional "updated=..." label. You may have to run this command a couple of times to see the new label.
