---
layout: page
title: Инсталляция GitLab в ubuntu 22.04
description: Инсталляция GitLab в ubuntu 22.04
keywords: tools, gitops, kubernetes, ci-cd, GitLab, инсталляция
permalink: /tools/containers/kubernetes/ci-cd/gitlab/setup/helm/minikube/
---

# Инсталляция GitLab в ubuntu 22.04

<br/>

**Делаю:**  
2026.01.06

<br/>

# Разбираюсь как устанавливать правильно!!!

<br/>

### Инсталляция GitLab с помощью helm

```
$ helm repo add gitlab https://charts.gitlab.io/
$ helm repo update
```

<br/>

```
$ export PROFILE=${USER}-minikube
$ export INGRESS_HOST=$(minikube --profile ${PROFILE} ip)
$ echo gitlab.$INGRESS_HOST.nip.io
```

<br/>

```
$ helm search repo gitlab
```

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > gitlab-config.yaml <<EOF
global:
  edition: ce
  hosts:
    domain: $INGRESS_HOST.nip.io
    https: false
  # Глобальное отключение TLS
  ingress:
    configureCertmanager: false
    tls:
      enabled: false

# Отключение встроенного GitLab Runner
gitlab-runner:
  install: false

# Отключение встроенного Registry
registry:
  enabled: false

installCertmanager: false

# Убираем TLS в настройках веб-сервиса
gitlab:
  webservice:
    ingress:
      tls:
        enabled: false
EOF
```

<!-- <br/>

```
$ helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --create-namespace \
  --set global.edition=ce \
  --set gitlab-runner.install=false \
  --set global.hosts.domain=gitlab.$INGRESS_HOST.nip.io \
  --set global.hosts.externalIP=$INGRESS_HOST \
  --set certmanager-issuer.email=skip@example.com \
  --set global.ingress.configureCertmanager=false \
  --version 9.7.0 \
  --wait \
  --timeout 15m
``` -->

<br/>

```
  // --version 9.7.0 \
$ helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --create-namespace \
  --values gitlab-config.yaml
```

<!--
```
 \
  --wait \
  --timeout 15m
``` -->

<br/>

```
// helm uninstall gitlab -n gitlab
```

<br/>

```
$ kubectl get ingress -n gitlab
NAME                        CLASS          HOSTS                          ADDRESS        PORTS   AGE
gitlab-kas                  gitlab-nginx   kas.192.168.49.2.nip.io        192.168.49.2   80      2m58s
gitlab-minio                gitlab-nginx   minio.192.168.49.2.nip.io      192.168.49.2   80      2m58s
gitlab-webservice-default   gitlab-nginx   gitlab.192.168.49.2.nip.io     192.168.49.2   80      2m58s
```

<br/>

```
// Получить root пароль GitLab
$ kubectl get secret -n gitlab gitlab-gitlab-initial-root-password \
  -o jsonpath='{.data.password}' | base64 --decode && echo
```

<br/>

```
// root / <root-password>
http://gitlab.192.168.49.2.nip.io
```

<br/>

### Добавить GitLab Runner

<br/>

```
$ RUNNER_TOKEN=$(kubectl exec -n gitlab -it $(kubectl get pods -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}') -- gitlab-rails runner "runner = Ci::Runner.create!(runner_type: 'instance_type', description: 'k8s-runner', tag_list: [], run_untagged: true); puts runner.token")
```

<br/>

```
$ echo $RUNNER_TOKEN
```

<!-- ```
//  Находим имя пода toolbox (в старых версиях назывался task-runner)
$ TOOLBOX_POD=$(kubectl get pods -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}')

$ kubectl exec -n gitlab -it $TOOLBOX_POD -- gitlab-rails runner "
  runner = Ci::Runner.create!(runner_type: 'instance_type', description: 'k8s-runner', run_untagged: true)
  puts runner.token
"
``` -->

<br/>

```
$ cd ~/tmp
```

<!--
<br/>

```
kubectl run curl-test --image=curlimages/curl:latest -n gitlab -it --rm -- \
  curl -I http://gitlab-webservice-default.gitlab.svc.cluster.local:8080
```

<br/>

```
$ kubectl run curl-test --image=curlimages/curl:latest -n gitlab -it --rm -- \
  curl -I http://gitlab-webservice-default.gitlab.svc.cluster.local:8181
``` -->

<br/>

```yaml
$ cat > runner-config.yaml <<EOF
gitlabUrl: http://gitlab.192.168.49.2.nip.io

runnerToken: $RUNNER_TOKEN

rbac:
  create: true

# Решение проблемы Request bottleneck
concurrent: 10
checkInterval: 5

runners:
  # Настройка конкурентности (убирает Warning из логов)
  requestConcurrency: 4

  config: |
    [[runners]]
      # Отключаем проверку TLS на уровне клиента
      tls_verify = false
      [runners.kubernetes]
        namespace = "{{ .Release.Namespace }}"
        image = "ubuntu:24.04"
        privileged = true
        pull_policy = ["always", "if-not-present"]

# Глобальное отключение TLS для сессий
envVars:
  - name: CI_SERVER_TLS_CA_FILE
    value: ""
  - name: GIT_SSL_NO_VERIFY
    value: "true"

EOF
```

<br/>

```
// Установить runner в тот же namespace
$ helm install gitlab-runner gitlab/gitlab-runner \
  --namespace gitlab \
  --values runner-config.yaml \
  --wait \
  --timeout 15m
```

<br/>

```
// helm uninstall gitlab-runner -n gitlab
```

```
http://gitlab.192.168.49.2.nip.io/admin/runners
```

<br/>

### Проверка Runner

```
$ kubectl exec -n gitlab -it deployment/gitlab-toolbox -- gitlab-rails runner '
runner = Ci::Runner.instance_type.last
puts "--- Runner Diagnostic ---"
puts "Description:  #{runner.description}"
puts "Online:       #{runner.online? ? "YES" : "NO"}"
puts "Active:       #{runner.active}"
puts "Can pick untagged: #{runner.run_untagged}"
puts "Locked:       #{runner.locked}"
puts "Access level: #{runner.access_level}"
puts "Tags:         #{runner.tag_list}"
puts "Projects:     #{runner.projects.pluck(:name).join(", ")}"

if !runner.online?
  puts "\n[!] ВНИМАНИЕ: Раннер OFFLINE. Проверьте логи пода самого раннера."
elsif runner.run_untagged == false && runner.tag_list.empty?
  puts "\n[!] ВНИМАНИЕ: Раннер не берет задачи без тегов, но тегов у него нет."
end
'
```

<br/>

```
--- Runner Diagnostic ---
Description:  k8s-runner
Online:       YES
Active:       true
Can pick untagged: true
Locked:       false
Access level: not_protected
Tags:
Projects:
```

<br/>

# Добавить возможность клонировать репо

```
$ kubectl exec -n gitlab -it deployment/gitlab-toolbox -- gitlab-rails runner "
settings = ApplicationSetting.current
settings.update!(import_sources: ['github', 'git'])
puts \"\nSUCCESS: Import sources updated!\"
puts \"Current sources: #{settings.import_sources.join(', ')}\"
"
```

<!-- <br/>

В Deployment поменял

```
yaml
        - name: CI_SERVER_URL
          value: http://gitlab-webservice-default.gitlab.svc.cluster.local:8080
``` -->
