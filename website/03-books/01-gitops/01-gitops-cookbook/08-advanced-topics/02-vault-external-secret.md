---
layout: page
title: GitOps Cookbook - Advanced Topics - Encrypt Secrets with ArgoCD (ArgoCD + HashiCorp Vault + External Secret)
description: Хранить credentials в vault
keywords: books, gitops, GitOps Cookbook - Advanced Topics, Encrypt Secrets with ArgoCD (ArgoCD + HashiCorp Vault + External Secret)
permalink: /books/gitops/gitops-cookbook/advanced-topics/vault-external-secret/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 08. 8.2 Encrypt Secrets with ArgoCD (ArgoCD + HashiCorp Vault + External Secret)

<br/>

**Задача:**  
Хранить credentials в vault

<br/>

**Делаю:**  
2025.12.09

<br/>

**Нужно заходить сюда и читать доки:**  
https://external-secrets.io/

<br/>

**Посмотреть:**
https://www.youtube.com/watch?v=1mjgLcQgSCo

https://www.youtube.com/watch?v=SyRZe5YVCVk

<br/>

```
$ helm repo add external-secrets https://charts.external-secrets.io
```

<br/>

```
$ helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets \
  --create-namespace \
  --version 0.16.0
```

<br/>

```
$ kubectl get pods -n external-secrets
NAME                                               READY   STATUS    RESTARTS   AGE
external-secrets-578bcbd665-jf6vd                  1/1     Running   0          39s
external-secrets-cert-controller-b5d7544b8-52rvj   1/1     Running   0          39s
external-secrets-webhook-9cdb85fd-bj4zp            1/1     Running   0          39s
```

<br/>

```
$ kubectl get crd | grep external-secrets
acraccesstokens.generators.external-secrets.io          2025-12-09T02:01:11Z
clusterexternalsecrets.external-secrets.io              2025-12-09T02:01:11Z
clustergenerators.generators.external-secrets.io        2025-12-09T02:01:11Z
clusterpushsecrets.external-secrets.io                  2025-12-09T02:01:11Z
clustersecretstores.external-secrets.io                 2025-12-09T02:01:11Z
ecrauthorizationtokens.generators.external-secrets.io   2025-12-09T02:01:11Z
externalsecrets.external-secrets.io                     2025-12-09T02:01:11Z
fakes.generators.external-secrets.io                    2025-12-09T02:01:11Z
gcraccesstokens.generators.external-secrets.io          2025-12-09T02:01:11Z
generatorstates.generators.external-secrets.io          2025-12-09T02:01:11Z
githubaccesstokens.generators.external-secrets.io       2025-12-09T02:01:11Z
grafanas.generators.external-secrets.io                 2025-12-09T02:01:11Z
passwords.generators.external-secrets.io                2025-12-09T02:01:11Z
pushsecrets.external-secrets.io                         2025-12-09T02:01:11Z
quayaccesstokens.generators.external-secrets.io         2025-12-09T02:01:11Z
secretstores.external-secrets.io                        2025-12-09T02:01:11Z
stssessiontokens.generators.external-secrets.io         2025-12-09T02:01:11Z
uuids.generators.external-secrets.io                    2025-12-09T02:01:11Z
vaultdynamicsecrets.generators.external-secrets.io      2025-12-09T02:01:11Z
webhooks.generators.external-secrets.io                 2025-12-09T02:01:11Z
```

<br/>

```
$ helm repo add hashicorp https://helm.releases.hashicorp.com
$ helm install vault hashicorp/vault -n vault --create-namespace --set server.dev.enabled=true
```

<br/>

```
$ kubectl get pods -n vault
NAME                                    READY   STATUS    RESTARTS   AGE
vault-0                                 1/1     Running   0          7m8s
vault-agent-injector-556c5dd8fb-qgdrr   1/1     Running   0          7m8s
```

<br/>

```
$ kubectl logs -n vault vault-0 | grep -A 5 -B 5 "Root Token"

The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.

Unseal Key: WyhvMpI1nWtOX5qjOXIC9GArr3eDKBcQ1cAa+HD+j1E=
Root Token: root

Development mode should NOT be used in production installations!
```

<br/>

```
$ kubectl create secret generic vault-token \
--from-literal=token=$VAULT_TOKEN
```

<br/>

```
$ kubectl port-forward -n vault svc/vault 8200:8200
```

<br/>

```
$ export VAULT_ADDR='http://127.0.0.1:8200'

$ export VAULT_TOKEN='root'

$ vault kv put secret/pacman-secrets2 pass=pacman2
======= Secret Path =======
secret/data/pacman-secrets2

======= Metadata =======
Key                Value
---                -----
created_time       2025-12-09T04:22:41.522270649Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

```

<br/>

```
// Смотрим актуальную версию API
$ kubectl api-resources | grep SecretStore
applications                        app,apps           argoproj.io/v1alpha1              true         Application
applicationsets                     appset,appsets     argoproj.io/v1alpha1              true         ApplicationSet
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: vault-store
  #namespace: external-secrets
spec:
  provider:
    vault:
      # server: "http://vault.local:8200"
      server: "http://vault.vault.svc.cluster.local:8200"
      path: "secret"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          key: "token"
          #namespace: external-secrets
EOF
```

<br/>

```
$ kubectl get SecretStore
NAME          AGE   STATUS   CAPABILITIES   READY
vault-store   8s    Valid    ReadWrite      True
```

<br/>

```

// Смотрим актуальную версию API
$ kubectl api-resources | grep ExternalSecret$ kubectl api-resources | grep ExternalSecret
clusterexternalsecrets ces external-secrets.io/v1beta1 false ClusterExternalSecret
externalsecrets es external-secrets.io/v1beta1 true ExternalSecret
```

<br/>

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: pacman-external-secret
  # namespace: default
spec:
  refreshInterval: "15s"
  secretStoreRef:
    name: vault-store
    kind: SecretStore
  target:
    name: pacman-external-secret
  data:
  - secretKey: token
    remoteRef:
      key: secret/pacman-secrets2
      property: pass
EOF
```

<br/>

```
$ kubectl get ExternalSecret
NAME                     STORETYPE     STORE         REFRESH INTERVAL   STATUS              READY
pacman-external-secret   SecretStore   vault-store   15s                SecretSynced        True
```

<br/>

```
$ kubectl get secret
NAME                     TYPE     DATA   AGE
pacman-external-secret   Opaque   1      64s
```

<br/>

```
$ kubectl get secret pacman-external-secret -o yaml
```

<br/>

```
$ kubectl get secret pacman-external-secret -o jsonpath='{.data.token}' | base64 -d
pacman2
```

<br/>

То, что сохранили в vault, получили в secret

Надеюсь я все правильно понял и интерпретировал результат.
