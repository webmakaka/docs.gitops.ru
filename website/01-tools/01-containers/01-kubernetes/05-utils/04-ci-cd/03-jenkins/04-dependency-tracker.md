---
layout: page
title: Инсталляция Jenkins в ubuntu 22.04
description: Инсталляция Jenkins в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, Jenkins, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/jenkins/dependency-tracker/
---

# [FAIL!] SBOM with CycloneDX and Dependency Tracker

<br/>

**Делаю:**  
2026.01.02

```
$ helm repo add dependency-track https://dependencytrack.github.io/helm-charts
$ helm repo update
```

<br/>

```
$ export PROFILE=${USER}-minikube
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)
$ echo dependencytrack.$INGRESS_HOST.nip.io
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
  tls: []
  annotations: {}
  host: dependencytrack.$INGRESS_HOST.nip.io

frontend:
  replicaCount: 1
  service:
    type: NodePort

apiserver:
  resources:
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
$ helm search repo dependency-track
NAME                       	CHART VERSION	APP VERSION	DESCRIPTION
dependency-track/dependency-track	0.40.0       	4.13.6        	Dependency-Track is an intelligent Component An...
```

<br/>

```
$ helm install \
    dependency-track dependency-track/dependency-track \
    --namespace dependency-track \
    --create-namespace \
    --values deptrack.values.yaml \
    --version 0.40.0 \
    --wait
```

<br/>

```
// $ helm uninstall dependency-track --namespace dependency-track
```

<br/>

```
$ helm list -n dependency-track
NAME            	NAMESPACE       	REVISION	UPDATED                                	STATUS  	CHART                  	APP VERSION
dependency-track	dependency-track	1       	2026-01-02 22:20:22.691371548 +0300 MSK	deployed	dependency-track-0.40.0	4.13.6
```

<br/>

```
$ kubectl get pods -n dependency-track
NAME                                         READY   STATUS    RESTARTS   AGE
dependency-track-api-server-0                1/1     Running   0          2m22s
dependency-track-frontend-6866fc6b9b-wt9rh   1/1     Running   0          2m22s
```

<br/>

```

$ kubectl get ingress -n dependency-track
NAME               CLASS   HOSTS         ADDRESS   PORTS   AGE
dependency-track   nginx   example.com             80      33s
```

<br/>

```
// Пришлось патчить HOSTS
$ kubectl patch ingress dependency-track -n dependency-track --type='json' -p='[{"op": "replace", "path": "/spec/rules/0/host", "value": "dependencytrack.'$INGRESS_HOST'.nip.io"}]'
```

<br/>

```
// OK!
// admin /admin
http://dependencytrack.192.168.49.2.nip.io/
```

<br/>

Administration -> Access Management -> Teams -> Automation

<br/>

New API Key:

Also add the following permissions

- POLICY_VIOLATION_ANALYSIS
- PROJECT_CREATION_UPLOAD
- VULNERABILITY_ANALYSIS

<br/>

```
$ kubectl get svc -n dependency-track
NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
dependency-track-api-server   ClusterIP   10.109.140.42   <none>        8081/TCP         52m
dependency-track-frontend     NodePort    10.97.167.253   <none>        8080:30298/TCP   52m
```

<br/>

### Configure Jenkins to Connect with Dependency Tracker

http://192.168.49.2:30264/manage/pluginManager/available

- OWASP Dependency-Track

<br/>

http://192.168.49.2:30264/manage/configure

<br/>

Dependency-Track Backend URL: http://dependency-track-api-server.dependency-track.svc.cluster.local:8081

API Key -> Add

- Kind: Secret text
- Secret: key copied from Dependency-Track earlier
- id: dep-track-api-key

Check Auto Create Projects

<br/>

Test Connection

<!--
http://dependency-track-frontend.dependency-track.svc.cluster.local

-->

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
            dependencyTrackPublisher (projectName: 'sample-spring-app',
                                     projectVersion: '0.0.1',
                                     artifact: 'target/bom.xml',
                                     autoCreateProjects: true,
                                     synchronous: true)
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

<!--


$ kubectl patch svc dependency-track-api-server -n dependency-track --type='json' -p='[{"op": "replace", "path": "/spec/ports/0/port", "value": 8081}]'


$ kubectl run api-test --rm -i --tty --image=curlimages/curl -n dependency-track -- /bin/sh


curl -v http://dependency-track-api-server.dependency-track.svc.cluster.loca
l:8081/api/version -->
<!--
```
cat <<EOF | kubectl apply -n dependency-track -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dependency-track-api-ingress
  namespace: dependency-track
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: dependencytrack-api.$INGRESS_HOST.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: dependency-track-api-server
            port:
              number: 8081
EOF
```

<br/>

```
http://dependencytrack-api.192.168.49.2.nip.io
``` -->
