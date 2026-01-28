---
layout: page
title: HashiCorp Certified Vault Associate
description: HashiCorp Certified Vault Associate
keywords: courses, security, vault
permalink: /courses/security/vault/hashicorp-certified-vault-associate/
---

# [Video Course] HashiCorp Certified Vault Associate

<br/>

```
English | MP4 | AVC 1280×720 | AAC 44KHz 2ch | 6h 38m | 1.71 GB
```

<br/>

https://www.debian.org/distrib/netinst

https://github.com/daveprowse/vac-course

<br/>

UI не заработал.

<br/>

```
// Vault UI is not available in this binary
$ http://127.0.0.1:8200/ui/
```

<br/>

Поэтому в docker

<br/>

https://hub.docker.com/r/hashicorp/vault

<br/>

```
$ docker run --cap-add=IPC_LOCK -e 'VAULT_LOCAL_CONFIG={"storage": {"file": {"path": "/vault/file"}}, "listener": [{"tcp": { "address": "0.0.0.0:8200", "tls_disable": true}}], "default_lease_ttl": "168h", "max_lease_ttl": "720h", "ui": true}' -p 8200:8200 hashicorp/vault server
```

<!--
<br/>

[Устанавливаем GoLang](/dev/go/setup/)

<br/>

**Проще из исходников:**

https://developer.hashicorp.com/vault/docs/install#compiling-from-source

<br/>

**Другие варианты:**

https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-install

<br/>

```
$ vault --version
Vault v1.17.0-beta1 ('f2cd7e2c329c86bbacfde7c20362968a43533621'), built 2024-03-22T10:19:23Z

$ vault -autocomplete-install
``` -->

<br/>

## Lab02

```
$ vault server -dev

$ export VAULT_ADDR='http://127.0.0.1:8200'

$ vault status

$ curl http://127.0.0.1:8200/v1/sys/init
```

<br/>

```
$ vault kv put -mount=secret color-A red=1
$ vault kv get -mount=secret color-A
```

<br/>

```
$ vault kv put -mount=secret color-B orange=2
$ vault kv list secret/
```

<br/>

```
$ vault kv delete -mount=secret color-A
$ vault kv get -mount=secret color-A
$ vault kv undelete -mount=secret -versions=1 color-A
$ vault kv get -mount=secret color-A
```

<br/>

```
// Vault UI is not available in this binary
$ http://127.0.0.1:8200/ui/
```

<br/>

https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-ui

<br/>

### Lab 03

<br/>

```
$ mkdir -p ~/vault/data
$ cd ~/vault/data
```

<br/>

```
$ mkdir -p ~/vault/data
$ cd ~/vault/data
```

<br/>

```
$ vi config.hcl
$ mkdir -p ./vault/data
```

<br/>

```
ui = true
disable_mlock = true

storage "raft" {
  path = "./vault/data"
  node_id = "node1"
}

listener "tcp" {
  address = "<your_IP_address>:8200"
  tls_disable = "true"
}

api_addr = "http://<your_IP_address>:8200"
cluster_addr = "https://<your_IP_address>:8201"
```

<br/>

```
$ vault server --config=config.hcl
```

<br/>

```
$ export VAULT_ADDR='http://192.168.56.11:8200'

$ vault status

$ vault operator init

$ vault operator unseal

// root token
$ vault login

$ vault secrets list

$ vault secrets enable kv

$ vault secrets list
```

<br/>

```
$ vault kv put -mount=kv solar_system planet1=mercury
$ vault kv list kv
$ vault kv get -mount=kv solar_system
```

<br/>

```
$ vault operator seal
```

<br/>

### Lab 04

<br/>

```
$ vault operator init
$ vault operator unseal
$ vault operator unseal
$ vault operator unseal
```

<br/>

```
$ vault auth enable userpass
$ vault auth list
$ vault auth disable userpass
```

<br/>

```
$ vault auth enable -path=local_logins -description="Local Username Authentication" userpass
$ vault auth disable local_logins
$ vault auth enable userpass
```

<br/>

```
$ vault write auth/userpass/users/test_user password=test123
$ vault read auth/userpass/users/test_user
```

<br/>

```
$ vault login -method=userpass \
username=test_user \
password=test123
```

<br/>

```
// [OK!]
$ curl \
  --request POST \
  --data '{"password": "test123"}' \
  http://192.168.56.11:8200/v1/auth/userpass/login/test_user | jq
```

<br/>

### Lab 05 - Vault Policies

<br/>

```
$ vault read sys/policy/default
$ vault read sys/policy/root

$ vault read sys/policy/default >> default.hcl
```

<br/>

```
$ vault server -dev

$ export VAULT_ADDR='http://127.0.0.1:8200'
$ export VAULT_TOKEN=<Root Token>
$ vault status


$ git clone https://github.com/daveprowse/vac-course
$ cd vac-course/lab-05/

$ vault policy write admin admin-policy.hcl
$ vault policy list

$ vault policy read admin
$ vault read sys/policy/admin

$ curl --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/sys/policies/acl/admin | jq
```

<br/>

```
$ vault token create -policy=admin

ADMIN_TOKEN=$(vault token create -format=json -policy="admin" | jq -r ".auth.client_token")

$ echo ${ADMIN_TOKEN}

$ vault token lookup $ADMIN_TOKEN

$ vault token capabilities $ADMIN_TOKEN sys/auth/approle

$ vault token capabilities $ADMIN_TOKEN sys/auth
$ vault token capabilities $ADMIN_TOKEN auth/
```

<br/>

### Lab 06 - Vault Token

<br/>

```
$ vault server -dev
$ export VAULT_ADDR='http://127.0.0.1:8200'
$ export VAULT_TOKEN=<ROOT_TOKEN>
```

<br/>

```
$ vault token create
$ vault token revoke <CREATED_TOKEN>
```

<br/>

```
$ vault token create -ttl=1h -use-limit=3 -policy=default
$ export LIMITED_TOKEN=<CREATED_TOKEN_ID>

$ vault token lookup $LIMITED_TOKEN
$ VAULT_TOKEN=$LIMITED_TOKEN vault token lookup
$ VAULT_TOKEN=$LIMITED_TOKEN vault token lookup
$ VAULT_TOKEN=$LIMITED_TOKEN vault token lookup
$ vault token lookup $LIMITED_TOKEN
```

<br/>

```
$ vault token create -ttl=1h -policy=default
$ vault token renew <CREATED_TOKEN_ID>
$ vault token lookup <CREATED_TOKEN_ID>
```

<br/>

```
$ vault list auth/token/accessors

$ vault token revoke <CREATED_TOKEN_ID>

$ vault list auth/token/accessors

$ vault token revoke ${ROOT_TOKEN}
```

<br/>

### Lab 07 - Vault Leases

AWS не особо сейчас актуален.
