---
layout: page
title: Ultimate Argo Bootcamp - Argo Events and Argo Image Updater
description: Ultimate Argo Bootcamp - Argo Events and Argo Image Updater
keywords: courses, gitops, argo, Ultimate Argo Bootcamp, Argo Events and Argo Image Updater
permalink: /courses/gitops/tools/ci-cd/argo/ultimate-argo-bootcamp-by-school-of-devops/argo-events-and-argo-image-updater/
---

# [School Of DevOps] Ultimate Argo Bootcamp: Argo Events and Argo Image Updater

<br/>

Делаю:  
2026.01.22

<br/>

https://kubernetes-tutorial.schoolofdevops.com/argo_events/

<br/>

### [Инсталляция Argo Events](/tools/gitops/ci-cd/argo/argo-events/setup/)

### [Инсталляция Argo Image Updater](/tools/gitops/ci-cd/argo/argo-image-updater/setup/)

<br/>

### Create an Argo Events EventSource

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
  name: webhook
  namespace: argo-events
spec:
  service:
    ports:
      - port: 12000
        targetPort: 12000
  webhook:
    example:
      port: "12000"
      endpoint: /example
      method: POST

    github:
      port: "12000"
      endpoint: /github
      method: POST
EOF
```

<br/>

```
// workflow template
$ kubectl get pods -n argo-events | grep eventsource
webhook-eventsource-cxtnt-568686b87d-kfmdf   1/1     Running   0          43s
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: vote-ci-template
  namespace: argo-events
spec:
  entrypoint: main
  serviceAccountName: default
  arguments:
    parameters:
    - name: repo-url
      value: "https://github.com/your-username/your-flask-app.git"
    - name: branch
      value: "main"
    - name: image
      value: "your-registry/your-flask-app"
    - name: dockerfile
      value: "Dockerfile"

  volumeClaimTemplates:
  - metadata:
      name: workspace
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 100Mi

  volumes:
  - name: docker-config
    secret:
      secretName: docker-registry-creds
      items:
        - key: .dockerconfigjson
          path: config.json

  templates:
  - name: main
    inputs:
      parameters:
      - name: repo-url
      - name: branch
      - name: image
      - name: dockerfile
    steps:
    - - name: clone
        template: clone
        arguments:
          parameters:
          - name: repo-url
            value: "{{inputs.parameters.repo-url}}"
          - name: branch
            value: "{{inputs.parameters.branch}}"
    - - name: build
        template: build
    - - name: test
        template: test
    - - name: imagebuild
        template: imagebuild
        arguments:
          parameters:
          - name: commit-sha
            value: "{{steps.clone.outputs.parameters.commit-sha}}"
          - name: image
            value: "{{inputs.parameters.image}}"
          - name: dockerfile
            value: "{{inputs.parameters.dockerfile}}"

  # Clone task
  - name: clone
    inputs:
      parameters:
      - name: repo-url
      - name: branch
    script:
      image: alpine/git
      command: [sh]
      source: |
        #!/bin/sh
        git clone --branch {{inputs.parameters.branch}} {{inputs.parameters.repo-url}} /workspace
        cd /workspace
        COMMIT_SHA=$(git rev-parse --short HEAD)
        echo $COMMIT_SHA > /workspace/commit-sha.txt
      volumeMounts:
      - name: workspace
        mountPath: /workspace
    outputs:
      parameters:
      - name: commit-sha
        valueFrom:
          path: /workspace/commit-sha.txt

  # Build task
  - name: build
    script:
      image: python:3.9
      command: ["sh"]
      source: |
        #!/bin/sh
        cd /workspace
        pip install -r requirements.txt
      volumeMounts:
      - name: workspace
        mountPath: /workspace

  # Test task
  - name: test
    script:
      image: python:3.9
      command: ["sh"]
      source: |
        #!/bin/sh
        cd /workspace
        pip install nose
        nosetests
      volumeMounts:
      - name: workspace
        mountPath: /workspace

  # Image build and publish task using Kaniko
  - name: imagebuild
    inputs:
      parameters:
      - name: commit-sha
      - name: image
      - name: dockerfile
    container:
      image: gcr.io/kaniko-project/executor:latest
      command: ["/kaniko/executor"]
      args:
      - --dockerfile=/workspace/{{inputs.parameters.dockerfile}}
      - --context=/workspace
      - --destination={{inputs.parameters.image}}:{{inputs.parameters.commit-sha}}
      - --force
      volumeMounts:
      - name: workspace
        mountPath: /workspace
      - name: docker-config
        mountPath: /kaniko/.docker
      env:
      - name: DOCKER_CONFIG
        value: /kaniko/.docker
EOF
```

<br/>

```
$ kubectl get workflowtemplate -A
NAMESPACE     NAME               AGE
argo-events   vote-ci-template   22s
```

<br/>

```
$ argo template list -A
NAMESPACE     NAME
argo-events   vote-ci-template
```

<br/>

```
$ {
    export REGISTRY_SERVER=https://index.docker.io/v1/
    export REGISTRY_USER=webmakaka
    export REGISTRY_PASSWORD=webmakaka-password

    echo ${REGISTRY_SERVER}
    echo ${REGISTRY_USER}
    echo ${REGISTRY_PASSWORD}
}
```

<br/>

```
$ kubectl create secret -n argo-events docker-registry docker-registry-creds \
    --docker-server=${REGISTRY_SERVER} \
    --docker-username=${REGISTRY_USER} \
    --docker-password=${REGISTRY_PASSWORD}
```

<br/>

### Add sensor

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Sensor
metadata:
  name: polling-sensor
  namespace: argo-events
spec:
  template:
    serviceAccountName: operate-workflow-sa
  dependencies:
    - name: poll-github
      eventSourceName: webhook
      eventName: github
  triggers:
    - template:
        name: launch-vote-ci
        argoWorkflow:
          operation: submit
          source:
            resource:
              apiVersion: argoproj.io/v1alpha1
              kind: Workflow
              metadata:
                generateName: ci-pipeline-
              spec:
                workflowTemplateRef:
                  name: vote-ci-template
                arguments:
                  parameters:
                  - name: repo-url
                    value: "https://github.com/wildmakaka/vote.git"
                  - name: branch
                    value: "main"
                  - name: image
                    value: "webmakaka/vote"
                  - name: dockerfile
                    value: "Dockerfile"
EOF
```

<br/>

```
// too many open files
// чтобы ушла до перезагрузки
$ sudo sysctl fs.inotify.max_user_instances=8192
$ sudo sysctl fs.inotify.max_user_watches=524288
```

<br/>

```
$ kubectl get pods -n argo-events
NAME                                           READY   STATUS    RESTARTS   AGE
controller-manager-59884fd695-qgnxk            1/1     Running   0          35m
eventbus-default-stan-0                        2/2     Running   0          34m
eventbus-default-stan-1                        2/2     Running   0          34m
eventbus-default-stan-2                        2/2     Running   0          34m
events-webhook-588ccdfcb5-bcpg9                1/1     Running   0          35m
polling-sensor-sensor-mj4bg-64f6f77d58-f9fgk   1/1     Running   0          74s
webhook-eventsource-cxtnt-568686b87d-kfmdf     1/1     Running   0          22m
```

<br/>

```
$ kubectl logs -n argo-events -l "controller=sensor-controller"
```

<br/>

### Deploy GitHub Poller

<br/>

```
$ kubectl create secret generic github-token-secret \
    --from-literal=token=<GITHUB_ACCESS_TOKEN>
```

<br/>

```
// OK!
https://localhost:2746/workflows/argo-events
```

<br/>

```yaml
$ cat << EOF | kubectl apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: github-polling-job
spec:
  schedule: "* * * * *"  # Poll every minute
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: poller
            image: schoolofdevops/github-poller:latest
            env:
            - name: GITHUB_API_URL
              value: "https://api.github.com/repos/wildmakaka/vote/commits"
            - name: GITHUB_TOKEN
              valueFrom:
                secretKeyRef:
                  name: github-token-secret
                  key: token
            - name: LAST_COMMIT_FILE
              value: "/data/last_commit.txt"
            - name: ARGO_EVENT_SOURCE_URL
              value: "http://webhook-eventsource-svc.argo-events.svc.cluster.local:12000/github"
            volumeMounts:
            - name: commit-storage
              mountPath: /data
          restartPolicy: OnFailure
          volumes:
          - name: commit-storage
            persistentVolumeClaim:
              claimName: poller-pvc  # Use a PVC to persist the last commit file
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: poller-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
EOF
```

<br/>

```
$ kubectl get cronjobs
NAME                 SCHEDULE    TIMEZONE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
github-polling-job   * * * * *   <none>     False     1        5s              80s
```

<br/>

```
$ kubectl -n argo port-forward --address 0.0.0.0 svc/argo-server 2746:2746 > /dev/null
```

<br/>

Появился новый image (делал коммит в репо):  
https://hub.docker.com/r/webmakaka/vote/tags

<br/>

### Image Updater

<br/>

https://kubernetes-tutorial.schoolofdevops.com/argo_iamge_updater/

<br/>

```
$ kubectl -n argocd create secret generic git-creds \
  --from-literal=username=wildmakaka \
  --from-literal=password=<GITHUB_ACCESS_TOKEN>
```

<br/>

```
$ kubectl get application -n argocd

$ kubectl describe application -n argocd vote-staging
```

<br/>

```yaml
$ cat > ~/tmp/argo_applications_vote-staging_patch.yaml <<'EOF'
metadata:
  annotations:
    argocd-image-updater.argoproj.io/git-branch: main
    argocd-image-updater.argoproj.io/image-list: myimage=webmakaka/vote
    argocd-image-updater.argoproj.io/myimage.allow-tags: regexp:^[0-9a-f]{7}$
    argocd-image-updater.argoproj.io/myimage.ignore-tags: latest, dev
    argocd-image-updater.argoproj.io/myimage.update-strategy: latest
    argocd-image-updater.argoproj.io/myimage.kustomize.image-name: schoolofdevops/vote
    argocd-image-updater.argoproj.io/myimage.force-update: "true"
    argocd-image-updater.argoproj.io/write-back-method: git:secret:argocd/git-creds
    argocd-image-updater.argoproj.io/write-back-target: "kustomization:../base"
EOF
```

<br/>

```
image-list - где искать образ
kustomize.image-name - что менять в манифестах
```

<br/>

```
$ kubectl patch application --type=merge -n argocd vote-staging --patch-file ~/tmp/argo_applications_vote-staging_patch.yaml
```

<br/>

```
$ kubectl get application vote-staging -n argocd -o jsonpath='{.metadata.annotations}' | jq .
```

<br/>

```
// логи
$ kubectl logs -f -l "app.kubernetes.io/name=argocd-image-updater" -n argocd
```

<br/>

Обновился tag в репо wildmakaka.  
Потом спустя минут 10 обновились images в ns staging  
Делаем MR в release  
Потом спустя минут 10 обновились images в ns prod
