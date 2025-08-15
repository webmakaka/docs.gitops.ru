---
layout: page
title: Разворачиваем Gitlab в виртуальной машине Vagrant подготовленными скриптами
description: Разворачиваем Gitlab в виртуальной машине Vagrant подготовленными скриптами
keywords: devops, gitops, cvs, gitlab, setup, vagrant, git runner
permalink: /tools/git/gitlab/vagrant/
---

# Разворачиваем Gitlab в виртуальной машине Vagrant подготовленными скриптами

Делаю  
22.03.2019

<br/>

**Из видеокурса "Continuous Integration on Gitlab":**  
https://www.udemy.com/continuous-integration-on-gitlab/

Материал нашел в интернетах.

<br/>

Для начала в hosts хостовой машине прописываю:

    # vi /etc/hosts

    192.168.0.10 my-gitlab-ce

<br/>

    $ mkdir ~/vagrant-gitlab && cd ~/vagrant-gitlab

<br/>

    $ vagrant plugin install vagrant-hostmanager

<br/>

    $ git clone https://bitbucket.org/sysadm-ru/gitlab4ci.git .

<br/>

    $ vagrant up

 <br/>

    $ vagrant ssh my-gitlab-ce

 <br/>

    $ sudo gitlab-rake gitlab:env:info

    System information
    System:
    Current User:	git
    Using RVM:	no
    Ruby Version:	2.5.3p105
    Gem Version:	2.7.6
    Bundler Version:1.16.6
    Rake Version:	12.3.2
    Redis Version:	3.2.12
    Git Version:	2.18.1
    Sidekiq Version:5.2.5
    Go Version:	unknown

    GitLab information
    Version:	11.8.3
    Revision:	3f81311
    Directory:	/opt/gitlab/embedded/service/gitlab-rails
    DB Adapter:	postgresql
    URL:		http://my-gitlab-ce
    HTTP Clone URL:	http://my-gitlab-ce/some-group/some-project.git
    SSH Clone URL:	git@my-gitlab-ce:some-group/some-project.git
    Using LDAP:	no
    Using Omniauth:	yes
    Omniauth Providers:

    GitLab Shell
    Version:	8.4.4
    Repository storage paths:
    - default: 	/var/opt/gitlab/git-data/repositories
    Hooks:		/opt/gitlab/embedded/service/gitlab-shell/hooks
    Git:		/opt/gitlab/embedded/bin/git

<br/>

    $ curl http://my-gitlab-ce
    <html><body>You are being <a href="http://my-gitlab-ce/users/sign_in">redirected

<br/>

http://my-gitlab-ce
