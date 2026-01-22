---
layout: page
title: FluxCD 101 with Hands-On Labs
description: FluxCD 101 with Hands-On Labs
keywords: linux, kubernetes, FluxCD, Secret Management & Sign Verification, Mozilla SOPS
permalink: /courses/containers/kubernetes/ci-cd/fluxcd/fluxcd-101-with-hands-on-labs/secret-management-and-sign-verification/mozilla-sops/
---

# [Video Course][Siddharth Barahalikar] FluxCD 101 with Hands-On Labs [ENG, 2023][~5h 45m]

<br/>

## Mozilla SOPS

<br/>

### 06. DEMO - Mozilla SOPS - Admin

Настраивается админом

<br/>

```
$ cd ~/projects/dev/fluxcd/bb-app-source/infrastructure/
```

<br/>

```
$ gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 3072
Subkey-Type: 1
Subkey-Length: 3072
Expire-Date: 0
Name-Comment: k8s
Name-Real: dev.us-e1.k8s
Name-Email: admin@bb.com
EOF
```

<br/>

```
gpg: key 19E6D3BCD21F8CCF marked as ultimately trusted
gpg: directory '/home/marley/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/home/marley/.gnupg/openpgp-revocs.d/F4CAF8D8C08255FA4125215E19E6D3BCD21F8CCF.rev'
```

<br/>

```
$ gpg --list-public-keys
$ gpg --list-secret-keys
```

<br/>

```
// 19E6D3BCD21F8CCF при генерации в output
$ gpg --export-secret-keys --armor 19E6D3BCD21F8CCF
```

<br/>

```
$ cd ~/projects/dev/fluxcd/bb-app-source/infrastructure/
$ mkdir sops
$ cd sops
$ gpg --export-secret-keys --armor 19E6D3BCD21F8CCF > sops-gpg.key
$ gpg --export --armor 19E6D3BCD21F8CCF > sops-gpg.pub
```

<br/>

```
$ kubectl -n flux-system create secret generic sops-gpg --from-file=sops.asc=sops-gpg.key
```

<br/>

```
$ rm sops-gpg.key
```

<br/>

```
$ gpg --delete-secret-and-public-keys 19E6D3BCD21F8CCF
```

<br/>

commit / push

<br/>

### 07. DEMO - Mozilla SOPS - Developer

Настраивается девелопером. Вроде как админ сгенерил, удалил у себя а девелоперу передал pubic key.

<br/>

```
$ cd ~/projects/dev/fluxcd/bb-app-source/infrastructure/database
$ rm sealed-secret-mysql.yaml
```

<br/>

```
$ vi secret-mysql.yaml
```

<br/>

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-mysql
  namespace: database
stringData:
  password: mysql-password-0123456789
```

<br/>

```
$ gpg --import sops/sops-gpg.pub
```

<br/>

```
$ gpg --list-public-keys 19E6D3BCD21F8CCF
```

<br/>

**Устанавливаем sops**

<br/>

https://github.com/mozilla/sops/releases

<br/>

```
$ cd ~/tmp
$ wget https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64
$ chmod +x sops-v3.7.3.linux.amd64
$ sudo mv sops-v3.7.3.linux.amd64 /usr/bin/sops
```

<br/>

```
$ cd ~/projects/dev/fluxcd/bb-app-source/infrastructure/database
$ sops --encrypt \
  --encrypted-regex="^(data|stringData)$" \
  --pgp 19E6D3BCD21F8CCF \
  --in-place secret-mysql.yaml
```

<br/>

```
$ kubectl -n database get secrets
NAME           TYPE     DATA   AGE
secret-mysql   Opaque   1      146m
```

<br/>

```
$ flux reconcile source git infra-source-git
$ flux reconcile kustomization infra-database-kustomize-git-mysql
$ flux resume kustomization infra-database-kustomize-git-mysql
```

<br/>

```
// Должен обновиться, но у меня нет
$ kubectl -n database get secrets
```

<br/>

```
$ kubectl -n database get secrets secret-mysql -o json | jq .data.password -r | base64 -d
```

<br/>

```
$ kubectl -n flux-system get secrets sops-gpg
NAME       TYPE     DATA   AGE
sops-gpg   Opaque   1      42m
```

<br/>

```
$ vi infra-database-kustomize-git-mysql.yml
```

Добавить на уровне targetNamespace: database

```yaml
decription:
  provider: sops
  secretRef:
    name: sops-gpg
```

<br/>

commit / push

<br/>

```
$ flux reconcile source git flux-system
$ flux reconcile kustomization infra-database-kustomize-git-mysql
```

<br/>

```
$ kubectl -n flux-system get secrets
```

<br/>

```
// Д.б. понятный пароль из-за того, что добавили блок decription
$ kubectl -n database get secrets secret-mysql -o json | jq .data.password -r | base64 -d
```
