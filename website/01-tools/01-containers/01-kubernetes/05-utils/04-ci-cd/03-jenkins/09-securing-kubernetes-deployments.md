---
layout: page
title: Инсталляция Jenkins в ubuntu 22.04
description: Инсталляция Jenkins в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, Jenkins, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/jenkins/securing-kubernetes-deployments/
---

# Securing Kubernetes Deployments

<br/>

**Делаю:**  
2026.01.04

<br/>

### [Устанавливаю Single Node Kubernetes Environment](/docs.k8s.ru/tools/containers/kubernetes/setup/single-node-kubernetes/)

<br/>

### Running CIS Benchmark Scans

<br/>

https://dev-sec.io/baselines/kubernetes/

<br/>

```
$ curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec
```

<br/>

```
$ cd ~/tmp
$ git clone https://github.com/dev-sec/cis-kubernetes-benchmark
```

<br/>

```
$ inspec exec ~/tmp/cis-kubernetes-benchmark
Profile Summary: 46 successful controls, 34 control failures, 42 controls skipped
Test Summary: 85 successful, 59 failures, 44 skipped
```

<br/>

```
Here is your license key: free-72b8655e-a93d-45f6-b12a-f871ef1f5d0e-3709
```

<br/>

### Kube Bench

<br/>

```
$ cd ~/tmp
$ git clone https://github.com/aquasecurity/kube-bench.git
$ cd kube-bench
$ kubectl apply -f job.yaml
```

<br/>

```
$ kubectl get pods
NAME               READY   STATUS    RESTARTS   AGE
kube-bench-hnnsx   0/1     Pending   0          51s
```

<br/>

```
$ kubectl logs kube-bench-hnnsx
```

<br/>

### Kube Hunter

<br/>

```
$ cd ~/tmp
$ git clone https://github.com/aquasecurity/kube-hunter.git
$ cd kube-hunter
$ kubectl apply -f job.yaml
```

<br/>

### Analysing Deployment Manifests with Kube-Scan

https://kubesec.io/

<br/>

```
$ cd ~/tmp
$ git clone https://github.com/wildmakaka/dso-demo.git
$ cd dso-demo/deploy/
$ docker run -i kubesec/kubesec scan /dev/stdin < dso-demo-deploy.yaml
```

<br/>

```
$ cd ~/tmp
$ git clone https://github.com/wildmakaka/dso-demo.git
$ cd dso-demo/deploy/
$ docker run -i kubesec/kubesec scan /dev/stdin < dso-demo-deploy.yaml
```

<br/>

```
stage('Scan k8s Deploy Code') {
    steps {
        container('docker-tools') {
            sh 'kubesec scan deploy/dso-demo-deploy.yaml'
        }
    }
}
```
