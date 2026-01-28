---
layout: page
title: 01. Сборка и push контейнеров в registry
description: 01. Сборка и push контейнеров в registry
keywords: devops, ci-cd, gitlab, kubernetes, docker, built and push
permalink: /samples/ci-cd/gitlab/kubernetes/build-and-push/
---

# 01. Сборка и push контейнеров в registry

<br/>

GitLab -> Project -> Settings -> CI/CD -> Variables

<br/>

Variables - не Protected

<br/>

![GitOps](/img/samples/ci-cd/gitlab/kubernetes/pic-lecture01-pic01.png 'Devops'){: .center-image }

<br/>

Планируется использовать registry, что на hub.docker.com

<br/>

```
CI_REGISTRY -> docker.io
REGISTRY_USER -> <Your Username>
REGISTRY_PASSWORD -> <Your Password>
```

<br/>

```
.gitlab-ci.yml
```

<br/>

```yaml
image: docker:stable

variables:
  DOCKER_TLS_CERTDIR: ''
  DOCKER_HOST: tcp://192.168.0.5:2375
  DOCKER_DRIVER: overlay2

services:
  - docker:stable-dind

before_script:
  - docker info
  - echo ${CI_REGISTRY}
  - echo ${REGISTRY_USER}
  - echo ${REGISTRY_PASSWORD} | docker login -u ${REGISTRY_USER} --password-stdin ${CI_REGISTRY}

stages:
  - build
  - release

backend-build:
  stage: build
  except:
    - tags
  script:
    - docker build ./apps/v1/app/backend/ -f ./apps/v1/app/backend/Dockerfile -t webmakaka/devops-backend:$CI_COMMIT_SHORT_SHA
    - docker push webmakaka/devops-backend:$CI_COMMIT_SHORT_SHA

backend-release:
  stage: release
  only:
    - tags
  script:
    - docker pull webmakaka/devops-backend:$CI_COMMIT_SHORT_SHA
    - docker tag webmakaka/devops-backend:$CI_COMMIT_SHORT_SHA webmakaka/devops-backend:$CI_COMMIT_TAG
    - docker push webmakaka/devops-backend:$CI_COMMIT_TAG

frontend-build:
  stage: build
  except:
    - tags
  script:
    - docker build ./apps/v1/app/frontend/ -f ./apps/v1/app/frontend/Dockerfile -t webmakaka/devops-frontend:$CI_COMMIT_SHORT_SHA
    - docker push webmakaka/devops-frontend:$CI_COMMIT_SHORT_SHA

frontend-release:
  stage: release
  only:
    - tags
  script:
    - docker pull webmakaka/devops-frontend:$CI_COMMIT_SHORT_SHA
    - docker tag webmakaka/devops-frontend:$CI_COMMIT_SHORT_SHA webmakaka/devops-frontend:$CI_COMMIT_TAG
    - docker push webmakaka/devops-frontend:$CI_COMMIT_TAG
```

<br/>

Как минимум "webmakaka" нужно заменить на свой логин.

<br/>

    $ git commit -am 'Add release stage'
    $ git push origin master
    $ git tag v0.0.1
    $ git push origin master --tags

<br/>

**Commit**

![GitOps](/img/samples/ci-cd/gitlab/kubernetes/pic-lecture01-pic02.png 'Devops'){: .center-image }

<br/>

**Release**

![GitOps](/img/samples/ci-cd/gitlab/kubernetes/pic-lecture01-pic03.png 'Devops'){: .center-image }

<br/>

**Результат на hub.docker.com**

![GitOps](/img/samples/ci-cd/gitlab/kubernetes/pic-lecture01-pic04.png 'Devops'){: .center-image }

<br/>

![GitOps](/img/samples/ci-cd/gitlab/kubernetes/pic-lecture01-pic05.png 'Devops'){: .center-image }
