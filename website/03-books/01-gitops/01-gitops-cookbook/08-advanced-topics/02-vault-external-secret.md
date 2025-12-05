---
layout: page
title: GitOps Cookbook - Advanced Topics - Encrypt Secrets with ArgoCD (ArgoCD + HashiCorp Vault + External Secret)
description: Зашифровать Secret в Git
keywords: books, gitops, GitOps Cookbook - Advanced Topics, Encrypt Secrets with ArgoCD (ArgoCD + HashiCorp Vault + External Secret)
permalink: /books/gitops/gitops-cookbook/advanced-topics/vault-external-secret/
---

<br/>

# [Book] [FAIL!] GitOps Cookbook: 08. 8.2 Encrypt Secrets with ArgoCD (ArgoCD + HashiCorp Vault + External Secret)

<br/>

**Задача:**  
Хранить учетки во внешних сервисах или в vault

<br/>

**Делаю:**  
2025.12.05

<br/>

**Нужно заходить сюда и читать доки:**  
https://external-secrets.io/

<br/>

**Посмотреть:**
https://www.youtube.com/watch?v=1mjgLcQgSCo

https://www.youtube.com/watch?v=SyRZe5YVCVk

<!-- <br/>

```
$ helm repo add external-secrets https://charts.external-secrets.io
```

<br/>

```
helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets \
  --create-namespace \
  --set installCRDs=true
``` -->

<br/>

```
$ kubectl get pods -n external-secrets
NAME                                                READY   STATUS    RESTARTS   AGE
external-secrets-7cf45cd977-cjt4r                   1/1     Running   0          102s
external-secrets-cert-controller-7cbf854658-xwg7m   1/1     Running   0          102s
external-secrets-webhook-7d878757cb-x6qfj           1/1     Running   0          102s
```

<br/>

```
// Наверное не нужно было делать
$ kubectl delete crd   clusterexternalsecrets.external-secrets.io   externalsecrets.external-secrets.io   --ignore-not-found
$ kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/v0.9.6/deploy/crds/bundle.yaml
```

```
$ kubectl get crd | grep external-secrets
acraccesstokens.generators.external-secrets.io          2025-12-05T01:08:41Z
cloudsmithaccesstokens.generators.external-secrets.io   2025-12-05T01:08:41Z
clusterexternalsecrets.external-secrets.io              2025-12-05T01:20:16Z
clustergenerators.generators.external-secrets.io        2025-12-05T01:08:41Z
clusterpushsecrets.external-secrets.io                  2025-12-05T01:08:41Z
clustersecretstores.external-secrets.io                 2025-12-05T01:08:41Z
ecrauthorizationtokens.generators.external-secrets.io   2025-12-05T01:08:41Z
externalsecrets.external-secrets.io                     2025-12-05T01:20:16Z
fakes.generators.external-secrets.io                    2025-12-05T01:08:41Z
gcraccesstokens.generators.external-secrets.io          2025-12-05T01:08:41Z
generatorstates.generators.external-secrets.io          2025-12-05T01:08:41Z
githubaccesstokens.generators.external-secrets.io       2025-12-05T01:08:41Z
grafanas.generators.external-secrets.io                 2025-12-05T01:08:41Z
mfas.generators.external-secrets.io                     2025-12-05T01:08:41Z
passwords.generators.external-secrets.io                2025-12-05T01:08:41Z
pushsecrets.external-secrets.io                         2025-12-05T01:08:41Z
quayaccesstokens.generators.external-secrets.io         2025-12-05T01:08:41Z
secretstores.external-secrets.io                        2025-12-05T01:08:41Z
sshkeys.generators.external-secrets.io                  2025-12-05T01:08:41Z
stssessiontokens.generators.external-secrets.io         2025-12-05T01:08:41Z
uuids.generators.external-secrets.io                    2025-12-05T01:08:41Z
vaultdynamicsecrets.generators.external-secrets.io      2025-12-05T01:08:41Z
webhooks.generators.external-secrets.io                 2025-12-05T01:08:41Z
```

<br/>

https://developer.hashicorp.com/vault/install

```
$ wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
$ echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
$ sudo apt update && sudo apt install vault
```

<br/>

```
$ vault server -dev
```

<br/>

```
// Новый терминал
$ export VAULT_ADDR='http://127.0.0.1:8200'

$ export VAULT_TOKEN='<токен_из_вывода_команды_vault_server>'
```

<br/>

```
$ vault status
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.21.1
Build Date      2025-11-18T13:04:32Z
Storage Type    inmem
Cluster Name    vault-cluster-d4b54403
Cluster ID      37b3d04e-3389-3992-9a91-2377c91fe8a3
HA Enabled      false
```

<br/>

```
$ kubectl create secret generic vault-token \
--from-literal=token=$VAULT_TOKEN \
-n external-secrets
```

<br/>

```
$ kubectl create secret generic vault-token \
--from-literal=token=$VAULT_TOKEN \
-n default
```

<br/>

```
$ vault kv put secret/pacman-secrets pass=pacman
======= Secret Path =======
secret/data/pacman-secrets

======= Metadata =======
Key                Value
---                -----
created_time       2025-12-05T00:57:22.015379331Z
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

// Оригинал не отработал

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: vault-secretstore
  namespace: default
spec:
  provider:
    vault:
      server: "http://vault.local:8200"
      path: "secret"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          key: "token"
          namespace: external-secrets
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: vault-secretstore
  namespace: default
spec:
  provider:
    vault:
      server: "http://vault.local:8200"
      path: "secret"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"  # Секрет в namespace default
          key: "token"
          # namespace: default  # Не указываем, значит будет использоваться namespace SecretStore
EOF
```

<br/>

<br/>

```
// Смотрим актуальную версию API
$ kubectl api-resources | grep ExternalSecret$ kubectl api-resources | grep ExternalSecret
clusterexternalsecrets              ces                external-secrets.io/v1beta1               false        ClusterExternalSecret
externalsecrets                     es                 external-secrets.io/v1beta1               true         ExternalSecret
```

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: pacman-externalsecrets
  namespace: default
spec:
  refreshInterval: "15s"
  secretStoreRef:
    name: vault-secretstore
    kind: SecretStore
  target:
    name: pacman-externalsecrets
  data:
    - secretKey: token
      remoteRef:
        key: secret/pacman-secrets
        property: pass
EOF
```

<br/>

```
// Ссылка на репо с файло, что выше. Но в нем vault-store, а не SecretStore
$ argocd app create pacman \
--repo https://github.com/gitops-cookbook/pacman-kikd-manifests.git \
--path 'k8s/externalsecrets' \
--dest-server https://kubernetes.default.svc \
--dest-namespace default \
--sync-policy auto
```
