---
layout: page
title: FluxCD 101 with Hands-On Labs
description: FluxCD 101 with Hands-On Labs
keywords: linux, kubernetes, FluxCD, Notification Controller
permalink: /courses/containers/kubernetes/ci-cd/fluxcd/fluxcd-101-with-hands-on-labs/notification-controller/
---

# [Video Course][Siddharth Barahalikar] FluxCD 101 with Hands-On Labs [ENG, 2023][~5h 45m]

<br/>

## 07. Notification Controller

<br/>

```
$ cd ~/projects/dev/fluxcd/bb-app-source/
$ git switch 02-demo
```

<br/>

```
$ kubectl -n flux-system expose deployment notification-controller \
  --name receiver \
  --port 80 \
  --target-port 9292 \
  --type NodePort
```

<br/>

```
$ kubectl -n flux-system get svc
***
receiver                  NodePort    10.97.144.132    <none>        80:31720/TCP   27s
***
```

<br/>

```
$ kubectl -n flux-system create secret generic github-webhook-token \
  --from-literal=token=secret-token-dont-share
```

<br/>

```
$ flux create receiver github-webhook-receiver \
  --type github \
  --event ping,push \
  --secret-ref github-webhook-token \
  --resource GitRepository/2-demo-source-git-bb-app \
  --export > github-webhook-receiver.yaml
```

<br/>

```
$ flux reconcile source git flux-system
```

<br/>

```
$ flux get receivers
NAME                   	SUSPENDED	READY	MESSAGE
github-webhook-receiver	False    	True 	Receiver initialized for path: /hook/ab09b3ac5436ef9fca17e74ddc7d57b24be7943a1e00ee34f45df11b3b73beda
```

<br/>

```
// Не у меня не заработает!
$ npx localtunnel --port 31720
```

<br/>

GITHUB_USERNAME -> bb-app-source -> Settings -> Webhooks -> Add webhook

<br/>

```
Payload URL:
tunnel + /hook/ab09b3ac5436ef9fca17e74ddc7d57b24be7943a1e00ee34f45df11b3b73beda

Content type:
application/x-www-form-urlencoded

Secret:
secret-token-dont-share
```

<br/>

### 04. DEMO - Alerts & Providers

Лень разбираться.  
Slack заблокирован.
