---
layout: page
title: Инсталляция Jenkins в ubuntu 22.04
description: Инсталляция Jenkins в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, Jenkins, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/jenkins/secrets-management-with-vault/
---

# Secrets Management with Vault

<br/>

**Делаю:**  
2026.01.04

<br/>

### [Устанавливаю vault](/tools/containers/kubernetes/utils/security/vault/setup/)

<br/>

```
// Connect to the vault-0 which has the vault manager configured
$ kubectl exec -it -n vault vault-0 -- sh
```

<br/>

```
// Explore vault using some simple commands
$ vault
$ vault status
$ vault secrets list
```

<br/>

```
// Adding Secret to the Vault
$ vault kv put secret/dso-demo/database username=devops password=mysupersecret
```

<br/>

```
// Retrieve information that you just added and verify
$ vault kv list secret/
$ vault kv list secret/dso-demo
$ vault kv get secret/dso-demo/database
```

<br/>

```
======== Secret Path ========
secret/data/dso-demo/database

======= Metadata =======
Key                Value
---                -----
created_time       2026-01-04T05:26:07.408297829Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

====== Data ======
Key         Value
---         -----
password    mysupersecret
username    devops
```

<br/>

### Setting up Vault Access Policies

<br/>

```
$ vault policy
$ vault policy list
```

<br/>

```
$ vault policy write dso-demo - <<EOF
path "secret/data/dso-demo/database" {
capabilities = ["read"]
}
EOF
```

<br/>

```
$ vault policy read dso-demo
path "secret/data/dso-demo/database" {
capabilities = ["read"]
```

<br/>

### Writing Policy and Kubernetes RBAC

```
$ vault auth
$ vault auth list
```

<br/>

```
$ vault auth enable kubernetes
$ vault auth list
```

<br/>

```
$ env | grep -i kube
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_SERVICE_HOST=10.96.0.1
```

<br/>

```
$ ls /var/run/secrets/kubernetes.io/serviceaccount/
ca.crt     namespace  token
```

<br/>

```
$ ls /var/run/secrets/kubernetes.io/serviceaccount/
ca.crt     namespace  token
```

<br/>

```
$ vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    issuer="https://kubernetes.default.svc.cluster.local"
```

<br/>

```
$ vault auth list
Path           Type          Accessor                    Description                Version
----           ----          --------                    -----------                -------
kubernetes/    kubernetes    auth_kubernetes_6ca9cb88    n/a                        n/a
token/         token         auth_token_1081d226         token based credentials    n/a
```

<br/>

```
// map the vault policy with the service
account dso-demo
$ vault write auth/kubernetes/role/dso-demo \
    bound_service_account_names=dso-demo \
    bound_service_account_namespaces=default \
    policies=dso-demo \
    audience="" \
    ttl=30h
```

<!-- ```
// map the vault policy with the service
account dso-demo
$ vault write auth/kubernetes/role/dso-demo \
    bound_service_account_names=dso-demo \
    bound_service_account_namespaces=default \
    policies=dso-demo \
    audience=vault \
    ttl=30h
``` -->

<br/>

### Injecting a Secret into the Pod

<br/>

Нужно добавить serviceAccountName: dso-demo и:

```
annotations:
    vault.hashicorp.com/agent-inject: 'true'
    vault.hashicorp.com/role: 'dso-demo'
    vault.hashicorp.com/agent-inject-secret-database: 'secret/dso-demo/database'
```

В файл:

https://github.com/wildmakaka/dso-demo/blob/main/deploy/dso-demo-deploy.yaml

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dso-demo
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: dso-demo
  name: dso-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dso-demo
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: dso-demo
      annotations:
        vault.hashicorp.com/agent-inject: 'true'
        vault.hashicorp.com/role: 'dso-demo'
        vault.hashicorp.com/agent-inject-secret-database: 'secret/dso-demo/database'
    spec:
      serviceAccountName: dso-demo
      containers:
        - image: webmakaka/dso-demo
          name: dso-demo
          ports:
            - containerPort: 8080
          resources: {}
status: {}
EOF
```

<br/>

```
$ kubectl get pods
NAME                        READY   STATUS     RESTARTS   AGE
dso-demo-6768c4d85f-chrwk   0/2     Init:0/1   0          2m4s
```

<br/>

Пошли траблшутить!

<br/>

### Troubleshooting the Vault Policy

```
$ vault policy read dso-demo
path "secret/data/dso-demo/database" {
capabilities = ["read"]
```

<br/>

```
$ vault kv get secret/dso-demo/database
======== Secret Path ========
secret/data/dso-demo/database

======= Metadata =======
Key                Value
---                -----
created_time       2026-01-04T05:26:07.408297829Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

====== Data ======
Key         Value
---         -----
password    mysupersecret
username    devops
```

<br/>

```
$ vault policy write dso-demo - <<EOF
path "secret/data/dso-demo/*" {
capabilities = ["read"]
}
EOF
```

<br/>

```
$ vault policy read dso-demo
path "secret/data/dso-demo/*" {
capabilities = ["read"]
}
```

<br/>

Не помогло!

<br/>

```
$ vault policy write dso-demo - <<EOF
path "*" {
capabilities = ["read"]
}
EOF
```

<!--
```
// Вроде после этого заработало
// $ kubectl create token dso-demo --audience=vault
``` -->

<br/>

```
$ kubectl exec -it dso-demo-xxxx -- sh
```

<br/>

```
# ls /vault/secrets/
database
```

<br/>

```
# cat /vault/secrets/database
data: map[password:mysupersecret username:devops]
metadata: map[created_time:2026-01-04T05:26:07.408297829Z custom_metadata:<nil> deletion_time: destroyed:false version:1]
```

<br/>

```
$ vault policy write dso-demo - <<EOF
path "secret/data/dso-demo/database" {
capabilities = ["read"]
}
EOF
```

<br/>

### Customizing Secrets using Templates

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: dso-demo
  name: dso-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dso-demo
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: dso-demo
      annotations:
        vault.hashicorp.com/agent-inject: 'true'
        vault.hashicorp.com/role: 'dso-demo'
        vault.hashicorp.com/agent-inject-secret-database: 'secret/dso-demo/database'
        vault.hashicorp.com/agent-inject-template-database: |
            {{- with secret "secret/dso-demo/database" -}}
                mysql -u {{ .Data.data.username }} -p {{ .Data.data.password }} -h database:3306 mydb
            {{- end -}}
    spec:
      serviceAccountName: dso-demo
      containers:
        - image: webmakaka/dso-demo
          name: dso-demo
          ports:
            - containerPort: 8080
          resources: {}
status: {}
EOF
```

<br/>

```
$ kubectl exec -it dso-demo-xxxx -- sh
```

<br/>

```
# cat /vault/secrets/database
mysql -u devops -p mysupersecret -h database:3306 mydb
```

<br/>

### Rotating Secrets

```
$ vault kv put secret/dso-demo/database user=devops password=superdupersecretnow
```

<br/>

Ждем сколько-то времени.

<br/>

```
# cat /vault/secrets/database
mysql -u <no value> -p superdupersecretnow -h database:3306 mydb
```
