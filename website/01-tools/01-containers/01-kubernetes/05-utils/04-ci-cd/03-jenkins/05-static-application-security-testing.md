---
layout: page
title: Инсталляция Jenkins в ubuntu 22.04
description: Инсталляция Jenkins в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, Jenkins, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/jenkins/static-application-security-testing/
---

# Static Application Security Testing (SAST)

<br/>

**Делаю:**  
2026.01.01

<br/>

```
- name: slscan
  image: shiftleft/sast-scan
  #imagePullPolicy: Always
  command: ["cat"]
  tty: true
  volumeMounts:
  - name: m2
    mountPath: /root/.m2/
  - name: workspace
    mountPath: /home/jenkins/agent
```

<br/>

```
stage('SAST') {
  steps {
    container('slscan') {
      sh 'scan --type java,depscan --build'
    }
  }

  post {
    success {
      archiveArtifacts(
        allowEmptyArchive: true,
        artifacts: 'reports/*',
        fingerprint: true,
        onlyIfSuccessful: true
      )
    }
  }
}
```
