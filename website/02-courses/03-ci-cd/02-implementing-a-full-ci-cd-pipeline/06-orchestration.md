---
layout: page
title: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Оркестрация
description: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - Оркестрация
keywords: Видеокурсы по DevOps, Внедрение полного конвейера CI/CD, Оркестрация
permalink: /courses/ci-cd/implementing-a-full-ci-cd-pipeline/orchestration/
---

# [A Cloud Guru, Linux Academy] Внедрение полного конвейера CI/CD [RUS, 2020]

<br/>

## 07. Оркестрация

**Делаю все с 0. На виртуалках.**

<br/>

### 01. Поднимаю локальный kubernetes кластер

Разворачиваю <a href="https://github.com/webmakaka/vagrant-kubernetes-3-node-cluster-ubuntu-20.04">kubernetes</a> в виртуалках.

<br/>

### 02. Поднимаю в виртуалке Jenkis

<br/>

    $ mkdir ~/vagrant-jenkins && cd ~/vagrant-jenkins

<br/>

**Создаю Vagrantfile для виртуалки**

<br/>

```
$ cat << EOF >> Vagrantfile

# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/focal64"
  config.hostmanager.enabled = true
  config.hostmanager.include_offline = true

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = 2
  end

  config.vm.define "jenkins.k8s" do |c|
    c.vm.hostname = "jenkins.k8s"
    c.vm.network "private_network", ip: "192.168.0.5"
  end
end
EOF
```

<br/>

    $ vagrant up

<br/>

    $ vagrant ssh jenkins.k8s

<br/>

    $ sudo apt update
    $ sudo apt upgrade -y

<br/>

    $ sudo apt install -y \
        openssh-server \
        rar unrar-free \
        unzip

<br/>

**Создаю пользователя "jenkins"**

    $ sudo su  -
    # adduser --disabled-password --gecos "" jenkins
    # usermod -aG sudo jenkins
    # passwd jenkins

<br/>

**Предоставляю возможность подключения по SSH**

    # sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

    # service sshd reload

<br/>

**Разрешаю выполнение команд sudo без пароля**

    # vi /etc/sudoers

<br/>

    %sudo   ALL=(ALL:ALL) ALL

<br/>

меняю на:

```shell
#%sudo   ALL=(ALL:ALL) ALL
%sudo   ALL=(ALL:ALL) NOPASSWD:ALL
```

<br/>

Устанавливаю <a href="//javadev.org/devtools/jdk/setup/linux/">JDK8</a>

Устанавливаю <a href="//javadev.org/devtools/build/gradle/linux/ubuntu/">Gradle</a>

Устанавливаю <a href="/tools/containers/docker/setup/ubuntu/">Docker</a>

Устанавливаю <a href="//javadev.org/devtools/cicd/jenkins/setup/ubuntu/20.04/">Jenkins</a>

<br/>

    $ sudo usermod -aG docker jenkins
    $ sudo systemctl restart jenkins
    $ sudo systemctl restart docker

<br/>

http://192.168.0.5:8080/

<br/>

### Генерация ключа для работы с GitHub

    $ ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -q -N ""

    $ cat ~/.ssh/id_rsa.pub

<br/>

Вставляем на GitHub

<br/>

GitHub -> Settings -> SSH and GPG keys

<br/>

<!--

**Jenkins**

<br/>

    $ docker login --username=<hub username> --email=<hub email>

-->

<br/>

### Создаю Credentials

Manage Jenkins -> Credentials

<br/>

![Jenkins](/img/courses/ci-cd/implementing-a-full-ci-cd-pipeline/pic-m06-pic01.png 'Jenkins'){: .center-image }

<!--

<br/>

github_token -> github_api_key (Думаю, нужен только для хуков).

-->

<br/>

### Проверяю возможность работы с kubernetes

<br/>

    $ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/

<br/>

    $ mkdir -p ~/.kube

<br/>

    // root password: kubeadmin
    $ scp root@192.168.0.10:/etc/kubernetes/admin.conf ~/.kube/config

<br/>

    $ kubectl get nodes
    NAME         STATUS   ROLES                  AGE    VERSION
    master.k8s   Ready    control-plane,master   127m   v1.20.1
    node1.k8s    Ready    <none>                 124m   v1.20.1
    node2.k8s    Ready    <none>                 120m   v1.20.1

<br/>

### 03. Работа по задаче развертывания с помощью jenkins приложения в локальный kubernetes кластер

Клонируем к себе в репо на гитхаб

https://github.com/linuxacademy/cicd-pipeline-train-schedule-kubernetes

<br/>

**В Jenkins Нужно установить Plugin'ы:**

- "Docker Pipeline"
- "Kubernetes Continuous Deploy"
- "Publish Over SSH" (может и не нужен здесь)

<!--

<br/>

Kubernetes
Также установил Plugin "Kubernetes Client API"

-->

<br/>

**Добавление Credentials:**

Jenkins -> Add Credentials ->

<br/>

Kind -> Kubernetes configuration (kubeconfig)

id: kubeconfig
Description: Kubeconfig

Kubeconfig -> Enter directly ->

Вставляю содержимое файла

    $ cat ~/.kube/config

<br/>

![Kubeconfig](/img/courses/ci-cd/implementing-a-full-ci-cd-pipeline/pic-m06-pic02.png 'Kubeconfig'){: .center-image }

<br/>

### Создание нового задания

Jenkins -> New Item

Name: train-schedule
Type: Multibranch Pipeline

<br/>

Branch Source -> GitHub

<!--Credentials -> Github API Key -->

Repository HTTPS URL

https://github.com/wildmakaka/cicd-pipeline-train-schedule-kubernetes

validate.

<br/>

### Изменения в проекте для Deploy

**У меня уже все сделано!**

<br/>

Делается следующим образом.

Добавляем в проект github

https://github.com/linuxacademy/cicd-pipeline-train-schedule-kubernetes/blob/example-solution/train-schedule-kube.yml

<br/>

Заменяем Jenkinsfile и в нем docker-hub:

https://github.com/linuxacademy/cicd-pipeline-train-schedule-kubernetes/blob/example-solution/Jenkinsfile

<br/>

**На шаге развертывания ошибка.**

```
ERROR: ERROR: Can't construct a java object for tag:yaml.org,2002:io.kubernetes.client.openapi.models.V1Service; exception=Class not found: io.kubernetes.client.openapi.models.V1Service
 in 'reader', line 1, column 1:
    kind: Service
    ^

hudson.remoting.ProxyException: Can't construct a java object for tag:yaml.org,2002:io.kubernetes.client.openapi.models.V1Service; exception=Class not found: io.kubernetes.client.openapi.models.V1Service
 in 'reader', line 1, column 1:
    kind: Service
    ^

	at org.yaml.snakeyaml.constructor.Constructor$ConstructYamlObject.construct(Constructor.java:335)
	at org.yaml.snakeyaml.constructor.BaseConstructor.constructObjectNoCheck(BaseConstructor.java:229)
	at org.yaml.snakeyaml.constructor.BaseConstructor.constructObject(BaseConstructor.java:219)
	at io.kubernetes.client.util.Yaml$CustomConstructor.constructObject(Yaml.java:337)
	at org.yaml.snakeyaml.constructor.BaseConstructor.constructDocument(BaseConstructor.java:173)
	at org.yaml.snakeyaml.constructor.BaseConstructor.getSingleData(BaseConstructor.java:157)
	at org.yaml.snakeyaml.Yaml.loadFromReader(Yaml.java:490)
	at org.yaml.snakeyaml.Yaml.loadAs(Yaml.java:456)
	at io.kubernetes.client.util.Yaml.loadAs(Yaml.java:224)
	at io.kubernetes.client.util.Yaml.modelMapper(Yaml.java:494)
	at io.kubernetes.client.util.Yaml.loadAll(Yaml.java:272)
	at com.microsoft.jenkins.kubernetes.wrapper.KubernetesClientWrapper.apply(KubernetesClientWrapper.java:236)
	at com.microsoft.jenkins.kubernetes.command.DeploymentCommand$DeploymentTask.doCall(DeploymentCommand.java:172)
	at com.microsoft.jenkins.kubernetes.command.DeploymentCommand$DeploymentTask.call(DeploymentCommand.java:124)
	at com.microsoft.jenkins.kubernetes.command.DeploymentCommand$DeploymentTask.call(DeploymentCommand.java:106)
	at hudson.FilePath.act(FilePath.java:1164)
	at com.microsoft.jenkins.kubernetes.command.DeploymentCommand.execute(DeploymentCommand.java:68)
	at com.microsoft.jenkins.kubernetes.command.DeploymentCommand.execute(DeploymentCommand.java:45)
	at com.microsoft.jenkins.azurecommons.command.CommandService.runCommand(CommandService.java:88)
	at com.microsoft.jenkins.azurecommons.command.CommandService.execute(CommandService.java:96)
	at com.microsoft.jenkins.azurecommons.command.CommandService.executeCommands(CommandService.java:75)
	at com.microsoft.jenkins.azurecommons.command.BaseCommandContext.executeCommands(BaseCommandContext.java:77)
	at com.microsoft.jenkins.kubernetes.KubernetesDeploy.perform(KubernetesDeploy.java:42)
	at com.microsoft.jenkins.azurecommons.command.SimpleBuildStepExecution.run(SimpleBuildStepExecution.java:54)
	at com.microsoft.jenkins.azurecommons.command.SimpleBuildStepExecution.run(SimpleBuildStepExecution.java:35)
	at org.jenkinsci.plugins.workflow.steps.SynchronousNonBlockingStepExecution.lambda$start$0(SynchronousNonBlockingStepExecution.java:47)
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)
Caused by: hudson.remoting.ProxyException: org.yaml.snakeyaml.error.YAMLException: Class not found: io.kubernetes.client.openapi.models.V1Service
	at org.yaml.snakeyaml.constructor.Constructor.getClassForNode(Constructor.java:664)
	at org.yaml.snakeyaml.constructor.Constructor$ConstructYamlObject.getConstructor(Constructor.java:322)
	at org.yaml.snakeyaml.constructor.Constructor$ConstructYamlObject.construct(Constructor.java:331)
	... 30 more
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline

Could not update commit status, please check if your scan credentials belong to a member of the organization or a collaborator of the repository and repo:status scope is selected


GitHub has been notified of this commit’s build result

ERROR: Kubernetes deployment ended with HasError
Finished: FAILURE
```

<br/>

### Ничего не заработало с помощью этого Jenkins

Пишут, что нужно сделать DownGrade плагинов:

```
Jackson 2 API v2.10.0,

Kubernetes v1.21.3,

Kubernetes Client API v4.6.3-1,

Kubernetes Continuous Deploy v2.1.2,

Kubernetes Credentials v0.5.0
```

<br/>

Возможно, что также нужно делать DownGrade:

```

Snakeyaml API to v1.26.2
GitHub Branch Source 2.7.1

```

<br/>

**Downgrade:**  
https://www.youtube.com/watch?v=d6BU8LBc9Ow

<br/>

**Скачать плагины:**  
https://plugins.jenkins.io/

<br/>

Jenkins -> Plugins -> Advanced -> Upload

<br/>

### Запускаю руками

    $ kubectl get nodes
    NAME         STATUS   ROLES                  AGE   VERSION
    master.k8s   Ready    control-plane,master   19h   v1.20.1
    node1.k8s    Ready    <none>                 19h   v1.20.1
    node2.k8s    Ready    <none>                 19h   v1.20.1

<br/>

```
$ cat << 'EOF' | kubectl apply -f -
kind: Service
apiVersion: v1
metadata:
  name: train-schedule-service
spec:
  type: NodePort
  selector:
    app: train-schedule
  ports:
  - protocol: TCP
    port: 8080
    nodePort: 30001

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: train-schedule-deployment
  labels:
    app: train-schedule
spec:
  replicas: 2
  selector:
    matchLabels:
      app: train-schedule
  template:
    metadata:
      labels:
        app: train-schedule
    spec:
      containers:
      - name: train-schedule
        image: webmakaka/train-schedule
        ports:
        - containerPort: 8080
EOF
```

<br/>

    $ kubectl get pods
    NAME                                         READY   STATUS    RESTARTS   AGE
    train-schedule-deployment-67bfb5f9db-29cnj   1/1     Running   0          100s
    train-schedule-deployment-67bfb5f9db-q8kvm   1/1     Running   0          100s

<br/>

    $ kubectl get svc
    NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
    kubernetes               ClusterIP   10.96.0.1       <none>        443/TCP          19h
    train-schedule-service   NodePort    10.105.61.230   <none>        8080:30001/TCP   73s

<br/>

http://node1.k8s:30001

<br/>

![Kubeconfig](/img/courses/ci-cd/implementing-a-full-ci-cd-pipeline/pic-m06-pic03.png 'Kubeconfig'){: .center-image }

<br/>

### Удаляю созданные ресурсы

    $ kubectl delete svc train-schedule-service
    $ kubectl delete deployment train-schedule-deployment
