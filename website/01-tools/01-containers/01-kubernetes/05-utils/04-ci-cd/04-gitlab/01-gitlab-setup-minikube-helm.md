---
layout: page
title: Инсталляция GitLab в ubuntu 22.04
description: Инсталляция GitLab в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, GitLab, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/gitlab/setup/helm/minikube/
---

# Инсталляция GitLab в ubuntu 22.04

<br/>

**Делаю:**  
2026.01.06

<br/>

# Разбираюсь как устанавливать!!!

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
gitlab-registry             gitlab-nginx   registry.192.168.49.2.nip.io   192.168.49.2   80      2m58s
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

```
//  Находим имя пода toolbox (в старых версиях назывался task-runner)
$ TOOLBOX_POD=$(kubectl get pods -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}')

$ kubectl exec -n gitlab -it $TOOLBOX_POD -- gitlab-rails runner "
  runner = Ci::Runner.create!(runner_type: 'instance_type', description: 'k8s-runner', run_untagged: true)
  puts runner.token
"
```

<br/>

```
$ cd ~/tmp
```

<br/>

```yaml
$ cat > runner-config.yaml <<EOF
# URL вашего GitLab
gitlabUrl: http://gitlab-webservice-default.gitlab.svc.cluster.local:8080

# НОВОЕ: В 2026 году используем runnerToken вместо runnerRegistrationToken
runnerToken: "glrtr-JszP89kmHP5mnuDugHnY"

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
        # Важно: разрешаем HTTP внутри кластера
        pull_policy = ["always", "if-not-present"]

# Глобальное отключение TLS для сессий
envVars:
  - name: CI_SERVER_TLS_CA_FILE
    value: ""
  - name: GIT_SSL_NO_VERIFY
    value: "true"

# Решение проблемы "Checking for jobs... failed":
# Если Ingress не пускает по внешнему домену, прописываем прямой путь к сервису
hostAliases:
  - ip: "$(kubectl get svc -n gitlab gitlab-webservice-default -o jsonpath='{.spec.clusterIP}')"
    hostnames:
      - "gitlab.$INGRESS_HOST.nip.io"
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

<br/>

# 1. Находим имя пода toolbox

TOOLBOX_POD=$(kubectl get pods -n gitlab -l app=toolbox -o jsonpath='{.items[0].metadata.name}')

# 2. Выполняем команду внутри него

```
$ kubectl exec -n gitlab -it $TOOLBOX_POD -- gitlab-rails runner "
runner = Ci::Runner.instance_type.last
if runner.update(active: true, run_untagged: true, locked: false, access_level: 'not_protected')
  puts '--- Runner Configuration Updated ---'
  puts \"ID:          #{runner.id}\"
  puts \"Description: #{runner.description}\"
  puts \"Token:       #{runner.token}\"
  puts \"Status:      #{runner.status}\"
  puts \"Untagged:    #{runner.run_untagged}\"
  puts \"Locked:      #{runner.locked}\"
  puts '------------------------------------'
else
  puts 'ERROR: Failed to update runner'
  puts runner.errors.full_messages
end
"
```

<br/>

```
--- Runner Configuration Updated ---
ID:          1
Description: k8s-runner
Token:       glrtr-YtxqMQJyKXjskj7TVh3Q
Status:      never_contacted
Untagged:    true
Locked:      false
------------------------------------
```

<br/>

```
http://gitlab.192.168.49.2.nip.io/admin/runners
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

<br/>

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
Online:       NO
Active:       true
Can pick untagged: true
Locked:       false
Access level: not_protected
Tags:
Projects:

[!] ВНИМАНИЕ: Раннер OFFLINE. Проверьте логи пода самого раннера.
```

<br/>

В Deployment поменял

```
yaml
        - name: CI_SERVER_URL
          value: http://gitlab-webservice-default.gitlab.svc.cluster.local:8080
```
