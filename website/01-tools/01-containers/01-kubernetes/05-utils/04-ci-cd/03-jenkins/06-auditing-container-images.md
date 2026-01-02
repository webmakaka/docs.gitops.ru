---
layout: page
title: Инсталляция Jenkins в ubuntu 22.04
description: Инсталляция Jenkins в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, Jenkins, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/jenkins/auditing-container-images/
---

# Auditing Container Images

<br/>

**Делаю:**  
2026.01.02

<br/>

Сканируем docker image на уязвимости и Dockerfile на их корректность с т.з. безопасности.

<br/>

```
stage('Image Analysis') {
    parallel {
        stage('Image Linting') {
            steps {
                container('docker-tools') {
                    sh 'dockle webmakaka/dso-demo --exit-code 1'
                }
            }
        }
        stage('Image Scan') {
            steps {
                container('docker-tools') {
                    sh 'trivy image --exit-code 1 webmakaka/dso-demo'
                }
            }
        }
    }
}
```

<br/>
