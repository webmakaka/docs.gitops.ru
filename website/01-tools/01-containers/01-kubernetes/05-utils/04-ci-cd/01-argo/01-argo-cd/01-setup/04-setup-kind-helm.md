---
layout: page
title: Инсталляция ArgoCD на Kind с помощью Helm
description: Инсталляция ArgoCD на Kind с помощью Helm
keywords: devops, containers, kubernetes, ci-cd, argocd, setup, kind, helm
permalink: /tools/containers/kubernetes/utils/ci-cd/argo/argo-cd/setup/kind/helm/
---

# Инсталляция ArgoCD на Kind с помощью Helm

<br/>

Делаю:  
2025.12.31

<br/>

Взято в книге: [[Book][Andrew Block, Christian Hernandez] Argo CD: Up and Running: A Hands-On Guide to GitOps and Kubernetes [ENG, 2025]](/books/containers/kubernetes/utils/ci-cd/argo-cd/argocd-up-and-running/)

<br/>

### [Установить Argo CD CLI](/tools/containers/kubernetes/utils/ci-cd/argo/argo-cd/setup/minikube/cli/)

<br/>

**Запустить kind**

```yaml
$ cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
    - containerPort: 80
      hostPort: 80
      protocol: TCP
    - containerPort: 443
      hostPort: 443
      protocol: TCP
EOF
```

<br/>

```
$ kubectl get nodes
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   55s   v1.34.0
```

<br/>

```
$ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
$ helm repo update
```

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > values-ingress-nginx.yaml <<EOF
controller:
  service:
    type: NodePort
  hostPort:
    enabled: true
  updateStrategy:
    type: Recreate
EOF
```

<br/>

```
$ helm -n ingress-nginx install ingress-nginx ingress-nginx/ingress-nginx --create-namespace \
-f values-ingress-nginx.yaml
```

<br/>

```
$ kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

<br/>

```
$ kubectl get pods -n ingress-nginx
NAME                                       READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-c98c9b6d4-gs5rz   1/1     Running   0          67s
```

<br/>

```
$ kubectl get svc -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.96.27.157    <none>        80:31117/TCP,443:30497/TCP   2m6s
ingress-nginx-controller-admission   ClusterIP   10.96.244.156   <none>        443/TCP                      2m6s
```

<br/>

```
// OK!
$ curl http://127.0.0.1
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

<br/>

```
// Если нужен debug
$ kubectl exec -n ingress-nginx deployment/ingress-nginx-controller -- curl -I http://localhost
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0   146    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 404 Not Found
Date: Fri, 05 Dec 2025 22:56:42 GMT
Content-Type: text/html
Content-Length: 146
Connection: keep-alive
```

<br/>

```yaml
$ cat > values-argocd-ingress.yaml <<EOF
server:
  ingress:
    enabled: true
    hostname: argocd.k8s.local
    ingressClassName: nginx
  extraArgs:
  - --insecure
EOF
```

<!-- <br/>

```yaml
$ cat > values-argocd-ingress.yaml <<EOF
---
server:
  ingress:
    enabled: true
    hostname: argocd.k8s.local
    ingressClassName: nginx
    # Явно указываем использовать HTTP порт
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
      nginx.ingress.kubernetes.io/ssl-redirect: "false"
    # Указываем использовать http порт
    http: true
    https: false
  extraArgs:
  - --insecure
EOF
``` -->

<br/>

```
$ helm upgrade -i argo-cd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  -f values-argocd-ingress.yaml
```

<br/>

```
$ kubectl get pods -n argocd
NAME                                                        READY   STATUS    RESTARTS   AGE
argo-cd-argocd-application-controller-0                     1/1     Running   0          10m
argo-cd-argocd-applicationset-controller-586d475675-ch7zs   1/1     Running   0          10m
argo-cd-argocd-dex-server-949d55f49-lrjzw                   1/1     Running   0          10m
argo-cd-argocd-notifications-controller-78c4879795-hl9k2    1/1     Running   0          10m
argo-cd-argocd-redis-9b58f4d5c-jd7dn                        1/1     Running   0          10m
argo-cd-argocd-repo-server-bfc967df4-5lrzv                  1/1     Running   0          10m
argo-cd-argocd-server-678b78f468-j5dkb                      1/1     Running   0          10m
```

<br/>

```
$ kubectl get ingress -n argocd
NAME                    CLASS   HOSTS              ADDRESS   PORTS   AGE
argo-cd-argocd-server   nginx   argocd.k8s.local             80      2s
```

<br/>

```
// Добавить в hosts
$ echo "127.0.0.1 argocd.k8s.local" | sudo tee -a /etc/hosts
```

<br/>

```
// OK!
http://argocd.k8s.local
```

<br/>

```
$ export ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
$ echo ${ARGOCD_PASSWORD}
```

<br/>

```
$ argocd login argocd.k8s.local \
    --insecure \
    --username admin \
    --password $ARGOCD_PASSWORD \
    --grpc-web
```

<br/>

```
$ ARGOCD_PASSWORD_NEW_PASSWORD=ABCDEFGH123
$ argocd account update-password \
    --current-password ${ARGOCD_PASSWORD} \
    --new-password ${ARGOCD_PASSWORD_NEW_PASSWORD}
$ ARGOCD_PASSWORD=${ARGOCD_PASSWORD_NEW_PASSWORD}
$ echo ${ARGOCD_PASSWORD}
```

<br/>

```
$ k get nodes
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   13m   v1.34.0
```

<br/>

```yaml
// Удалить
// $ kind delete cluster
```
