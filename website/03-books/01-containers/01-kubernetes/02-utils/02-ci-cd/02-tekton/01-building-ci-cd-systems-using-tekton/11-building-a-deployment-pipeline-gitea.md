---
layout: page
title: Building CI/CD Systems Using Tekton - Building a Deployment Pipeline
description: Building CI/CD Systems Using Tekton - Building a Deployment Pipeline
keywords: books, ci-cd, tekton, Building a Deployment Pipeline
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/building-a-deployment-pipeline-gitea/
---

# [OK!] Chapter 13. Building a Deployment Pipeline

<br/>

**Делаю:**  
2025.12.13

<br/>

```
// Использую
$ LATEST_KUBERNETES_VERSION=v1.32.2
```

<br/>

Let's think about what operations are needed every time you perform a commit on your source code:

<br/>

1. Clone the repository.
2. Install the required libraries.
3. Test the code.
4. Lint the code.
5. Build and push the image.
6. Deploy the application.

<br/>

### Using the task catalog

https://hub.tekton.dev/

<br/>

```
$ {
    tkn hub install task git-clone
    tkn hub install task npm
    tkn hub install task kubernetes-actions
}
```

<br/>

```
$ kubectl get task npm -o yaml > npm-task.yaml
$ vi npm-task.yaml
```

<br/>

```
default: docker.io/library/node:18-alpine
```

<br/>

```
$ kubectl apply -f npm-task.yaml
```

<br/>

### Adding an additional task

<br/>

Можно попробовать использовать task "docker build task".
Но требуется обращение к Docker демону по сокету (или как-то так) и не работает во всех окружениях.

Предлагают использовать Buildah

https://buildah.io/

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-push
spec:
  params:
    - name: image
    - name: username
    - name: password
  workspaces:
    - name: source
  steps:
    - name: build-image
      image: quay.io/buildah/stable:v1.23.3
      securityContext:
        privileged: true
      script: |
        cd $(workspaces.source.path)
        buildah bud --layers -t $(params.image) .
        buildah login -u $(params.username) -p $(params.password) docker.io
        buildah push $(params.image)
EOF
```

<br/>

### Creating the pipeline

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: tekton-deploy
spec:
  params:
    - name: repo-url
    - name: deployment-name
    - name: image
    - name: docker-username
    - name: docker-password
  workspaces:
    - name: source
  tasks:

    - name: clone
      taskRef:
        name: git-clone
      params:
        - name: url
          value: $(params.repo-url)
      workspaces:
        - name: output
          workspace: source

    - name: install
      taskRef:
        name: npm
      params:
        - name: ARGS
          value:
            - install
      workspaces:
        - name: source
          workspace: source
      runAfter:
        - clone

    - name: lint
      taskRef:
        name: npm
      params:
        - name: ARGS
          value:
            - run
            - lint
      workspaces:
        - name: source
          workspace: source
      runAfter:
        - install

    - name: test
      taskRef:
        name: npm
      params:
        - name: ARGS
          value:
            - run
            - test
      workspaces:
        - name: source
          workspace: source
      runAfter:
        - install

    - name: build-push
      taskRef:
        name: build-push
      params:
        - name: image
          value: $(params.image)
        - name: username
          value: $(params.docker-username)
        - name: password
          value: $(params.docker-password)
      workspaces:
        - name: source
          workspace: source
      runAfter:
        - test
        - lint

    - name: deploy
      taskRef:
        name: kubernetes-actions
      params:
        - name: args
          value:
            - rollout
            - restart
            - deployment/$(params.deployment-name)
      runAfter:
        - build-push
EOF
```

<br/>

### Creating the trigger

<br/>

```
$ export TEKTON_SECRET_TOKEN=$(head -c 24 /dev/random | base64)
$ echo ${TEKTON_SECRET_TOKEN}
$ kubectl create secret generic git-secret --from-literal=secretToken=${TEKTON_SECRET_TOKEN}
```

<br/>

**Нужно не забыть заменить <DOCKER_PASSWORD> на свой.**

<br/>

```yaml
$ cat << 'EOF' | envsubst | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: commit-tt
spec:
  params:
  - name: gitrepositoryurl
    description: The git repository url
  resourcetemplates:
  - apiVersion: tekton.dev/v1
    kind: PipelineRun
    metadata:
      generateName: tekton-deploy-
    spec:
      pipelineRef:
        name: tekton-deploy
      params:
        - name: repo-url
          value: $(tt.params.gitrepositoryurl)
        - name: deployment-name
          value: tekton-deployment
        - name: image
          value: ${DOCKER_USERNAME}/tekton-lab-app
        - name: docker-username
          value: ${DOCKER_USERNAME}
        - name: docker-password
          value: <DOCKER_PASSWORD>
      workspaces:
        - name: source
          volumeClaimTemplate:
            spec:
              accessModes:
              - ReadWriteOnce
              resources:
                requests:
                  storage: 1Gi
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: event-binding
spec:
  params:
    - name: gitrepositoryurl
      value: $(body.repository.clone_url)
EOF
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1alpha1
kind: EventListener
metadata:
  name: listener
spec:
  serviceAccountName: tekton-triggers-example-sa
  triggers:
    - name: trigger
      bindings:
        - ref: event-binding
      template:
        ref: commit-tt
      interceptors:
        - github:
            secretRef:
              secretName: git-secret
              secretKey: secretToken
            eventTypes:
              - push
EOF
```

<!-- <br/>

```
????
$ kubectl port-forward svc/el-listener 8080
``` -->

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tekton-gitea-ingress
  namespace: default  # Указать namespace где находится сервис
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: tekton-events.192.168.49.2.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: el-listener  # Правильное имя сервиса!
            port:
              number: 8080
EOF
```

<br/>

```
$ kubectl create clusterrolebinding \
  serviceaccounts-cluster-admin \
  --clusterrole=cluster-admin \
  --group=system:serviceaccounts
```

<br/>

### Нужно развернуть приложение

<br/>

// Поправить <YOUR_USERNAME>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tekton-deployment
spec:
  selector:
    matchLabels:
      app: trigger-demo
  template:
    metadata:
      labels:
        app: trigger-demo
    spec:
      containers:
      - name: tekton-pod
        image: <YOUR_USERNAME>/tekton-lab-app
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: tekton-svc
spec:
  selector:
    app: trigger-demo
  ports:
  - port: 3000
    protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tekton-ingress
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: tekton-svc
            port:
              number: 3000
EOF
```

<br/>

```
Fork -> https://github.com/PacktPublishing/tekton-book-app
```

<br/>

**Github -> MyProject -> Settings -> Webhooks -> Add webhook**

<br/>

• Payload URL: (http://tekton-events.192.168.49.2.nip.io)
• Content type: application/json.
• Secret: Use the secret token you created earlier. You can view your token with the echo ${TEKTON_SECRET_TOKEN} command.

<br/>

Which events would you like to trigger this webhook?

- Just the push event

<br/>

Add Webhook

<br/>

Вносим изменения в исходный код.

http://gitea.192.168.49.2.nip.io/gitea_admin/tekton-book-app/src/branch/main/server.js

<br/>

```
change: "here"
```

<br/>

Меняем на

```
change: "the end"
```

<br/>

```
Commit changes
```

<br/>

```
$ tkn pipelineruns ls tekton-deploy
NAME                  STARTED         DURATION   STATUS
tekton-deploy-69n84   4 minutes ago   4m37s      Succeeded
```

<br/>

```
$ tkn pipelinerun logs tekton-deploy-blqts

****
[deploy : kubectl] deployment.apps/tekton-deployment restarted
```

<br/>

**Появился image:**  
https://hub.docker.com/r/webmakaka/tekton-lab-app

<br/>

```
// Убеждаемся, что значение профиля установлено
$ echo ${PROFILE}
$ curl $(minikube --profile ${PROFILE} ip)
```

<br/>

**response:**

```
{"message":"Hello","change":"the end"}
```
