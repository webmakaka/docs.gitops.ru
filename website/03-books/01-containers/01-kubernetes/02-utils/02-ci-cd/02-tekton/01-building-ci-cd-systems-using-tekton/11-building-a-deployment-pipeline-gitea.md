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
2026.01.27

<br/>

Если не будет работать, смотреть содержимое коммита: e75e6863a4bc644ef40a79ac7507b1cfd2ea63ea

<br/>

```
// Использую
$ LATEST_KUBERNETES_VERSION=v1.32.2
```

<br/>

## Подготовка

<br/>

### [Установка gitea в minikube](/tools/git/gitea/minikube/setup/)

<br/>

```
$ kubectl create ns my-pipelines-ns
```

<br/>

```
$ export TEKTON_SECRET_TOKEN=$(head -c 24 /dev/random | base64)
$ echo ${TEKTON_SECRET_TOKEN}
$ kubectl create secret generic git-secret --from-literal=secretToken=${TEKTON_SECRET_TOKEN}  -n my-pipelines-ns
```

<br/>

```
//    username: gitea_admin
//    password: r8sA8CPHD9!bt6d
http://gitea.192.168.49.2.nip.io/
```

<br/>

```
New Migration -> https://github.com/PacktPublishing/tekton-book-app
```

<br/>

**gitea_admin / tekton-book-app -> MyProject -> Settings -> Webhooks -> Add webhook -> Gitea**

<br/>

• Target URL: (http://tekton-events.192.168.49.2.nip.io)
• Content type: application/json.
• Secret: Use the secret token you created earlier. You can view your token with the echo ${TEKTON_SECRET_TOKEN} command.

<br/>

Trigger On:

- Push event

<br/>

Add Webhook

<br/>

### Нужно развернуть приложение на стенде. см предыдущий шаг.

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
$ export PROFILE=${USER}-minikube
$ echo ${PROFILE}
$ curl $(minikube --profile ${PROFILE} ip)
```

<br/>

**response:**

```
{"message":"Hello","change":"here"}
```

<br/>

## Основная часть

Let's think about what operations are needed every time you perform a commit on your source code:

<br/>

1. Clone the repository.
2. Install the required libraries.
3. Test the code.
4. Lint the code.
5. Build and push the image.
6. Deploy the application.

<br/>

### Adding an additional task

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
$ kubectl create secret docker-registry dockerhub-secret -n my-pipelines-ns \
    --docker-server=${REGISTRY_SERVER} \
    --docker-username=${REGISTRY_USER} \
    --docker-password=${REGISTRY_PASSWORD}
```

<br/>

```
$ kubectl create serviceaccount tekton-sa -n my-pipelines-ns
```

<br/>

```
$ kubectl patch serviceaccount tekton-sa \
  -n my-pipelines-ns \
  -p '{"secrets": [{"name": "dockerhub-secret"}]}'
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-push
  namespace: my-pipelines-ns
spec:
  params:
    - name: image
      description: Ссылка на образ (например, docker.io/user/app:latest)
  workspaces:
    - name: source
  steps:
    - name: build-and-push
      image: gcr.io/kaniko-project/executor:v1.23.2
      env:
        - name: DOCKER_CONFIG
          value: /kaniko/.docker
      args:
        - --dockerfile=Dockerfile
        - --context=$(workspaces.source.path)
        - --destination=$(params.image)
        - --digest-file=$(results.IMAGE_DIGEST.path)
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
  volumes:
    - name: docker-config
      secret:
        # Секрет должен быть создан командой:
        # kubectl create secret docker-registry dockerhub-secret ...
        secretName: dockerhub-secret
        items:
          - key: .dockerconfigjson
            path: config.json
  results:
    - name: IMAGE_DIGEST
      description: Digest собранного образа
EOF
```

<!--
<br/>

```yaml
$ cat << 'EOF' | kubectl apdeply -f -
apiVersion: tekton.dev/v1
kind: Task
metadata:
  name: build-push
  namespace: my-pipelines-ns
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
``` -->

<br/>

### Using the task catalog

https://hub.tekton.dev/ was officially shut down in January 2026

<br/>

Нужно использовать:

```
https://artifacthub.io/packages/tekton-task/tekton-catalog-tasks/git-clone
https://artifacthub.io/packages/tekton-task/tekton-catalog-tasks/npm
https://artifacthub.io/packages/tekton-task/tekton-catalog-tasks/kubernetes-actions
```

<br/>

### Creating the pipeline

<br/>

Для теста

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: tekton-deploy
  namespace: my-pipelines-ns
spec:
  params:
    - name: repo-url
  workspaces:
    - name: source
  tasks:

    - name: clone
      taskRef:
        resolver: hub
        params:
          - name: catalog
            value: tekton-catalog-tasks
          - name: type
            value: artifact
          - name: name
            value: git-clone
          - name: version
            value: "0.9"
      params:
        - name: url
          value: $(params.repo-url)
      workspaces:
        - name: output
          workspace: source
EOF
```

<br/>

```
$ tkn pipeline start tekton-deploy --use-param-defaults -n my-pipelines-ns
```

<br/>

```
? Value for param `repo-url` of type `string`? http://gitea.192.168.49.2.nip.io/gitea_admin/tekton-book-app.git
? Name for the workspace : source
? Value of the Sub Path :
? Type of the Workspace : emptyDir
? Type of EmptyDir :
```

<br/>

```
$ tkn pipelineruns ls tekton-deploy
NAME                      STARTED          DURATION   STATUS
tekton-deploy-run-kc2z2   50 seconds ago   19s        Succeeded
```

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: tekton-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

<br/>

// Шаг тестирования и линтинга пришлось отключить, т.к. в них ошибки.

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: tekton.dev/v1
kind: Pipeline
metadata:
  name: tekton-deploy
  namespace: my-pipelines-ns
spec:
  params:
    - name: repo-url
    - name: deployment-name
    - name: image
  workspaces:
    - name: source
  tasks:

    - name: clone
      taskRef:
        resolver: hub
        params:
          - name: catalog
            value: tekton-catalog-tasks
          - name: type
            value: artifact
          - name: name
            value: git-clone
          - name: version
            value: "0.9"
      params:
        - name: url
          value: $(params.repo-url)
      workspaces:
        - name: output
          workspace: source

    - name: install
      taskRef:
        resolver: hub
        params:
          - name: catalog
            value: tekton-catalog-tasks
          - name: type
            value: artifact
          - name: name
            value: npm
          - name: version
            value: "0.1"
      params:
        - name: ARGS
          value: ["install"]
        - name: IMAGE
          value: "node:20-alpine"
      workspaces:
        - name: source
          workspace: source
      runAfter:
        - clone

    - name: lint
      taskRef:
        resolver: hub
        params:
          - name: catalog
            value: tekton-catalog-tasks
          - name: type
            value: artifact
          - name: name
            value: npm
          - name: version
            value: "0.1"
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
        resolver: hub
        params:
          - name: catalog
            value: tekton-catalog-tasks
          - name: type
            value: artifact
          - name: name
            value: npm
          - name: version
            value: "0.1"
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
      workspaces:
        - name: source
          workspace: source
      runAfter:
        - test
        - lint

    - name: deploy
      taskRef:
        resolver: hub
        params:
          - name: catalog
            value: tekton-catalog-tasks
          - name: type
            value: artifact
          - name: name
            value: kubernetes-actions
          - name: version
            value: "0.2"
      params:
        - name: args
          value:
            - rollout
            - restart
            - deployment/$(params.deployment-name)
            - -n
            - default
      runAfter:
        - build-push
EOF
```

<br/>

```
$ tkn pipeline start tekton-deploy --use-param-defaults -n my-pipelines-ns
```

<br/>

```
? Value for param `repo-url` of type `string`? http://gitea.192.168.49.2.nip.io/gitea_admin/tekton-book-app.git
? Value for param `deployment-name` of type `string`? tekton-deployment
? Value for param `image` of type `string`? webmakaka/tekton-lab-app
? Value for param `docker-username` of type `string`? webmakaka
? Value for param `docker-password` of type `string`?
Please give specifications for the workspace: source
? Name for the workspace : source
? Value of the Sub Path :
? Type of the Workspace : pvc
? Value of Claim Name : tekton-pvc

```

<br/>

```
$ tkn pipelineruns ls tekton-deploy -n my-pipelines-ns
NAME                      STARTED         DURATION   STATUS
tekton-deploy-run-nbx4f   2 minutes ago   2m3s       Succeeded
```

<br/>

```
$ tkn pipelinerun logs tekton-deploy-run-nbx4f -n my-pipelines-ns
****
[deploy : kubectl] deployment.apps/tekton-deployment restarted
```

<br/>

## Настраиваем обновление по коммиту

<br/>

### Creating the trigger

<br/>

**Нужно поменять <DOCKER_PASSWORD> на свой.**

```
$ export DOCKER_USERNAME=<YOUR_DOCKER_USERNAME>
```

<br/>

```yaml
$ cat << 'EOF' | envsubst | kubectl apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: commit-tt
  namespace: my-pipelines-ns
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
      serviceAccountName: tekton-sa
      pipelineRef:
        name: tekton-deploy
      params:
        - name: repo-url
          value: "$(tt.params.gitrepositoryurl)"
        - name: deployment-name
          value: "tekton-deployment"
        - name: image
          value: "docker.io/${DOCKER_USERNAME}/tekton-lab-app:latest"
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
  namespace: my-pipelines-ns
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
  namespace: my-pipelines-ns
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

<br/>

```yaml
$ cat << 'EOF' | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tekton-gitea-ingress
  namespace: my-pipelines-ns
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
            name: el-listener
            port:
              number: 8080
EOF
```

<br/>

```
// Не нужно создавать! (Скорее всего)
$ kubectl create clusterrolebinding \
  serviceaccounts-cluster-admin \
  --clusterrole=cluster-admin \
  --group=system:serviceaccounts \
  --namespace=my-pipelines-ns
```

<br/>

```
$ kubectl create sa tekton-triggers-example-sa -n my-pipelines-ns

$ kubectl create rolebinding el-admin \
 --clusterrole=cluster-admin \
 --serviceaccount=my-pipelines-ns:tekton-triggers-example-sa \
 --namespace=my-pipelines-ns
```

<br/>

## Проверка работы

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

## Проверяем

<br/>

```
$ kubectl logs -l eventlistener=listener -n my-pipelines-ns
$ kubectl logs  -l app=tekton-triggers-controller --tail=20 -n tekton-pipelines
```

<br/>

```
$ tkn pipelineruns ls tekton-deploy -n my-pipelines-ns
NAME                  STARTED         DURATION   STATUS
tekton-deploy-69n84   4 minutes ago   4m37s      Succeeded
```

<br/>

```
$ tkn pipelinerun -n my-pipelines-ns logs tekton-deploy-rp6kl

****
[deploy : kubectl] deployment.apps/tekton-deployment restarted
```

<br/>

**Появился image:**  
https://hub.docker.com/r/webmakaka/tekton-lab-app

<br/>

```
$ export PROFILE=${USER}-minikube
$ echo ${PROFILE}
$ curl $(minikube --profile ${PROFILE} ip)
```

<br/>

**response:**

```
{"message":"Hello","change":"the end"}
```
