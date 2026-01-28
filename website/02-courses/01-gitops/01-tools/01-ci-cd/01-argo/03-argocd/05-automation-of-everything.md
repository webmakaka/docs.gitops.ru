---
layout: page
title: Kubernetes ArgoCD
description: Kubernetes ArgoCD
keywords: devops, contaiers, kubernetes, ci-cd, argocd
permalink: /courses/containers/kubernetes/ci-cd/argocd/automation-of-everything/
---

# Kubernetes ArgoCD

### Automation of Everything - How To Combine Argo Events, Workflows & Pipelines, CD, and Rollouts

<br/>

Делаю:  
15.02.2021

<br/>

https://www.youtube.com/watch?v=XNXJtxkUKeY

<br/>

**Original Gist**

https://gist.github.com/vfarcic/48f44d3974db698d3127f52b6e7cd0d3

<br/>

```
$ export INGRESS_HOST=$(minikube --profile my-profile ip)
$ echo ${INGRESS_HOST}
192.168.49.2
```

<br/>

```
export BASE_HOST=[...] # e.g., $INGRESS_HOST.nip.io

export REGISTRY_SERVER=https://index.docker.io/v1/

# Replace `[...]` with the registry username

export REGISTRY_USER=[...]

# Replace `[...]` with the registry password

export REGISTRY_PASS=[...]

# Replace `[...]` with the registry email

export REGISTRY_EMAIL=[...]

# Replace `[...]` with the GitHub token

export GH_TOKEN=[...]

# Replace `[...]` with the GitHub email

export GH_EMAIL=[...]
```

<br/>

```
$ cd ~/tmp
$ git clone https://github.com/vfarcic/argo-combined-app
$ git clone https://github.com/vfarcic/argo-combined-demo.git

```

<br/>

```
$ cd argo-combined-app
```

<br/>

```
$ cat kustomize/base/ingress.yaml \
 | sed -e "s@acme.com@staging.argo-combined-app.$BASE_HOST@g" \
 | tee kustomize/overlays/staging/ingress.yaml

$ cat kustomize/overlays/production/rollout.yaml \
 | sed -e "s@vfarcic@$REGISTRY_USER@g" \
 | tee kustomize/overlays/production/rollout.yaml

$ cat kustomize/overlays/staging/deployment.yaml \
 | sed -e "s@vfarcic@$REGISTRY_USER@g" \
 | tee kustomize/overlays/staging/deployment.yaml
```

<br/>

```

$ cd argo-combined-demo

$ cat orig/sealed-secrets.yaml \
 | sed -e "s@vfarcic@$GH_ORG@g" \
 | tee production/sealed-secrets.yaml

$ cat argo-cd/base/ingress.yaml \
 | sed -e "s@acme.com@argo-cd.$BASE_HOST@g" \
 | tee argo-cd/overlays/production/ingress.yaml

$ cat argo-workflows/base/ingress.yaml \
 | sed -e "s@acme.com@argo-workflows.$BASE_HOST@g" \
 | tee argo-workflows/overlays/production/ingress.yaml

$ cat argo-events/base/event-sources.yaml \
 | sed -e "s@vfarcic@$GH_ORG@g" \
    | sed -e "s@acme.com@webhook.$BASE_HOST@g" \
 | tee argo-events/overlays/production/event-sources.yaml

$ cat argo-events/base/sensors.yaml \
 | sed -e "s@value: vfarcic@value: $GH_ORG@g" \
 | sed -e "s@value: CHANGE_ME_IMAGE_OWNER@value: $REGISTRY_USER@g" \
 | tee argo-events/overlays/production/sensors.yaml

$ cat production/argo-cd.yaml \
 | sed -e "s@vfarcic@$GH_ORG@g" \
 | tee production/argo-cd.yaml

$ cat production/argo-workflows.yaml \
 | sed -e "s@vfarcic@$GH_ORG@g" \
 | tee production/argo-workflows.yaml

$ cat production/argo-events.yaml \
 | sed -e "s@vfarcic@$GH_ORG@g" \
 | tee production/argo-events.yaml

$ cat production/argo-rollouts.yaml \
 | sed -e "s@vfarcic@$GH_ORG@g" \
 | tee production/argo-rollouts.yaml

$ cat production/argo-combined-app.yaml \
 | sed -e "s@github.com/vfarcic@github.com/$GH_ORG@g" \
 | sed -e "s@- vfarcic@- $REGISTRY_USER@g" \
 | tee production/argo-combined-app.yaml

$ cat staging/argo-combined-app.yaml \
 | sed -e "s@github.com/vfarcic@github.com/$GH_ORG@g" \
 | sed -e "s@- vfarcic@- $REGISTRY_USER@g" \
 | tee staging/argo-combined-app.yaml

$ cat apps.yaml \
 | sed -e "s@vfarcic@$GH_ORG@g" \
 | tee apps.yaml
```

<br/>

```
$ kubectl apply --filename sealed-secrets
```

<br/>

```
$ kubectl --namespace workflows \
 create secret \
 docker-registry regcred \
 --docker-server=$REGISTRY_SERVER \
    --docker-username=$REGISTRY_USER \
 --docker-password=$REGISTRY_PASS \
    --docker-email=$REGISTRY_EMAIL \
 --output json \
 --dry-run=client \
 | kubeseal --format yaml \
 | tee argo-workflows/overlays/production/regcred.yaml

# Wait for a while and repeat the previous command if the output contains `cannot fetch certificate` error message
```

<br/>

```
$ echo "apiVersion: v1
kind: Secret
metadata:
name: github-access
namespace: workflows
type: Opaque
data:
token: $(echo -n $GH_TOKEN | base64)
user: $(echo -n $GH_ORG | base64)
email: $(echo -n $GH_EMAIL | base64)" \
 | kubeseal --format yaml \
 | tee argo-workflows/overlays/workflows/githubcred.yaml

```

<br/>

```
$ echo "apiVersion: v1
kind: Secret
metadata:
name: github-access
namespace: argo-events
type: Opaque
data:
token: $(echo -n $GH_TOKEN | base64)" \
 | kubeseal --format yaml \
 | tee argo-events/overlays/production/githubcred.yaml
```

<br/>

```
git add .

git commit -m "Manifests"

git push

cd ..
```

<br/>

### GitOps deployments

<br/>

```
$ cd argo-combined-demo
```

<br/>

```
$ cat production/argo-cd.yaml
```

<br/>

```
$ kustomize build \
 argo-cd/overlays/production \
 | kubectl apply --filename -

$ kubectl --namespace argocd \
 rollout status \
 deployment argocd-server
```

<br/>

```
$ export PASS=$(kubectl \
 --namespace argocd \
 get secret argocd-initial-admin-secret \
 --output jsonpath="{.data.password}" \
 | base64 --decode)

$ argocd login \
 --insecure \
 --username admin \
 --password $PASS \
    --grpc-web \
    argo-cd.$BASE_HOST

$ argocd account update-password \
 --current-password $PASS \
 --new-password admin
```

<br/>

```
http://argo-cd.$BASE_HOST

admin / admin
```

<br/>

```

$ kubectl apply --filename project.yaml

$ kubectl apply --filename apps.yaml

```

<br/>

### Events and workflows

```
$ cat argo-events/overlays/production/event-sources.yaml

$ cat argo-events/overlays/production/sensors.yaml

open https://github.com/$GH_ORG/argo-combined-app/settings/hooks

open http://argo-workflows.$BASE_HOST
```

<br/>

```
$ cd ../argo-combined-app

# This might not work with providers that do not expose the IP but a host (e.g., AWS EKS)

$ export ISTIO_HOST=$(kubectl \
 --namespace istio-system \
 get svc istio-ingressgateway \
 --output jsonpath="{.status.loadBalancer.ingress[0].ip}")

$ echo $ISTIO_HOST

$ cat kustomize/base/istio.yaml \
 | sed -e "s@acme.com@argo-combined-app.$ISTIO_HOST.xip.io@g" \
 | tee kustomize/overlays/production/istio.yaml

$ cat config.toml \
 | sed -e "s@Where DevOps becomes practice@Subscribe now\!\!\!@g" \
 | tee config.toml
```

<br/>

```
git add .

git commit -m "A silly change"

git push

```

<br/>

### GitOps upgrades

open http://staging.argo-combined-app.$BASE_HOST

<br/>

### Canary deployments

cat kustomize/overlays/production/rollout.yaml

kubectl argo rollouts \
 --namespace production \
 get rollout argo-combined-app \
 --watch

open http://argo-combined-app.$ISTIO_HOST.xip.io

```

```
