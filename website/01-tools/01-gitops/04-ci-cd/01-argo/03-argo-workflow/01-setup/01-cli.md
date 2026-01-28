---
layout: page
title: Инсталляция CLI Argo WorkFlow в ubuntu 22.04
description: Инсталляция CLI Argo WorkFlow в ubuntu 22.04
keywords: devops, containers, kubernetes, argo, WorkFlow, setup
permalink: /tools/gitops/ci-cd/argo/argo-workflow/setup/cli/
---

# Инсталляция CLI Argo WorkFlow в ubuntu 22.04

<br/>

Делаю:  
2026.01.22

<br/>

```
$ cd ~/tmp

// Download the binary
$ curl -sLO "https://github.com/argoproj/argo-workflows/releases/download/v3.7.8/argo-linux-amd64.gz"

// Unzip
$ gunzip "argo-linux-amd64.gz"

// Make binary executable
$ chmod +x "argo-linux-amd64"

// Move binary to path
$ sudo mv "./argo-linux-amd64" /usr/local/bin/argo

// Test installation
$ argo version
```
