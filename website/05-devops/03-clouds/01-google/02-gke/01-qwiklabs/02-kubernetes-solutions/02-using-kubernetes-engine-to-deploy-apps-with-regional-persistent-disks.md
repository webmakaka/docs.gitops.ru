---
layout: page
title: Using Kubernetes Engine to Deploy Apps with Regional Persistent Disks
description: Using Kubernetes Engine to Deploy Apps with Regional Persistent Disks
keywords: Using Kubernetes Engine to Deploy Apps with Regional Persistent Disks
permalink: /devops/clouds/google/gke/qwiklabs/kubernetes-solutions/using-kubernetes-engine-to-deploy-apps-with-regional-persistent-disks/
---

# [GSP200] Using Kubernetes Engine to Deploy Apps with Regional Persistent Disks

<br/>

Делаю:  
24.05.2019

https://www.qwiklabs.com/focuses/1050?parent=catalog

<br/>

## Creating the Regional Kubernetes Engine Cluster

    $ CLUSTER_VERSION=$(gcloud container get-server-config --region us-west1 --format='value(validMasterVersions[0])')

    $ export CLOUDSDK_CONTAINER_USE_V1_API_CLIENT=false

    $ gcloud container clusters create repd \
        --cluster-version=${CLUSTER_VERSION} \
        --machine-type=n1-standard-4 \
        --region=us-west1 \
        --num-nodes=1 \
        --node-locations=us-west1-a,us-west1-b,us-west1-c

<br/>

## Deploying the App with a Regional Disk

<br/>

### Install and initialize Helm

    $ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh

    $ chmod 700 get_helm.sh

    $ ./get_helm.sh

    $ kubectl create serviceaccount tiller --namespace kube-system

    $ kubectl create clusterrolebinding tiller-cluster-rule \
        --clusterrole=cluster-admin \
        --serviceaccount=kube-system:tiller

    $ helm init --service-account=tiller

    $ until (helm version --tiller-connection-timeout=1 >/dev/null 2>&1); do echo "Waiting for tiller install..."; sleep 2; done && echo "Helm install complete"

<br/>

### Create the StorageClass

```yaml
$ kubectl apply -f - <<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: repd-west1-a-b-c
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-standard
  replication-type: regional-pd
  zones: us-west1-a, us-west1-b, us-west1-c
EOF
```

<br/>

    $ kubectl get storageclass

<br/>

### Create Persistent Volume Claims

```
$ kubectl apply -f - <<EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: data-wp-repd-mariadb-0
  namespace: default
  labels:
    app: mariadb
    component: master
    release: wp-repd
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 8Gi
  storageClassName: standard
EOF
```

<br/>

```
$ kubectl apply -f - <<EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: wp-repd-wordpress
  namespace: default
  labels:
    app: wp-repd-wordpress
    chart: wordpress-5.7.1
    heritage: Tiller
    release: wp-repd
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 200Gi
  storageClassName: repd-west1-a-b-c
EOF
```

<br/>

    $ kubectl get persistentvolumeclaims
    NAME                     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
    data-wp-repd-mariadb-0   Bound    pvc-c916bc18-7e2e-11e9-8681-42010a8a0064   8Gi        ROX            standard           15s
    wp-repd-wordpress        Bound    pvc-cea7f4e7-7e2e-11e9-8681-42010a8a0064   200Gi      ROX            repd-west1-a-b-c   5s

<br/>

### Deploy WordPress

    // Deploy the WordPress chart that is configured to use the StorageClass that you created earlier:
    $ helm install --name wp-repd \
        --set smtpHost= --set smtpPort= --set smtpUser= \
        --set smtpPassword= --set smtpUsername= --set smtpProtocol= \
        --set persistence.storageClass=repd-west1-a-b-c \
        --set persistence.existingClaim=wp-repd-wordpress \
        --set persistence.accessMode=ReadOnlyMany \
        stable/wordpress

<br/>

    $ kubectl get pods

<br/>

    // Run the following command which waits for the service load balancer's external IP address to be created:
    $ while [[ -z $SERVICE_IP ]]; do SERVICE_IP=$(kubectl get svc wp-repd-wordpress -o jsonpath='{.status.loadBalancer.ingress[].ip}'); echo "Waiting for service external IP..."; sleep 2; done; echo http://$SERVICE_IP/admin

<br/>

    // Verify that the persistent disk was created:
    $ while [[ -z $PV ]]; do PV=$(kubectl get pvc wp-repd-wordpress -o jsonpath='{.spec.volumeName}'); echo "Waiting for PV..."; sleep 2; done

<br/>

    $ kubectl describe pv $PV

<br/>

```
$ cat - <<EOF
Username: user
Password: $(kubectl get secret --namespace default wp-repd-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
EOF
```

<br/>

    $ echo http://$SERVICE_IP/admin

You now have a working deployment of WordPress that is backed by regional persistent disks in three zones.

<br/>

### Simulating a zone failure

У меня все сломалось, ничего не поднялось. Разбираться сейчас не хочется!
Контейнер не может подлючиться к MYSQL серверу.

    $ NODE=$(kubectl get pods -l app=wp-repd-wordpress -o jsonpath='{.items..spec.nodeName}')

    $ ZONE=$(kubectl get node $NODE -o jsonpath="{.metadata.labels['failure-domain\.beta\.kubernetes\.io/zone']}")

    $ IG=$(gcloud compute instance-groups list --filter="name~gke-repd-default-pool zone:(${ZONE})" --format='value(name)')

    $ echo "Pod is currently on node ${NODE}"
    Pod is currently on node gke-repd-default-pool-d4a7c03d-dhw7

    $ echo "Instance group to delete: ${IG} for zone: ${ZONE}"
    Instance group to delete: gke-repd-default-pool-d4a7c03d-grp for zone: us-west1-c

    $ kubectl get pods -l app=wp-repd-wordpress -o wide
    NAME                                READY   STATUS    RESTARTS   AGE     IP          NODE                                  NOMINATED NODE   READINESS GATES
    wp-repd-wordpress-7889b789f-zclpw   1/1     Running   0          6m15s   10.20.2.4   gke-repd-default-pool-d4a7c03d-dhw7   <none>           <none>


    // Now run the following to delete the instance group for the node where the WordPress pod is running, click Y to continue deleting:
    $ gcloud compute instance-groups managed delete ${IG} --zone ${ZONE}

Kubernetes is now detecting the failure and migrates the pod to a node in another zone.

<br/>

    // Verify that both the WordPress pod and the persistent volume migrated to the node that is in the other zone:
    $ kubectl get pods -l app=wp-repd-wordpress -o wide
    NAME                                READY   STATUS              RESTARTS   AGE   IP       NODE                                  NOMINATED NODE   READINESS GATES
    wp-repd-wordpress-7889b789f-k9sf6   0/1     ContainerCreating   0          18s   <none>   gke-repd-default-pool-ba2be98e-z4kh   <none>           <none>

<br/>

Make sure the node that is displayed is different from the node in the previous step.

<br/>

    $ echo http://$SERVICE_IP/admin
    http://34.83.219.236/admin

You have attached a regional persistent disk to a node that is in a different zone.
