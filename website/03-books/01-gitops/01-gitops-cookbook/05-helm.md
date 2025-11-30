---
layout: page
title: GitOps Cookbook - Helm
description: GitOps Cookbook - Helm
keywords: GitOps Cookbook, Helm
permalink: /books/gitops/gitops-cookbook/helm/
---

<br/>

# [Book] GitOps Cookbook: 04. Helm

<br/>

**Репо проекта:**  
https://github.com/gitops-cookbook/helm-charts/tree/master/pacman

<br/>

### 5.1 Creating a Helm Project

<br/>

**Делаю:**  
2025.11.27

<br/>

**Задача:**  
Вы хотите создать простой Helm проект

<br/>

```
$ cd ~/tmp
$ git clone git@github.com:gitops-cookbook/helm-charts.git
$ cd helm-charts/pacman
$ helm template .
$ helm template --set replicaCount=3 .
```

<br/>

```
$ helm install pacman .
```

<br/>

```
$ kubectl get pods
NAME                      READY   STATUS    RESTARTS   AGE
pacman-86454cc887-jdn62   1/1     Running   0          46s
```

<br/>

```
$ helm history pacman
```

<br/>

```
$ helm uninstall pacman
```

<br/>

### 5.2 Reusing Statements Between Templates

<br/>

**Делаю:**  
2025.11.29

<br/>

**Задача:**  
Вы хотите спользовать шаблоны и указывать в них значения

<br/>

```yaml
$ cat > templates/_helpers.tpl << EOF
{{- define "pacman.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name}}
app.kubernetes.io/version: {{ .Chart.AppVersion}}
{{- end }}
EOF
```

<br/>

Если в коде yaml прописать

<br/>

```
{{- include "pacman.selectorLabels" . | nindent 6 }}
```

<br/>

nindent - отсутп

<br/>

```
$ helm template .
```

<br/>

Появится содержимаое.

<br/>

### 5.3 Updating a Container Image in Helm

<br/>

**Делаю:**  
2025.11.29

<br/>

**Задача:**  
Вы хотите обновить container image в deployment файле используя Helm и проапгрейдить запущенный instance

<br/>

```
$ git checkout .
$ rm templates/_helpers.tpl
```

<br/>

```
$ helm install pacman .
NAME: pacman
LAST DEPLOYED: Sat Nov 29 01:36:29 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

```
$ helm history pacman
REVISION	UPDATED                 	STATUS  	CHART       	APP VERSION	DESCRIPTION
1       	Sat Nov 29 01:36:29 2025	deployed	pacman-0.1.0	1.0.0      	Install complete
```

<br/>

```
$ vi values.yaml
```

Прописываем container tag to 1.1.0

<br/>

```
$ vi Chart.yaml
```

Прописываем appVersion: "1.1.0"

<br/>

```
$ helm upgrade pacman .
```

<br/>

```
$ helm history pacman
REVISION	UPDATED                 	STATUS    	CHART       	APP VERSION	DESCRIPTION
1       	Sat Nov 29 01:36:29 2025	superseded	pacman-0.1.0	1.0.0      	Install complete
2       	Sat Nov 29 01:39:43 2025	deployed  	pacman-0.1.0	1.1.0      	Upgrade complete
```

<br/>

```
$ helm rollback pacman 1
```

<br/>

```
$ helm history pacman
REVISION	UPDATED                 	STATUS    	CHART       	APP VERSION	DESCRIPTION
1       	Sat Nov 29 01:36:29 2025	superseded	pacman-0.1.0	1.0.0      	Install complete
2       	Sat Nov 29 01:39:43 2025	superseded	pacman-0.1.0	1.1.0      	Upgrade complete
3       	Sat Nov 29 01:40:33 2025	deployed  	pacman-0.1.0	1.0.0      	Rollback to 1
```

<br/>

```yaml
$ cat > newvalues.yaml << EOF
image:
  tag: "1.2.0"
EOF
```

<br/>

```
$ helm template pacman -f newvalues.yaml .
```

<br/>

Tag прописался из файла newvalues.yaml.

<br/>

```
$ helm uninstall pacman
```

<br/>

### 5.4 Packaging and Distributing a Helm Chart

<br/>

**Делаю в бесплатном облаке google-cloud-shell:**  
2025.11.30

<br/>

**Задача:**  
Вы хотите создать свой Helm Chart и распространять его между пользователями

<br/>

```
$ helm package .

// Сгенерировать файл index.yaml
$ helm repo index .
```

<br/>

**С gpg подписью**

<br/>

```
# Создать основную папку
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg

# Создать необходимые подкаталоги
mkdir -p ~/.gnupg/private-keys-v1.d
mkdir -p ~/.gnupg/crls.d
```

<br/>

```
# Убедиться что владелец правильный
chown -R $USER:$USER ~/.gnupg
```

<br/>

```
$ gpg --batch --generate-key << EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: marley
Name-Email: marley@internet.ru
Expire-Date: 0
%commit
EOF
```

<br/>

```
$ gpg --list-secret-keys
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
/home/marley/.gnupg/pubring.kbx
-------------------------------
sec   rsa4096 2025-11-30 [SCEA]
      5546C6173CCC9C5B5E1CD4FE0547DC35D64C40F1
uid           [ultimate] marley <marley@internet.ru>
ssb   rsa4096 2025-11-30 [SEA]
```

<br/>

```
$ gpg --export-secret-keys > ~/.gnupg/secring.gpg
$ chmod 600 ~/.gnupg/secring.gpg
```

<br/>

```
$ helm package --sign --key 'marley@internet.ru' \
--keyring /home/${USER}/.gnupg/secring.gpg .
```

<br/>

```
$ cat pasha256:1.0.tgz.prov | grep sha256:
  pacman-0.1.0.tgz: sha256:6f8820f8109e62c28f3dec5ef8605529e452edec2e02d67add646054238bfb6b
```

<br/>

```
$ helm verify pacman-0.1.0.tgz --keyring /home/${USER}/.gnupg/secring.gpg
Signed by: marley <marley@internet.ru>
Using Key With Fingerprint: 5546C6173CCC9C5B5E1CD4FE0547DC35D64C40F1
Chart Hash Verified: sha256:6f8820f8109e62c28f3dec5ef8605529e452edec2e02d67add646054238bfb6b
```

<br/>

### [OK!] 5.5 Deploying a Chart from a Repository

<br/>

**Делаю в бесплатном облаке google-cloud-shell:**  
2025.11.30

<br/>

**Задача:**  
Вы хотите задеплоить Helm Chart хранящийся в репо

<br/>

```
// На дату 2025.11.30 не получается добавить, т.к. забанены всей страной
// Удалось выполнить команды в бесплатном облаке google-cloud-shell
$ helm repo add bitnami https://charts.bitnami.com/bitnami
```

<br/>

```
$ helm repo update
$ helm repo list
$ helm search repo postgresql
```

<br/>

```
$ helm install my-db \
  bitnami/postgresql \
  --namespace postgres \
  --create-namespace \
  --set auth.username=user1,auth.password=postgres1,auth.database=postgresdb1,primary.persistence.enabled=false
```

<br/>

```
$ kubectl get pods -n postgres
NAME                 READY   STATUS    RESTARTS   AGE
my-db-postgresql-0   1/1     Running   0          23s

```

<br/>

```
// To get the password for "user1" run:
$ {
  export POSTGRES_PASSWORD=$(kubectl get secret --namespace postgres my-db-postgresql -o jsonpath="{.data.password}" | base64 -d)
  echo ${POSTGRES_PASSWORD}
}
```

<br/>

```
// Подключиться к базе postgresql с помощью клиента psql
// OK!
$ kubectl run my-db-postgresql-client --rm --tty -i --restart='Never' --namespace postgres --image docker.io/bitnami/postgresql:latest --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host my-db-postgresql -U user1 -d postgresdb1 -p 5432
```

<br/>

```
// To connect to your database from outside the cluster
// OK!
$ kubectl port-forward --namespace postgres svc/my-db-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U user1 -d postgresdb1 -p 5432
```

<br/>

```
$ kubectl get statefulset -n postgres
NAME               READY   AGE
my-db-postgresql   1/1     2m54s
```

<br/>

```
$ helm show values bitnami/postgresql
```

<br/>

### [OK!] 5.6 Deploying a Chart with a Dependency

<br/>

**Делаю в бесплатном облаке google-cloud-shell:**  
2025.11.30

<br/>

**Задача:**  
Вы хотите задеплоить Helm Chart, с зависимостями от другого Helm Chart

<br/>

https://github.com/bitnami/charts/tree/main/bitnami/postgresql/#installing-the-chart

<br/>

```
$ cd ~/tmp
$ mkdir -p music/templates
$ cd music
```

<br/>

```yaml
$ cat > templates/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name}}
  labels:
    app.kubernetes.io/name: {{ .Chart.Name}}
    {{- if .Chart.AppVersion }}
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    {{- end }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ .Chart.Name}}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ .Chart.Name}}
    spec:
      containers:
          - image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion}}"
            imagePullPolicy: {{ .Values.image.pullPolicy }}
            securityContext:
              {{- toYaml .Values.securityContext | nindent 14 }}
            name: {{ .Chart.Name}}
            ports:
              - containerPort: {{ .Values.image.containerPort }}
                name: http
                protocol: TCP
            env:
              - name: QUARKUS_DATASOURCE_JDBC_URL
                value: {{ .Values.postgresql.server |
                default (printf "%s-postgresql" ( .Release.Name )) | quote }}
              - name: QUARKUS_DATASOURCE_USERNAME
                value: {{ .Values.postgresql.postgresqlUsername |
                default (printf "postgres" ) | quote }}
              - name: QUARKUS_DATASOURCE_PASSWORD
                valueFrom:
                  secretKeyRef:
                    name: {{ .Values.postgresql.secretName |
                    default (printf "%s-postgresql" ( .Release.Name )) | quote }}
                    key: {{ .Values.postgresql.secretKey }}
EOF
```

<br/>

```yaml
$ cat > templates/service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: {{ .Chart.Name }}
  name: {{ .Chart.Name }}
spec:
  ports:
    - name: http
      port: {{ .Values.image.containerPort }}
      targetPort: {{ .Values.image.containerPort }}
  selector:
    app.kubernetes.io/name: {{ .Chart.Name }}
EOF
```

<br/>

```yaml
$ cat > Chart.yaml << EOF
apiVersion: v2
name: music
description: A Helm chart for Music service

type: application
version: 0.1.0
appVersion: "1.0.0"

dependencies:
  - name: postgresql
    repository: "https://charts.bitnami.com/bitnami"
    version: 18.1.13
EOF
```

<br/>

```yaml
$ cat > values.yaml << EOF
image:
  repository: quay.io/gitops-cookbook/music
  tag: "1.0.0"
  pullPolicy: Always
  containerPort: 8080

replicaCount: 1

postgresql:
  server: jdbc:postgresql://music-db-postgresql:5432/postgresdb1
  postgresqlUsername: user1
  secretName: music-db-postgresql
  secretKey: password
EOF
```

<br/>

```
$ helm dependency update
```

<br/>

```
$ tree
.
├── Chart.lock
├── Chart.yaml
├── charts
│   └── postgresql-18.1.13.tgz
├── templates
│   ├── deployment.yaml
│   └── service.yaml
└── values.yaml
```

<br/>

```
$ helm install music-db \
  --namespace music \
  --create-namespace \
  --set global.postgresql.auth.username=user1,global.postgresql.auth.password=postgres1,global.postgresql.auth.database=postgresdb1,primary.persistence.enabled=false .
```

<br/>

```
$ kubectl get pods -n music
NAME                      READY   STATUS      RESTARTS       AGE
music-6d957c46bf-5w2g8    1/1     Running     2 (4m3s ago)   4m12s
music-db-postgresql-0     1/1     Running     0              4m12s
```

<br/>

```
// Можно пропустить
// GET ADMIN_POSTGRES_PASSWORD
$ {
  export ADMIN_POSTGRES_PASSWORD=$(kubectl get -n music secret music-db-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
  echo ${POSTGRES_PASSWORD}
}
```

<br/>

```
// Можно пропустить
// To connect to your database as admin
$ kubectl run my-db-postgresql-client --rm --tty -i --restart='Never' --namespace music --image docker.io/bitnami/postgresql:latest --env="PGPASSWORD=$ADMIN_POSTGRES_PASSWORD" \
      --command -- psql --host music-db-postgresql -U postgres -d postgres -p 5432
```

<br/>

```
// Можно пропустить
// GET USER POSTGRES_PASSWORD
$ {
  export USER_POSTGRES_PASSWORD=$(kubectl get -n music secret music-db-postgresql -o jsonpath="{.data.password}" | base64 -d)
  echo ${POSTGRES_PASSWORD}
}
```

<br/>

```
// Можно пропустить
// To connect to your database as user1
$ kubectl run my-db-postgresql-client --rm --tty -i --restart='Never' --namespace music --image docker.io/bitnami/postgresql:latest --env="PGPASSWORD=$USER_POSTGRES_PASSWORD" \
      --command -- psql --host music-db-postgresql -U user1 -d postgresdb1 -p 5432
```

<br/>

```
// Можно пропустить
// To connect to your database from outside the cluster
$ kubectl port-forward --namespace music svc/music-db-postgresql 5432:5432 &
    PGPASSWORD="$USER_POSTGRES_PASSWORD" psql --host 127.0.0.1 -U user1 -d postgresdb1 -p 5432
```

<br/>

```
// Можно пропустить
$ kubectl get services -n music
NAME                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
music                    ClusterIP   10.109.139.154   <none>        8080/TCP   83s
music-db-postgresql      ClusterIP   10.106.198.189   <none>        5432/TCP   83s
music-db-postgresql-hl   ClusterIP   None             <none>        5432/TCP   83s
```

<br/>

```
$ kubectl port-forward -n music service/music 8080:8080
```

<br/>

```
$ curl localhost:8080/song | jq
[
  {
    "id": 1,
    "artist": "DT",
    "name": "Quiero Munchies"
  },
  {
    "id": 2,
    "artist": "Lin-Manuel Miranda",
    "name": "We Don't Talk About Bruno"
  },
  {
    "id": 3,
    "artist": "Imagination",
    "name": "Just An Illusion"
  },
  {
    "id": 4,
    "artist": "Txarango",
    "name": "Tanca Els Ulls"
  },
  {
    "id": 5,
    "artist": "Halsey",
    "name": "Could Have Been Me"
  }
]
```

<br/>

### [OK!] 5.7 Triggering a Rolling Update Automatically

<br/>

**Делаю в бесплатном облаке google-cloud-shell:**  
2025.11.30

<br/>

**Задача:**  
Вы хотите обновить deployment при изменении ConfigMap

<br/>

```
$ cd ~/tmp
$ mkdir -p greetings/templates
$ cd greetings
```

<br/>

```yaml
$ cat > templates/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name}}
  labels:
    app.kubernetes.io/name: {{ .Chart.Name}}
    {{- if .Chart.AppVersion }}
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    {{- end }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ .Chart.Name}}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ .Chart.Name}}
    spec:
      containers:
          - image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion}}"
            imagePullPolicy: {{ .Values.image.pullPolicy }}
            securityContext:
              {{- toYaml .Values.securityContext | nindent 14 }}
            name: {{ .Chart.Name}}
            ports:
              - containerPort: {{ .Values.image.containerPort }}
                name: http
                protocol: TCP
            env:
              - name: GREETING
                valueFrom:
                  configMapKeyRef:
                    name: {{ .Values.configmap.name}}
                    key: greeting
EOF
```

<br/>

```yaml
$ cat > templates/service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: {{ .Chart.Name }}
  name: {{ .Chart.Name }}
spec:
  ports:
    - name: http
      port: {{ .Values.image.containerPort }}
      targetPort: {{ .Values.image.containerPort }}
  selector:
    app.kubernetes.io/name: {{ .Chart.Name }}
EOF
```

<br/>

```yaml
$ cat > templates/configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: greeting-config
data:
  greeting: Aloha
EOF
```

<br/>

```yaml
$ cat > Chart.yaml << EOF
apiVersion: v2
name: greetings
description: A Helm chart for Greetings service

type: application
version: 0.1.0
appVersion: "1.0.0"
EOF
```

<br/>

```yaml
$ cat > values.yaml << EOF
image:
  repository: quay.io/gitops-cookbook/greetings
  tag: "1.0.0"
  pullPolicy: Always
  containerPort: 8080

replicaCount: 1

configmap:
  name: greeting-config
EOF
```

<br/>

```
$ tree .
.
├── Chart.yaml
├── templates
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
└── values.yaml
```

<br/>

```
$ helm install greetings .
```

<br/>

```
$ kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
greetings-6df4d99d46-vzrj9   1/1     Running   0          29s
```

<br/>

```
$ kubectl port-forward service/greetings 8080:8080
```

<br/>

```
$ curl localhost:8080
```

**returns**

```
Aloha Ada
```

<br/>

**Update the ConfigMap**

<br/>

```yaml
$ cat > templates/configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: greeting-config
data:
  greeting: Hola
EOF
```

<br/>

```
$ helm upgrade greetings .
```

<br/>

```
$ kubectl port-forward service/greetings 8080:8080
```

<br/>

```
$ curl localhost:8080
```

**returns**

```
Aloha Alexandra⏎
```

<br/>

There are no changes in the Deployment object, there is no restart of the pod.

<br/>

```yaml
$ cat > templates/deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name}}
  labels:
    app.kubernetes.io/name: {{ .Chart.Name}}
    {{- if .Chart.AppVersion }}
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
    {{- end }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ .Chart.Name}}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ .Chart.Name}}
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
    spec:
      containers:
          - image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion}}"
            imagePullPolicy: {{ .Values.image.pullPolicy }}
            securityContext:
              {{- toYaml .Values.securityContext | nindent 14 }}
            name: {{ .Chart.Name}}
            ports:
              - containerPort: {{ .Values.image.containerPort }}
                name: http
                protocol: TCP
            env:
              - name: GREETING
                valueFrom:
                  configMapKeyRef:
                    name: {{ .Values.configmap.name}}
                    key: greeting
EOF
```

<br/>

```yaml
$ cat > templates/configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: greeting-config
data:
  greeting: Namaste
EOF
```

<br/>

```
$ helm upgrade greetings .
```

<br/>

```
$ kubectl port-forward service/greetings 8080:8080
```

<br/>

```
$ curl localhost:8080
```

<br/>

**returns**

```
Namaste Ada⏎
```

<br/>

```
$ kubectl describe pod greetings-bd8c9c4df-59xrj
```

<br/>

```
***
Annotations:      checksum/config:
***
```

<br/>

```yaml
$ cat > templates/configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: greeting-config
data:
  greeting: Привет!
EOF
```

<br/>

```
$ helm upgrade greetings .
```

<br/>

```
$ kubectl port-forward service/greetings 8080:8080
```

<br/>

```
// Нужно подождать перестартовки пода
$ curl localhost:8080
```

<br/>

```
Привет! Ada⏎
```
