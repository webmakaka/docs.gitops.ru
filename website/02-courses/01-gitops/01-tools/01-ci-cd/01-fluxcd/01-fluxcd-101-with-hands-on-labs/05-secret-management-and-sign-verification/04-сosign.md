---
layout: page
title: FluxCD 101 with Hands-On Labs
description: FluxCD 101 with Hands-On Labs
keywords: linux, kubernetes, FluxCD, Secret Management & Sign Verification, Cosign
permalink: /courses/containers/kubernetes/ci-cd/fluxcd/fluxcd-101-with-hands-on-labs/secret-management-and-sign-verification/сosign/
---

# [Video Course][Siddharth Barahalikar] FluxCD 101 with Hands-On Labs [ENG, 2023][~5h 45m]

<br/>

## Cosign

<br/>

### 10. DEMO - Install Cosign

https://docs.sigstore.dev/cosign/installation/

<br/>

```
$ cd ~/tmp
$ wget "https://github.com/sigstore/cosign/releases/download/v2.0.0/cosign-linux-amd64"
$ sudo mv cosign-linux-amd64 /usr/local/bin/cosign
$ chmod +x /usr/local/bin/cosign
```

<br/>

```
$ cosign version
```

<br/>

```
$ cosign generate-key-pair
```

<br/>

```
$ kubectl -n flux-system create secret generic cosign-pub --from-file=cosign.pub=cosign.pub
```

<br/>

### 11. DEMO - Cosign + OCI Artifacts

<br/>

```
$ cd ~/projects/dev/fluxcd/bb-app-source/
$ git switch 10-demo
```

<br/>

```
$ docker logout

// TOKEN
$ docker login ghcr.io --username webmakaka
```

<br/>

```
$ flux push artifact oci://ghcr.io/wildmakaka/bb-app:7.10.0-$(git rev-parse --short HEAD) \
  --path="./manifests" \
  --source="$(git config --get remote.origin.url)" \
  --revision="7.10.0/$(git rev-parse --short HEAD)"
```

<br/>

```
$ cd ~/tmp
$ cosign sign --key cosign.key ghcr.io/wildmakaka/bb-app@sha256:5e0b86ed6c4cd61e7beebab4b6ea98b21ae1fc9e100fcbb0c229992d308c6bcc
```

<br/>

Появилась подпись в package на github.

<br/>

```
$ cosign verify --key cosign.pub ghcr.io/wildmakaka/bb-app@sha256:5e0b86ed6c4cd61e7beebab4b6ea98b21ae1fc9e100fcbb0c229992d308c6bcc
```

<br/>

```
$ cd ~/projects/dev/fluxcd/block-buster/flux-clusters/dev-cluster/
$ rm 8-demo-*.yaml
```

<br/>

```
$ flux create source oci 10-demo-source-oci-bb-app \
  --url oci://ghcr.io/wildmakaka/bb-app \
  --tag 7.10.0-f0f5090 \
  --secret-ref ghcr-auth \
  --provider generic \
  --export > 10-demo-source-oci-bb-app.yaml
```

<br/>

```
$ flux create secret oci ghcr-auth \
  --url ghcr.io \
  --username wildmakaka \
  --password <GITHUB_TOKEN>
```

<br/>

```
$ kubectl -n flux-system get secrets ghcr-auth
NAME        TYPE                             DATA   AGE
ghcr-auth   kubernetes.io/dockerconfigjson   1      6s
```

<br/>

```
$ kubectl -n flux-system get secrets cosign-pub
NAME         TYPE     DATA   AGE
cosign-pub   Opaque   1      26m
```

<br/>

```
$ vi 10-demo-source-oci-bb-app.yaml
```

Добавляю:

```yaml
verify:
  provider: cosign
  secretRef:
    name: cosign-pub
```

<br/>

```
$ flux create kustomization 10-demo-kustomize-oci-bb-app \
  --source OCIRepository/10-demo-source-oci-bb-app \
  --target-namespace 10-demo \
  --interval 10s \
  --prune false \
  --export > 10-demo-kustomize-oci-bb-app.yaml
```

<br/>

```
$ flux reconcile source git flux-system
```

<br/>

```
$ flux get source oci 10-demo-source-oci-bb-app
NAME                     	REVISION                      	SUSPENDED	READY	MESSAGE
10-demo-source-oci-bb-app	7.10.0-f0f5090@sha256:5e0b86ed	False    	True 	stored artifact for digest '7.10.0-f0f5090@sha256:5e0b86ed'
```

<br/>

```
$ flux get kustomizations 10-demo-kustomize-oci-bb-app
NAME                        	REVISION                      	SUSPENDED	READY	MESSAGE
10-demo-kustomize-oci-bb-app	7.10.0-f0f5090@sha256:5e0b86ed	False    	True 	Applied revision: 7.10.0-f0f5090@sha256:5e0b86ed
```

<br/>

```
$ kubectl -n flux-system get ocirepositories.source.toolkit.fluxcd.io NAME                        URL                               READY   STATUS                                                                                                                AGE
10-demo-source-oci-bb-app   oci://ghcr.io/wildmakaka/bb-app   True    stored artifact for digest '7.10.0-f0f5090@sha256:5e0b86ed6c4cd61e7beebab4b6ea98b21ae1fc9e100fcbb0c229992d308c6bcc'   3m16s

```

<br/>

```
$ kubectl -n flux-system get ocirepositories.source.toolkit.fluxcd.io  -o yaml
***
- lastTransitionTime: "2023-05-01T15:42:23Z"
      message: verified signature of revision 7.10.0-f0f5090@sha256:5e0b86ed6c4cd61e7beebab4b6ea98b21ae1fc9e100fcbb0c229992d308c6bcc
      observedGeneration: 1
      reason: Succeeded
      status: "True"
      type: SourceVerified
***
```

<br/>

```
// OK!
http://192.168.49.2:30010/
```
