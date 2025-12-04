---
layout: page
title: GitOps Cookbook - Cloud Native CI/CD - Tekton - Using Tekton Triggers to Compile and Package an Application Automatically When a Change Occurs on Git
description: Запуск Pipeline для компиляции, упаковки и деплоя приложения с помощью tekton в kubernetes при изменении в git
keywords: books, gitops, cloud-native-cicd, tekton, Using Tekton Triggers to Compile and Package an Application Automatically When a Change Occurs on Git
permalink: /books/gitops/gitops-cookbook/cloud-native-cicd/tekton/using-tekton-triggers-to-compile-and-package-an-application-automatically-when-a-change-occurs-on-git/
---

<br/>

# [Book] [OK!] GitOps Cookbook: 06. Cloud Native CI/CD: Tekton: 6.8 Using Tekton Triggers to Compile and Package an Application Automatically When a Change Occurs on Git

<br/>

**Задача:**  
Запуск Pipeline для компиляции, упаковки и деплоя приложения с помощью tekton в kubernetes при изменении в git

<br/>

**Делаю:**  
2025.12.02

<br/>

https://tekton.dev/docs/getting-started/triggers/

<br/>

```
// Удаляем созданные на прошлом шагу
$ kubectl delete svc tekton-greeter
$ kubectl delete deployment tekton-greeter
```

<br/>

Уже созданы на предыдущем шаге:

- Secret на hub.docker.com
- ServiceAccount
- Role
- RoleBinding
- Pipeline
- PersistentVolumeClaim

<br/>

```
// Выполнить команду. Без нее не команда kubectl port-forward svc/el-tekton-greeter-eventlistener 8080 не отработает

// This will create a new ServiceAccount named tekton-triggers-sa that has the permissions needed to interact with the Tekton Pipelines component.
$ kubectl apply -f https://raw.githubusercontent.com/tektoncd/triggers/main/examples/rbac.yaml
```

<br/>

**В файле rbac.yaml:**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tekton-triggers-example-sa
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: triggers-example-eventlistener-binding
subjects:
  - kind: ServiceAccount
    name: tekton-triggers-example-sa
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-roles
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: triggers-example-eventlistener-clusterbinding
subjects:
  - kind: ServiceAccount
    name: tekton-triggers-example-sa
    namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: tekton-triggers-eventlistener-clusterroles
```

<br/>

```
$ kubectl get pods --namespace tekton-pipelines
NAME                                                READY   STATUS    RESTARTS   AGE
tekton-events-controller-77857f9b75-2dgtj           1/1     Running   0          8m14s
tekton-pipelines-controller-6987c95899-stkt8        1/1     Running   0          8m14s
tekton-pipelines-webhook-7f556bb7d9-6z9jt           1/1     Running   0          8m14s
tekton-triggers-controller-5b6d5f54b7-h6gsm         1/1     Running   0          7m50s
tekton-triggers-core-interceptors-f58696689-gwrpf   1/1     Running   0          7m45s
tekton-triggers-webhook-689688fc54-bvmq5            1/1     Running   0          7m50s
```

<br/>

```
// Пока все beta
$ kubectl api-resources | grep TriggerTemplate
triggertemplates                    tt                                     triggers.tekton.dev/v1beta1       true         TriggerTemplate


$ kubectl api-resources | grep TriggerBinding

$ kubectl api-resources | grep EventListener
```

```yaml
$ cat << 'EOF' | kubectl create -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: tekton-greeter-triggertemplate
spec:
  params:
    - name: git-revision
    - name: git-commit-message
    - name: git-repo-url
    - name: git-repo-name
    - name: content-type
    - name: pusher-name
  resourcetemplates:
  - apiVersion: tekton.dev/v1beta1
    kind: PipelineRun
    metadata:
      labels:
        tekton.dev/pipeline: tekton-greeter-pipeline-hub
      name: tekton-greeter-pipeline-webhook-1
    spec:
      serviceAccountName: tekton-deployer-sa
      params:
        - name: GIT_REPO
          value: $(tt.params.git-repo-url)
        - name: GIT_REF
          value: $(tt.params.git-revision)
        - name: DESTINATION_IMAGE
          value: webmakaka/tekton-greeter:latest
        - name: CONTEXT_DIR
          value: "quarkus"
        - name: IMAGE_DOCKERFILE
          value: "quarkus/Dockerfile"
        - name: IMAGE_CONTEXT_DIR
          value: "quarkus"
        - name: SCRIPT
          value: |
            kubectl create deploy tekton-greeter --image=webmakaka/tekton-greeter:latest
      pipelineRef:
        name: tekton-greeter-pipeline-hub
      workspaces:
      - name: app-source
        persistentVolumeClaim:
          claimName: app-source-pvc
      - name: maven-settings
        emptyDir: {}
---
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: tekton-greeter-triggerbinding
spec:
  params:
  - name: git-repo-url
    value: $(body.repository.clone_url)
  - name: git-revision
    value: $(body.after)
---
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: tekton-greeter-eventlistener
spec:
  serviceAccountName: tekton-triggers-example-sa
  triggers:
  - bindings:
    - ref: tekton-greeter-triggerbinding
    template:
      ref: tekton-greeter-triggertemplate
EOF
```

<br/>

```
// Команды, которые помогут почистить созданное
$ {
  kubectl delete TriggerTemplate tekton-greeter-triggertemplate
  kubectl delete TriggerBinding tekton-greeter-triggerbinding
  kubectl delete EventListener tekton-greeter-eventlistener
  kubectl delete deployment tekton-greeter
  kubectl delete pipelinerun tekton-greeter-pipeline-webhook-1
}
```

<br/>

### Запуск

If you are running your Git server outside the cluster (e.g., GitHub or GitLab), you need to expose the Service, for example, with an Ingress. Afterwards you can configure webhooks on your Git server using the EventListener URL associated to your Ingress.

<br/>

We can just simulate the webhook as it would come from the Git server

```
$ kubectl port-forward svc/el-tekton-greeter-eventlistener 8080
```

<br/>

```
$ curl -X POST \
  http://localhost:8080 \
  -H 'Content-Type: application/json' \
  -d '{ "after": "d9291c456db1ce29177b77ffeaa9b71ad80a50e6", "repository": { "clone_url" : "https://github.com/gitops-cookbook/tekton-tutorial-greeter.git" } }' | jq
```

<br/>

```
{
  "eventListener": "tekton-greeter-eventlistener",
  "namespace": "default",
  "eventListenerUID": "b1d6958c-e806-4cfc-a75c-3fbc5aaa1a23",
  "eventID": "efe17237-8bd5-4e74-9c5f-7354ace131ce"
}
```

<br/>

```
$ tkn pipeline ls
NAME                          AGE             LAST RUN                            STARTED         DURATION   STATUS
tekton-greeter-pipeline-hub   9 minutes ago   tekton-greeter-pipeline-webhook-1   6 minutes ago   5m18s      Failed
```

<br/>

```
$ tkn pipelinerun ls
NAME                                STARTED         DURATION   STATUS
tekton-greeter-pipeline-webhook-1   3 minutes ago   2m41s      Succeeded
```

<br/>

```
$ tkn pipelinerun logs tekton-greeter-pipeline-webhook-1 -f
[deploy : kubectl] deployment.apps/tekton-greeter created
```

<br/>

```
// Если запускать повторно, нужно удалить deployment
$ kubectl delete deployment tekton-greeter
```

<br/>

```
$ kubectl expose deploy/tekton-greeter --port 8080
$ kubectl port-forward svc/tekton-greeter 8080:8080
```

<br/>

```
$ curl localhost:8080
Meeow!! from Tekton 😺🚀⏎
```
