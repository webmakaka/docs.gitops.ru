---
layout: page
title: Инсталляция Jenkins в ubuntu 22.04
description: Инсталляция Jenkins в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, Jenkins, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/jenkins/dependency-tracker/
---

# SBOM with CycloneDX and Dependency Tracker

<br/>

**Делаю:**  
2025.12.26

```
$ helm repo add evryfs-oss https://evryfs.github.io/helm-charts/
$ helm repo update
```

<br/>

```
$ kubectl create namespace dependency-track
```

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > deptrack.values.yaml <<EOF
ingress:
  enabled: true
  tls:
    enabled: false
    secretName: ""
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    ## allow large bom.xml uploads:
    # nginx.ingress.kubernetes.io/proxy-body-size: 10m
  host: dependencytrack.example.org

frontend:
  replicaCount: 1
  service:
    type: NodePort

apiserver:
  resources:
    # https://docs.dependencytrack.org/getting-started/deploy-docker/
    requests:
      cpu: 1
      memory: 3000Mi
    limits:
      cpu: 2
      memory: 7Gi
EOF
```

<br/>

```
$ helm install dependency-track --values deptrack.values.yaml --namespace dependency-track evryfs-oss/dependency-track
$ helm list -n dependency-track
```

<br/>

```
$ kubectl get pods -n dependency-track
```

<br/>

```
// hosts
192.168.49.2 dependencytrack.example.org
```

<br/>

```
// OK!
// admin /admin
http://dependencytrack.example.org/change-password?redirect=%2Fdashboard
```

<br/>

Administration -> Access Management -> Teams -> Automation

<br/>

Copy the API Key: AjqsiQwaewMwD1AoaZRaCHBJOR2D7XPu

Also add the following permissions

PROJECT_CREATION_UPLOAD
POLICY_VIOLATION_ANALYSIS
VULNERABILITY_ANALYSIS

<br/>

### Configure Jenkins to Connect with Dependency Tracker

http://192.168.49.2:30264/manage/pluginManager/available

- OWASP Dependency-Track

<br/>

http://192.168.49.2:31272/manage/configure

<br/>

Dependency-Track URL : http://dependency-track-apiserver.dependency-track.svc.cluster.local

API Key ->

Kind - Secret
Secret: key copied from Dependency-Track earlier
id: dep-track-api-key

Check Auto Create Projects Box

<br/>

Test Connection ->

The detected version 4.6.3 is older than the required version 4.12.0 and is no longer supported

<br/>

jenkinsfile после

"OSS License Checker"

```
stage('Generate SBOM') {
    steps {
        container('maven') {
            sh 'mvn org.cyclonedx:cyclonedx-maven-plugin:makeAggregateBom'
        }
    }
    post {
        success {
            dependencyTrackPublisher projectName: 'sample-spring-app',
                                     projectVersion: '0.0.1',
                                     artifact: 'target/bom.xml',
                                     autoCreateProjects: true,
                                     synchronous: true
            archiveArtifacts (
                allowEmptyArchive: true,
                artifacts: 'target/bom.xml',
                fingerprint: true,
                onlyIfSuccessful: true
            )
        }
    }
}
```
