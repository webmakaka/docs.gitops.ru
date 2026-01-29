---
layout: page
title: GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - Advanced Traffic Management
description: GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - Advanced Traffic Management
keywords: courses, gitops, argo, GitOps in Practice with Argo CD and Argo Rollouts - Argo Rollouts - Advanced Traffic Management
permalink: /courses/gitops/ci-cd/argo/gitops-in-practice-with-argo-cd-and-argo-rollouts/argo-rollouts/advanced-traffic-management/
---

# [Lauro Fialho Müller] GitOps in Practice with Argo CD and Argo Rollouts [ENG, 2026]: Argo Rollouts: Advanced Traffic Management

<br/>

**Делаю:**  
2026.01.29

https://github.com/lm-academy/argo-rollouts-course/tree/main/setup-gateway-api

<br/>

```
$ kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
```

<br/>

```
$ helm repo add traefik https://traefik.github.io/charts
$ helm repo update
```

<br/>

```
$ cd ~/tmp
```

ии добавил

```
  enabled: true
  name: traefik-gateway
  namespace: traefik
```

<br/>

```yaml
$ cat > traefik-values.yaml << 'EOF'
# values.yaml
ports:
  web:
    port: 80
    nodePort: 30000
    # No redirection to HTTPS

api:
  dashboard: true
  insecure: true

ingressRoute:
  dashboard:
    enabled: true
    matchRule: Host(`dashboard.local`)
    entryPoints:
      - web

ingressClass:
  enabled: false

providers:
  kubernetesIngress:
    enabled: false
  kubernetesGateway:
    enabled: true

gateway:
  enabled: true
  name: traefik-gateway
  namespace: traefik
  listeners:
    web:
      port: 80
      protocol: HTTP
      namespacePolicy:
        from: All

logs:
  access:
    enabled: true

metrics:
  prometheus:
    enabled: true
EOF
```

<br/>

```
$ helm upgrade traefik traefik/traefik \
  --version 37.4.0 \
  --namespace traefik \
  --create-namespace \
  --install \
  --values traefik-values.yaml
```

<br/>

```
$ kubectl get svc -n traefik
NAME      TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
traefik   LoadBalancer   10.107.104.12   192.168.49.20   80:30000/TCP,443:30675/TCP   10s
```

<br/>

```
marley@workstation:~/tmp$ kubectl get Gateway -n traefik
NAME              CLASS     ADDRESS         PROGRAMMED   AGE
traefik-gateway   traefik   192.168.49.20   True         40s
```

<br/>

### Deploy Demo Application

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami
  namespace: traefik
spec:
  replicas: 2
  selector:
    matchLabels:
      app: whoami
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
        - name: whoami
          image: traefik/whoami
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: whoami
  namespace: traefik
spec:
  selector:
    app: whoami
  ports:
    - port: 80
EOF
```

### 5.2 Create HTTPRoute

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: whoami
  namespace: traefik
spec:
  parentRefs:
    - name: traefik-gateway
  hostnames:
    - 'whoami.local'
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: whoami
          port: 80
EOF
```

<br/>

```
$ kubectl get httproute whoami -n traefik
NAME     HOSTNAMES          AGE
whoami   ["whoami.local"]   22m
```

<br/>

### Step 6: Access the Application

<br/>

```
// Добавить в hosts
$ echo "192.168.49.20 whoami.local" | sudo tee -a /etc/hosts
$ echo "192.168.49.20 dashboard.local" | sudo tee -a /etc/hosts
```

<br/>

```
$ kubectl get httproute whoami -n traefik -o jsonpath='{.status.parents[0].conditions[?(@.type=="Accepted")].status}'
```

<br/>

```
$ curl -v -H "Host: whoami.local" http://192.168.49.20                        curl -v -H "Host: whoami.local" http://192.168.49.20
*   Trying 192.168.49.20:80...
* Connected to 192.168.49.20 (192.168.49.20) port 80 (#0)
> GET / HTTP/1.1
> Host: whoami.local
> User-Agent: curl/7.81.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Content-Length: 404
< Content-Type: text/plain; charset=utf-8
< Date: Thu, 29 Jan 2026 02:57:37 GMT
<
Hostname: whoami-64f6cf779d-gmvhb
IP: 127.0.0.1
IP: ::1
IP: 10.244.0.8
IP: fe80::6a:4cff:fee2:fb80
RemoteAddr: 10.244.0.7:40178
GET / HTTP/1.1
Host: whoami.local
User-Agent: curl/7.81.0
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 10.244.0.1
X-Forwarded-Host: whoami.local
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: traefik-5997b59959-nqsct
X-Real-Ip: 10.244.0.1

* Connection #0 to host 192.168.49.20 left intact

```

<br/>

```
http://dashboard.local
http://whoami.local
```

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > values-argo-rollouts.yaml << 'EOF'
# values-rollouts.yaml
dashboard:
  enabled: true

# New: For configuring the Gateway API Plugin
# Source: https://rollouts-plugin-trafficrouter-gatewayapi.readthedocs.io/en/latest/installation/#installing-the-plugin-via-init-containers
controller:
  initContainers:
    - name: copy-gwapi-plugin
      image: ghcr.io/argoproj-labs/rollouts-plugin-trafficrouter-gatewayapi:v0.8.0
      command: ['/bin/sh', '-c']
      args:
        - cp /bin/rollouts-plugin-trafficrouter-gatewayapi /plugins
      volumeMounts:
        - name: gwapi-plugin
          mountPath: /plugins
  trafficRouterPlugins:
    - name: argoproj-labs/gatewayAPI
      location: 'file:///plugins/rollouts-plugin-trafficrouter-gatewayapi'
  volumes:
    - name: gwapi-plugin
      emptyDir: {}
  volumeMounts:
    - name: gwapi-plugin
      mountPath: /plugins
EOF
```

<br/>

```
$ helm upgrade argo-rollouts argo/argo-rollouts \
    --install \
    --namespace argo-rollouts \
    --create-namespace \
    --version 2.40.5 \
    --values values-argo-rollouts.yaml
```

<br/>

```
$ kubectl rollout restart deployment -n argo-rollouts argo-rollouts
```
