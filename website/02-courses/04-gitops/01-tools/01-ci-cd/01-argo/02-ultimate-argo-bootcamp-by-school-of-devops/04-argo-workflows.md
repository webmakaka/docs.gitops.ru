---
layout: page
title: Ultimate Argo Bootcamp - Argo Workflows
description: Ultimate Argo Bootcamp - Argo Workflows
keywords: courses, gitops, argo, Ultimate Argo Bootcamp, Argo Workflows
permalink: /courses/gitops/tools/ci-cd/argo/ultimate-argo-bootcamp-by-school-of-devops/argo-workflows/
---

# [School Of DevOps] Ultimate Argo Bootcamp: Argo Workflows

<br/>

Делаю:  
2026.01.22

<br/>

Проект, который собираем:  
https://github.com/sfd226/vote

<br/>

### [Инсталляция Argo WorkFlow](/tools/containers/kubernetes/utils/ci-cd/argo/argo-workflow/setup/)

<br/>

```
// OK!
https://localhost:2746/workflows/argo
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
$ kubectl create secret -n argo docker-registry docker-registry-creds \
    --docker-server=${REGISTRY_SERVER} \
    --docker-username=${REGISTRY_USER} \
    --docker-password=${REGISTRY_PASSWORD}
```

<br/>

```yaml
$ cat > ~/tmp/vote-ci-workflow.yaml <<'EOF'
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: vote-ci-
spec:
  entrypoint: main
  arguments:
    parameters:
      - name: repo-url
        value: "https://github.com/xxxxxx/vote.git"
      - name: branch
        value: "main"
      - name: image
        value: "yyyyyy/vote"
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
$ argo submit -n argo --watch ~/tmp/vote-ci-workflow.yaml \
    -p repo-url=https://github.com/wildmakaka/vote.git \
    -p branch=main \
    -p image=webmakaka/vote \
    -p dockerfile=Dockerfile
```

<br/>

```
$ argo logs -n argo @latest
```

<br/>

```
$ argo list -n argo
NAME            STATUS      AGE   DURATION   PRIORITY   MESSAGE
vote-ci-6v2r2   Succeeded   17m   12m        0
```

<br/>

```
$ argo logs -n argo vote-ci-6v2r2
```

<br/>

```
$ argo list -n argo
NAME            STATUS      AGE   DURATION   PRIORITY   MESSAGE
vote-ci-6v2r2   Succeeded   17m   12m        0
```

<br/>

Появиляс image:  
https://hub.docker.com/r/webmakaka/vote/tags
