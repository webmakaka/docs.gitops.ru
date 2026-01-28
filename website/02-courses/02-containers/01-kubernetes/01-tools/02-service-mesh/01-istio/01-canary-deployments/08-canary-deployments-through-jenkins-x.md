---
layout: page
title: Canary Deployments To Kubernetes Using Istio and Friends - Canary Deployments Through Jenkins X
description: Canary Deployments To Kubernetes Using Istio and Friends - Canary Deployments Through Jenkins X
keywords: linux, kubernetes, Istio, canary deployments, flagger
permalink: /courses/containers/kubernetes/service-mesh/istio/canary-deployments/canary-deployments-through-jenkins-x/
---

# Canary Deployments To Kubernetes Using Istio and Friends

Не стал делать

<br/>

# 10 Canary Deployments Through Jenkins X

https://gist.github.com/vfarcic/0ccbb3a25fa59bbf2e578776d6deb07f

<br/>

```
##################
# Create Cluster
##################
```

<br/>

```
# NOTE: Jenkins X doesn't work with Docker Desktop and minikube

# GKE with Istio and Flagger: https://gist.github.com/561f87ee1a32c0d80d3a1027eb8a3171 (gke-istio-flagger.sh)

# EKS with Istio and Flagger: https://gist.github.com/4e0213715efcfb4b27be5012e15b5fe9 (eks-istio-flagger.sh)

# AKS with Istio and Flagger: https://gist.github.com/fbf632e59690fe80b63204592a14218a (aks-istio-flagger.sh)
```

<br/>

```
######################
# Quickstart Project
######################
```

<br/>

```
export CLUSTER_NAME=[...] # (e.g., istio)

export GH_USER=[...]

jx create quickstart \
 --filter golang-http \
 --name jx-canary

jx get activities \
 --filter jx-canary \
 --watch

# Cancel with ctrl+c

jx get activities \
 --filter environment-$CLUSTER_NAME-staging/master \
 --watch

# Cancel with ctrl+c

jx get applications

STAGING_ADDR=[...]

curl $STAGING_ADDR

####################

# Canary Resources

####################

cat jx-canary/charts/jx-canary/templates/hpa.yaml

cat jx-canary/charts/jx-canary/templates/canary.yaml

cat jx-canary/charts/jx-canary/values.yaml

#######################

# Switching To Canary

#######################

git clone \
 https://github.com/$GH_USER/environment-$CLUSTER_NAME-production

cd environment-$CLUSTER_NAME-production

cat env/values.yaml

GATEWAY_IP=$(kubectl --namespace istio-system \
 get service istio-ingressgateway \
 --output jsonpath="{.status.loadBalancer.ingress[0].ip}")

PROD_ADDR=jx-canary.$GATEWAY_IP.nip.io

echo $PROD_ADDR

cat env/values.yaml

echo "jx-canary:
hpa:
enabled: true
canary:
enabled: true
host: $PROD_ADDR" \
 | tee -a env/values.yaml

cat env/values.yaml

git add .

git commit -m "jx-canary"

git push --set-upstream origin master

jx get activities \
 --filter environment-$CLUSTER_NAME-production/master \
 --watch

# Cancel with ctrl+c

kubectl label namespace jx-production \
 istio-injection=enabled

jx get applications

export VERSION=[...] # e.g., 0.0.1

jx promote jx-canary \
 --version $VERSION \
 --env production \
 --batch-mode

jx get activities \
 --filter environment-$CLUSTER_NAME-production/master \
 --watch

# Cancel with ctrl+c

kubectl --namespace jx-production \
 get canaries

curl $PROD_ADDR

###############

# New Release

###############

kubectl --namespace jx-production \
 get all

kubectl --namespace jx-production \
 get virtualservices,gateways,destinationrules

pwd

cat env/values.yaml

kubectl describe namespace \
 jx-production

cd ../jx-canary

cat main.go | sed -e \
 "s@http example@http example with canary deployment@g" \
 | tee main.go

git add .

git commit -m "New release"

git push --set-upstream origin master

jx get activities \
 --filter jx-canary \
 --watch

# Cancel with ctrl+c

jx get activities \
 --filter environment-$CLUSTER_NAME-staging/master \
 --watch

# Cancel with ctrl+c

curl $STAGING_ADDR

kubectl --namespace jx-staging \
 get canaries

jx get applications

export VERSION=[...] # e.g., 0.0.1

jx promote jx-canary \
 --version $VERSION \
 --env production \
 --batch-mode

while true; do
curl $PROD_ADDR
sleep 1
done

# Cancel with ctrl+c when all the responses are coming from the new release

jx get applications --env production

kubectl --namespace jx-production \
 get canaries

cd ..

###############

# Cleaning Up

###############

rm -rf jx-canary

rm -rf environment-$CLUSTER_NAME-dev

rm -rf environment-$CLUSTER_NAME-production

hub delete -y $GH_USER/jx-canary

hub delete -y \
 $GH_USER/environment-$CLUSTER_NAME-dev

hub delete -y \
 $GH_USER/environment-$CLUSTER_NAME-staging

hub delete -y \
 $GH_USER/environment-$CLUSTER_NAME-production

# Delete the cluster using the Gists
```
