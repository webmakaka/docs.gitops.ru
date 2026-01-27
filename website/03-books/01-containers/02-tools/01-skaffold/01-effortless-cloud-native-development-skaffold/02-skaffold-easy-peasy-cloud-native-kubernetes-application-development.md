---
layout: page
title: Building CI/CD Systems Using Tekton - Skaffold – Easy-Peasy Cloud-Native Kubernetes Application Development
description: Building CI/CD Systems Using Tekton - Skaffold – Easy-Peasy Cloud-Native Kubernetes Application Development
keywords: books, ci-cd, tekton, Skaffold – Easy-Peasy Cloud-Native Kubernetes Application Development
permalink: /books/containers/kubernetes/tools/skaffold/skaffold-easy-peasy-cloud-native-kubernetes-application-development/
---

# Chapter 3. Skaffold – Easy-Peasy Cloud-Native Kubernetes Application Development

<br/>

**Делаю:**  
2025.12.14

<br/>

```
$ export \
    PROFILE=${USER}-minikube
```

<br/>

```
$ skaffold config set --kube-context ${PROFILE} local-cluster true
```

<br/>

```
$ cd ~/tmp/
$ git clone https://github.com/webmakaka/Effortless-Cloud-Native-App-Development-Using-Skaffold
```

<br/>

```
$ cd ~/tmp/Effortless-Cloud-Native-App-Development-Using-Skaffold/Chapter03/
```

<br/>

```
$ skaffold dev
```

<br/>

```
$ kubectl get all
```

<br/>

```
$ kubectl get svc
NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
kubernetes              ClusterIP   10.96.0.1        <none>        443/TCP          54m
skaffold-introduction   NodePort    10.102.184.144   <none>        8080:30087/TCP   3m30s
```

<br/>

```
$ export PROFILE=${USER}-minikube
$ echo ${PROFILE}
```

<br/>

```
$ echo $(minikube --profile ${PROFILE} ip)
$ export MINIKUBE_IP=$(minikube --profile ${PROFILE} ip)
$ echo ${MINIKUBE_IP}
```

<br/>

```
// Одно значение д.б. но выводятся все. Нужно смотреть код, что не так
$ curl -X GET "${MINIKUBE_IP}:30476/states?name=Karnataka" \
  | jq
```

<br/>

```
// Все данные
$ curl $(minikube --profile ${PROFILE} ip):30476/states \
  | jq
```

<br/>

```
[
  {
    "name": "Andra Pradesh",
    "capital": "Hyderabad"
  },
  {
    "name": "Arunachal Pradesh",
    "capital": "Itangar"
  },
  {
    "name": "Assam",
    "capital": "Dispur"
  },
  {
    "name": "Bihar",
    "capital": "Patna"
  },
  {
    "name": "Chhattisgarh",
    "capital": "Raipur"
  },
  {
    "name": "Goa",
    "capital": "Panaji"
  },
  {
    "name": "Gujarat",
    "capital": "Gandhinagar"
  },
  {
    "name": "Haryana",
    "capital": "Chandigarh"
  },
  {
    "name": "Himachal Pradesh",
    "capital": "Shimla"
  },
  {
    "name": "Jharkhand",
    "capital": "Ranchi"
  },
  {
    "name": "Karnataka",
    "capital": "Bengaluru"
  },
  {
    "name": "Kerala",
    "capital": "Thiruvananthapuram"
  },
  {
    "name": "Madhya Pradesh",
    "capital": "Bhopal"
  },
  {
    "name": "Maharashtra",
    "capital": "Mumbai"
  },
  {
    "name": "Manipur",
    "capital": "Imphal"
  },
  {
    "name": "Meghalaya",
    "capital": "Shillong"
  },
  {
    "name": "Mizoram",
    "capital": "Aizawl"
  },
  {
    "name": "Nagaland",
    "capital": "Kohima"
  },
  {
    "name": "Orissa",
    "capital": "Bhubaneshwar"
  },
  {
    "name": "Rajasthan",
    "capital": "Jaipur"
  },
  {
    "name": "Sikkim",
    "capital": "Gangtok"
  },
  {
    "name": "Tamil Nadu",
    "capital": "Chennai"
  },
  {
    "name": "Telangana",
    "capital": "Hyderabad"
  },
  {
    "name": "Tripura",
    "capital": "Agartala"
  },
  {
    "name": "Uttarakhand",
    "capital": "Dehradun"
  },
  {
    "name": "Uttar Pradesh",
    "capital": "Lucknow"
  },
  {
    "name": "West Bengal",
    "capital": "Kolkata"
  },
  {
    "name": "Punjab",
    "capital": "Chandigarh"
  }
]
```
