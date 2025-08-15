---
layout: page
title: Инсталляция Ansible в Ubuntu 22.04
description: Инсталляция Ansible в Ubuntu 22.04
keywords: tools, ansible, setup, ubuntu
permalink: /tools/ansible/setup/ubuntu/
---

# Инсталляция Ansible в Ubuntu 22.04

Делаю:  
2025.08.15

```
$ sudo apt-add-repository -y ppa:ansible/ansible

$ sudo apt update && sudo apt install -y ansible

$ ansible --version
ansible [core 2.17.13]
```
