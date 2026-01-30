---
layout: page
title: Инсталляция Harbor
description: Инсталляция Harbor
keywords: gitops, docker, docker-compose, инсталляция, Docker Registry в Linux
permalink: /tools/containers/kubernetes/utils/registries/harbor/setup/
---

# Инсталляция Harbor

https://goharbor.io/

<br/>

**Делаю:**  
2026.01.30

<br/>

```
$ sudo vi /etc/docker/daemon.json
```

<br/>

```
{ "insecure-registries":["harbor.192.168.49.2.nip.io"] }
```

<br/>

```
$ sudo service docker restart
```

<br/>

Инсталляция [MiniKube](/tools/containers/kubernetes/minikube/setup/)

**Испольновалась версия KUBERNETES_VERSION=v1.32**

<br/>

<div align="center">
  <iframe width="853" height="480" src="https://www.youtube.com/embed/f931M4-my1k" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

https://gist.github.com/vfarcic/0a322f969368bec74b75677da217291c

<!-- Signing And Verifying Container Images With Sigstore Cosign And Kyverno
https://www.youtube.com/watch?v=HLb1Q086u6M&t=0s -->

<br/>

## Setup

<br/>

```
$ export PROFILE=${USER}-minikube
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)
```

<br/>

```
$ echo ${INGRESS_HOST}
192.168.49.2
```

<br/>

```
$ helm repo add harbor https://helm.goharbor.io
$ helm repo update
```

<br/>

```
$ mkdir -p ~/tmp
$ cd ~/tmp
```

<br/>

```yaml
$ cat > harbor-values.yaml << 'EOF'
expose:
  tls:
    enabled: false
  ingress:
    annotations:
      ingress.kubernetes.io/proxy-body-size: '0'
      ingress.kubernetes.io/ssl-redirect: 'false'
      nginx.ingress.kubernetes.io/proxy-body-size: '0'
      nginx.ingress.kubernetes.io/ssl-redirect: 'false'
harborAdminPassword: Harbor12345
EOF
```

<br/>

proxy-body-size возможно нужно поправить!

<br/>

```
$ helm upgrade --install harbor harbor/harbor \
    --namespace harbor \
    --create-namespace \
    --set expose.ingress.hosts.core=harbor.$INGRESS_HOST.nip.io \
    --set expose.ingress.hosts.notary=notary.$INGRESS_HOST.nip.io \
    --set externalURL=http://harbor.$INGRESS_HOST.nip.io \
    --values harbor-values.yaml \
    --wait

$ echo "http://harbor.$INGRESS_HOST.nip.io"
```

<br/>

```
// OK!
// User: admin
// Password: Harbor12345
http://harbor.192.168.49.2.nip.io
```

<br/>

```
# `Administration` > `Registries` > `+ NEW ENDPOINT` > Add Docker Hub registry
# `Projects` > `NEW PROJECT`
# - Project Name: dot
# - Endpoint URL - http://harbor.192.168.49.2.nip.io
# - Press the `OK` button

# `Projects` > `dot` > `Configuration`
# - Check `Cosign` in `Deployment Security`
# - Check `Prevent vulnerable images from running` in `Deployment Security` and set the severity to `High`.
# - Set `Automatically scan images on push` in `Vulnerability scanning`
```

<br/>

## Build And Push Container (Docker) Images

<br/>

```
$ export PROFILE=${USER}-minikube
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)
$ echo harbor.$INGRESS_HOST.nip.io
```

<br/>

```
// admin / Harbor12345
$ docker login --username admin harbor.$INGRESS_HOST.nip.io
```

<br/>

### push image

```
$ git clone https://github.com/vfarcic/harbor-demo
$ cd harbor-demo/
```

<br/>

```
$ cp go.mod.orig go.mod
```

<br/>

```
$ yq --inplace \
    ".image.repository = \"harbor.$INGRESS_HOST.nip.io/dot/silly-demo\"" \
    helm/values.yaml

$ yq --inplace \
    ".ingress.host = \"silly-demo.$INGRESS_HOST.nip.io\"" \
    helm/values.yaml
```

<br/>

```
$ docker image build \
    --tag harbor.$INGRESS_HOST.nip.io/dot/silly-demo:v0.0.1 .
```

<br/>

```
// OK!
$ docker image push \
    harbor.$INGRESS_HOST.nip.io/dot/silly-demo:v0.0.1
```

<br/>

### Store Helm Charts And Other Artifacts In Harbor

```
$ cat helm/values.yaml

$ yq --inplace ".image.tag = \"v0.0.2\"" helm/values.yaml

$ yq --inplace ".version = \"0.0.2\"" helm/Chart.yaml


// admin / Harbor12345
$ helm registry login harbor.$INGRESS_HOST.nip.io --insecure

$ helm package helm

$ helm push silly-demo-0.0.2.tgz \
    oci://harbor.$INGRESS_HOST.nip.io/dot \
    --insecure-skip-tls-verify

Error: failed to perform "Tag" on destination: GET "https://harbor.192.168.49.2.nip.io/v2/dot/silly-demo/manifests/sha256:8f3804f1a4b1994e4cd7388a9ad24a9855b5a76cf59cc10757a12ac2f9ecd4fd": response status code 412: projectpolicyviolation: The image is not signed by cosign
```

<br/>

**Configure HTTPS Access to Harbor**  
https://goharbor.io/docs/2.5.0/install-config/configure-https/

<br/>

Kubernetes : How to install Harbor Private docker registry (Part 5)  
https://www.youtube.com/watch?v=F46IxGLibVY
