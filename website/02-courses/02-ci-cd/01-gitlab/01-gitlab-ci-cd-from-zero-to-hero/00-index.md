---
layout: page
title: TechWorld with Nana -  GitLab CI/CD
description: TechWorld with Nana -  GitLab CI/CD
keywords: Видеокурсы по DevOps, TechWorld with Nana, GitLab CI/CD
permalink: /courses/ci-cd/gitlab/gitlab-ci-cd-from-zero-to-hero/
---

# [Video Course][TechWorld with Nana] GitLab CI/CD - From Zero To Hero (2025) [ENG, 2022]

<br/>

<div align="center">
    <iframe width="853" height="480" src="https://www.youtube.com/embed/F7WMRXLUQRM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>

<br/>

Starting from chapter 2:

Simple demo Node.js project: https://gitlab.com/nanuchi/mynodeapp-cicd-project.git

<br/>

**5.3 Build Docker Image & Push to Private Registry**

Замена на kaniko

<br/>

```yaml
build_and_push:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:v1.9.0-debug
    entrypoint: ['']
  script:
    # Создаем конфиг с логином и паролем
    - mkdir -p /kaniko/.docker
    - echo '{"auths":{"https://index.docker.io/v1/":{"username":"webmakaka","password":"webmakaka-password"}}}' > /kaniko/.docker/config.json

    - |
      /kaniko/executor \
        --context . \
        --destination index.docker.io/webmakaka/mynodeapp-cicd-project:1.0
```

<br/>

Starting from chapter 7 (Microservices):
Microservice mono-repo: https://gitlab.com/nanuchi/mymicroservice-cicd

Microservice poly-repo: https://gitlab.com/mymicroservice-cicd

CI-templates (in the poly-repo group): https://gitlab.com/mymicroservice-cicd/ci-templates
