---
layout: page
title: Инсталляция Jenkins в ubuntu 22.04
description: Инсталляция Jenkins в ubuntu 22.04
keywords: tools, containers, kubernetes, ci-cd, Jenkins, инсталляция
permalink: /tools/containers/kubernetes/utils/ci-cd/jenkins/system-security-auditing-with-iaac/
---

# System Security Auditing with IaaC

<br/>

**Делаю:**  
2026.01.03

<br/>

Мы тестируем linux машину на предмет уязвимостей

<br/>

### На удаленном хосте 192.168.1.12

Выдать права, чтобы можно было выполнять sudo без пароля.

```
$ sudo apt update -y && sudo apt upgrade -y
$ sudo apt install -y ansible
```

<br/>

```
// Требуется license ID
https://www.chef.io/license-generation-free-trial
```

```
Here is your license key: free-72b8655e-a93d-45f6-b12a-f871ef1f5d0e-3709
```

<br/>

If you are using Chef Automate, please use below license JWT token:

```
eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImZyZWUtNzJiODY1NWUtYTkzZC00NWY2LWIxMmEtZjg3MWVmMWY1ZDBlLTM3MDkiLCJ2ZXJzaW9uIjoiMSIsInR5cGUiOiJmcmVlIiwiZ2VuZXJhdG9yIjoiY2hlZi9saWNlbnNlLShkZXZlbCkiLCJrZXlfc2hhMjU2IjoiZTBkZjI4YzhiYzY4MTUwZWRiZmVmOThjZDZiN2RjNDM5YzFmODBjN2U3ZWY3NDc4OTNhNjg5M2EyZjdiNjBmNyIsImdlbmVyYXRlZF9kYXRlIjp7InNlY29uZHMiOjE3Njc0NDE4NzV9LCJjdXN0b21lciI6Ik1heG11ZCBNYWdvbWVkb3YiLCJjdXN0b21lcklkIjoieDB6bGhAYWlyc3dvcmxkLm5ldCIsImN1c3RvbWVyX2lkX3ZlcnNpb24iOiIxIiwiZW50aXRsZW1lbnRzIjpbeyJuYW1lIjoiSGFiaXRhdCIsIm1lYXN1cmUiOiJub2RlIiwibGltaXQiOjEwLCJzdGFydCI6eyJzZWNvbmRzIjoxNzY3Mzk4NDAwfSwiZW5kIjp7InNlY29uZHMiOjE3OTg5MzQ0MDB9fSx7Im5hbWUiOiJJblNwZWMiLCJtZWFzdXJlIjoibm9kZSIsImxpbWl0IjoxMCwic3RhcnQiOnsic2Vjb25kcyI6MTc2NzM5ODQwMH0sImVuZCI6eyJzZWNvbmRzIjoxNzk4OTM0NDAwfX0seyJuYW1lIjoiSW5mcmEiLCJtZWFzdXJlIjoibm9kZSIsImxpbWl0IjoxMCwic3RhcnQiOnsic2Vjb25kcyI6MTc2NzM5ODQwMH0sImVuZCI6eyJzZWNvbmRzIjoxNzk4OTM0NDAwfX0seyJuYW1lIjoiV29ya3N0YXRpb24iLCJtZWFzdXJlIjoibm9kZSIsImxpbWl0IjoxMCwic3RhcnQiOnsic2Vjb25kcyI6MTc2NzM5ODQwMH0sImVuZCI6eyJzZWNvbmRzIjoxNzk4OTM0NDAwfX0seyJuYW1lIjoiQ2hlZiBDb3VyaWVyIiwibWVhc3VyZSI6Im5vZGUiLCJsaW1pdCI6MTAsInN0YXJ0Ijp7InNlY29uZHMiOjE3NjczOTg0MDB9LCJlbmQiOnsic2Vjb25kcyI6MTc5ODkzNDQwMH19LHsibmFtZSI6IkNoZWYgUGxhdGZvcm0iLCJtZWFzdXJlIjoibm9kZSIsImxpbWl0IjoxMCwic3RhcnQiOnsic2Vjb25kcyI6MTc2NzM5ODQwMH0sImVuZCI6eyJzZWNvbmRzIjoxNzk4OTM0NDAwfX0seyJuYW1lIjoiQXV0b21hdGUiLCJtZWFzdXJlIjoibm9kZSIsImxpbWl0IjoxLCJzdGFydCI6eyJzZWNvbmRzIjoxNzY3Mzk4NDAwfSwiZW5kIjp7InNlY29uZHMiOjE3OTg5MzQ0MDB9fV19.AAd5pdr-Oam6sr9vf4Tdbm_LB2oxdAmVtjgdL0-iT4RDvssuqGPZAnIiKeTZw1J1GKzsA1FCcNZxw8rajBWYY4IFAR5gjP-NEbyVsH6KK6rWfjz5YE8g4mok5kzZpiKdHhazR_Q29q19RqFdMbBNaObUsB29vPitoa1bFM3etBlbQpD7
```

<br/>

```
$ curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec
```

<br/>

```
$ inspec version
6.8.24
```

<br/>

```
$ cd ~/tmp
$ git clone https://github.com/dev-sec/linux-baseline.git
```

<br/>

```
$ inspec exec ~/tmp/linux-baseline
Profile Summary: 28 successful controls, 29 control failures, 1 control skipped
Test Summary: 123 successful, 60 failures, 2 skipped
```

<br/>

```
$ ssh-keygen -t rsa -b 4096 -f ~/.ssh/marley
$ ssh-keygen -t rsa -b 4096 -m PEM

```

<br/>

```
$ chmod 600 ~/.ssh/marley
$ chmod 644 ~/.ssh/marley.pub
```

<br/>

```
$ cat marley.pub >> ~/.ssh/authorized_keys
```

<br/>

### Install Essential Plugins

Browse to Manage Jenkins -> Manage Plugins -> Available

http://192.168.49.2:30264/manage/pluginManager/available

<br/>

Последняя версия не FAIL!

Версия 2.0.79.v1d1b_5f76dda_8 OK!  
https://plugins.jenkins.io/ssh-steps/releases/

- SSH Pipeline Steps

<br/>

```
// Добавьте в Jenkins:
// Jenkins → Manage Jenkins → Credentials → System → Global credentials → Add Credentials
http://192.168.49.2:30264/manage/credentials/store/system/domain/_/newCredentials
```

<br/>

```
Kind: SSH Username with private key
Scope: Global (Jenkins, nodes, items, all child items, etc)
ID: sshUser
Description: SSH User
Username: marley
key: OPENSSH PRIVATE KEY
```

<br/>

Fork -> https://github.com/lfs262/secops/

<br/>

В Jenkins файле указываем:

remote.host = "192.168.1.12"

<br/>

### Enforcing Compliance with Ansible

```
$ git clone https://github.com/wildmakaka/secops.git
$ cd secops/ansible
```

<br/>

```
$ ansible -i environments/prod all -m ping
localhost | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.10"
    },
    "changed": false,
    "ping": "pong"
}
```

<br/>

```
$ ansible-galaxy collection install devsec.hardening
```

<br/>

```
$ sudo ansible-playbook compliance.yaml
```

<br/>

```
$ inspec exec --no-distinct-exit ~/tmp/linux-baseline/
Profile Summary: 53 successful controls, 2 control failures, 3 controls skipped
Test Summary: 178 successful, 4 failures, 3 skipped
```

<br/>

```
    stage("Scan with InSpec") {
        sshCommand remote: remote, sudo: false, command: 'inspec exec ~/tmp/linux-baseline/'
    }
```

<br/>

### Debug

```
        stage("whoami") {
            sshCommand remote: remote, sudo: true, command: 'whoami'
        }
```
