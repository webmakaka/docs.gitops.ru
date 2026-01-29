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

<br/>

**Дока по инсталляции:**  
https://github.com/lm-academy/argo-rollouts-course/blob/main/setup-gateway-api/setup-instructions.md

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
// OK!
http://dashboard.local
http://whoami.local
```

<br/>

## Install Argo Rollouts Gateway API Plugin

<br/>

https://rollouts-plugin-trafficrouter-gatewayapi.readthedocs.io/en/latest/installation/

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
// Upgrade the helm chart with
$ helm upgrade argo-rollouts argo/argo-rollouts \
    --install \
    --namespace argo-rollouts \
    --create-namespace \
    --version 2.40.5 \
    --values values-argo-rollouts.yaml
```

<br/>

```
// Restart Argo Rollouts
$ kubectl rollout restart deployment -n argo-rollouts argo-rollouts
```

<br/>

```
$ kubectl get pod -n argo-rollouts
NAME                                       READY   STATUS    RESTARTS   AGE
argo-rollouts-6876f47dd4-fx5br             1/1     Running   0          13m
argo-rollouts-6876f47dd4-tnnwv             1/1     Running   0          14m
argo-rollouts-dashboard-6bc9fff6fc-29kbh   1/1     Running   0          14m
marley@workstation:~/projects/docs.gitops.ru$
```

<br/>

```
// Плагин должен быть скопирован
$ kubectl logs argo-rollouts-6876f47dd4-fx5br -n argo-rollouts | grep plugin
Defaulted container "argo-rollouts" out of: argo-rollouts, copy-gwapi-plugin (init)
time="2026-01-29T03:01:22Z" level=info msg="Copied plugin from /plugins/rollouts-plugin-trafficrouter-gatewayapi to /home/argo-rollouts/plugin-bin/argoproj-labs/gatewayAPI"
```

<br/>

## Traffic-Weighted Canary

https://github.com/lm-academy/argo-rollouts-course/tree/main/traffic-weighting/manifests

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: gateway-lab
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: rollout-gateway-stable
  namespace: gateway-lab
spec:
  ports:
    - port: 3000
      name: http
  selector:
    app: rollout-gateway
---
apiVersion: v1
kind: Service
metadata:
  name: rollout-gateway-canary
  namespace: gateway-lab
spec:
  ports:
    - port: 3000
      name: http
  selector:
    app: rollout-gateway
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: rollout-gateway
  namespace: gateway-lab
spec:
  gatewayClassName: traefik
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: Same
EOF
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: rollout-gateway-route
  namespace: gateway-lab
spec:
  parentRefs:
    - name: rollout-gateway
  hostnames:
    - 'color-app.local'
  rules:
    - backendRefs:
        - name: rollout-gateway-stable
          port: 3000
        - name: rollout-gateway-canary
          port: 3000
EOF
```

<br/>

```
$ kubectl describe httproute -n gateway-lab rollout-gateway-route
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollout-gateway
  namespace: gateway-lab
spec:
  replicas: 5
  selector:
    matchLabels:
      app: rollout-gateway
  template:
    metadata:
      labels:
        app: rollout-gateway
    spec:
      containers:
        - name: rollout-gateway
          image: lmacademy/simple-color-app:1.0.0
          env:
            - name: APP_COLOR
              value: blue
  strategy:
    canary:
      canaryService: rollout-gateway-canary
      stableService: rollout-gateway-stable
      dynamicStableScale: true
      trafficRouting:
        plugins:
          argoproj-labs/gatewayAPI:
            httpRoute: rollout-gateway-route # our created httproute
            namespace: gateway-lab # namespace where this rollout resides
      steps:
        - setWeight: 30
        - pause: {}
        - setWeight: 40
        - pause:
            duration: 10s
        - setWeight: 60
        - pause:
            duration: 10s
        - setWeight: 80
        - pause:
            duration: 10s
EOF
```

<br/>

```
$ kubectl argo rollouts get rollout rollout-gateway -n gateway-lab
```

<br/>

```
// Добавить в hosts
$ echo "192.168.49.20 color-app.local" | sudo tee -a /etc/hosts
```

<br/>

```
// OK!
http://color-app.local/
```

<br/>

```
// Запуск dashboard
$ kubectl argo rollouts dashboard
```

<br/>

```
// OK!
http://localhost:3100/rollouts/gateway-lab
```

<br/>

```
$ kubectl describe httproute rollout-gateway-route -n gateway-lab
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollout-gateway
  namespace: gateway-lab
spec:
  replicas: 5
  selector:
    matchLabels:
      app: rollout-gateway
  template:
    metadata:
      labels:
        app: rollout-gateway
    spec:
      containers:
        - name: rollout-gateway
          image: lmacademy/simple-color-app:1.0.0
          env:
            - name: APP_COLOR
              value: green
  strategy:
    canary:
      canaryService: rollout-gateway-canary
      stableService: rollout-gateway-stable
      dynamicStableScale: true
      trafficRouting:
        plugins:
          argoproj-labs/gatewayAPI:
            httpRoute: rollout-gateway-route # our created httproute
            namespace: gateway-lab # namespace where this rollout resides
      steps:
        - setWeight: 30
        - pause: {}
        - setWeight: 40
        - pause:
            duration: 10s
        - setWeight: 60
        - pause:
            duration: 10s
        - setWeight: 80
        - pause:
            duration: 10s
EOF
```

<br/>

```
$ kubectl argo rollouts promote rollout-gateway -n gateway-lab
```

<br/>

## Traffic Management - Header-Based Routing

<br/>

https://github.com/lm-academy/argo-rollouts-course/tree/main/header-based-routing

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollout-gateway
  namespace: gateway-lab
spec:
  replicas: 5
  selector:
    matchLabels:
      app: rollout-gateway
  template:
    metadata:
      labels:
        app: rollout-gateway
    spec:
      containers:
        - name: rollout-gateway
          image: lmacademy/simple-color-app:1.0.0
          env:
            - name: APP_COLOR
              value: red
  strategy:
    canary:
      canaryService: rollout-gateway-canary
      stableService: rollout-gateway-stable
      dynamicStableScale: true
      trafficRouting:
        plugins:
          argoproj-labs/gatewayAPI:
            httpRoute: rollout-gateway-route # our created httproute
            namespace: gateway-lab # namespace where this rollout resides
        managedRoutes:
          - name: qa-override
      steps:
        - setWeight: 1
        - pause:
            duration: 20s
        - setCanaryScale:
            weight: 40
        - setHeaderRoute:
            name: qa-override
            match:
              - headerName: x-canary
                headerValue:
                  exact: 'true'
        - pause: {}
        - setWeight: 30
        - pause: {}
        - setWeight: 40
        - pause:
            duration: 10s
        - setWeight: 60
        - pause:
            duration: 10s
        - setWeight: 80
        - pause:
            duration: 10s
EOF
```

<br/>

```
$ ./test-requests.sh color-app.local -1 0.2
```

<br/>

```
$ ./test-requests.sh --tester color-app.local -1 0.2
```

<br/>

```
$ kubectl argo rollouts promote rollout-gateway -n gateway-lab
```
