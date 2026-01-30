---
layout: page
title: Kubernetes Docker Registry
description: Kubernetes Docker Registry
keywords: linux, kubernetes, Docker Registry
permalink: /tools/containers/kubernetes/utils/registries/standard/
---

# Kubernetes Docker Registry

<br/>

**Делаю:**  
08.05.2023

<br/>

```
$ sudo vi /etc/hosts
```

```
192.168.49.2 private-docker-registry
```

<br/>

```
$ sudo vi /etc/docker/daemon.json
```

<br/>

```
{ "insecure-registries":["192.168.49.2:31500","192.168.49.2:31000","private-docker-registry:31500","private-docker-registry:31000"] }
```

<br/>

```
$ sudo service docker restart
```

<br/>

Инсталляция [MiniKube](/tools/containers/kubernetes/minikube/setup/)

**Испольновалась версия KUBERNETES_VERSION=v1.27.1**

<br/>

### Инсталляция пакетов с помощью helm

```
$ helm repo add stable https://charts.helm.sh/stable

$ helm repo update

$ helm install private stable/docker-registry --namespace kube-system \
  --set image.tag=2.7.1 \
  --set service.type=NodePort \
  --set service.nodePort=31500
```

<br/>

```
$ export NODE_PORT=$(kubectl get --namespace kube-system -o jsonpath="{.spec.ports[0].nodePort}" services private-docker-registry)
$ export NODE_IP=$(kubectl get nodes --namespace kube-system -o jsonpath="{.items[0].status.addresses[0].address}")
$ echo http://$NODE_IP:$NODE_PORT
```

<br/>

```
$ curl $NODE_IP:$NODE_PORT/v2/_catalog
{"repositories":[]}
```

<br/>

```
$ docker pull webmakaka/cats-app
$ docker tag webmakaka/cats-app private-docker-registry:$NODE_PORT/cats-app
$ docker push private-docker-registry:$NODE_PORT/cats-app
```

<br/>

```
$ curl private-docker-registry:$NODE_PORT/v2/_catalog
{"repositories":["cats-app"]}
```

<br/>

### Registry Web Interface

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: registry-ui-deployment
  labels:
    app: registry-ui
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: registry-ui
  template:
    metadata:
      labels:
        app: registry-ui
    spec:
      containers:
      - name: reg-ui
        image: joxit/docker-registry-ui:static
        env:
        - name: REGISTRY_URL
          value: "http://private-docker-registry:5000"
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: registry-ui
  labels:
    app: registry-ui
  namespace: kube-system
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 31000
    protocol: TCP
  selector:
    app: registry-ui
EOF
```

<br/>

```
// OK!
http://private-docker-registry:31000/
```

<br/>

```
$ docker rmi webmakaka/cats-app
$ docker rmi private-docker-registry:$NODE_PORT
$ docker pull private-docker-registry:31000/cats-app:latest
```

<!-- ```
$ kubectl port-forward --namespace kube-system \
  $(kubectl get po -n kube-system | grep private-docker-registry | \
  awk '{print $1;}') 5000:5000 &
``` -->
