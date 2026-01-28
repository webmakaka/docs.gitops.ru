---
layout: page
title: Use GitHub Actions to build and push a container image
description: Use GitHub Actions to build and push a container image
keywords: github ations, build, push, containers
permalink: /courses/ci-cd/use-github-actions-to-build-and-push-a-container-image/
---

# [Geert Baeke] Use GitHub Actions to build and push a container image [ENG, 2020]

<br/>

Делаю:  
07.11.2021

<br/>

https://www.youtube.com/watch?v=FYIRvqdP3pQ

<br/>

### Поехали

<br/>

**Форкаем к себе:**  
https://github.com/gbaeke/python-msi

<br/>

https://github.com/wildmakaka/python-msi/settings/secrets/actions

<br/>

**Заданы переменны:**

```
GHCR_PASSWORD
SNYK
```

<br/>

**build-push.yml**

```yaml
name: Publish Docker Image

on:
  push:
    branches: [master]
  release:
    types:
      - published
jobs:
  build:
    if: "!contains(github.event.head_commit.message, 'skip ci')"
    runs-on: ubuntu-latest

    steps:
      - name: Check out
        uses: actions/checkout@v2

      - name: Docker meta
        id: docker_meta
        uses: crazy-max/ghaction-docker-meta@v1
        with:
          images: ghcr.io/${{ github.repository_owner }}/python-msi
          tag-sha: true
          tag-edge: false
          tag-latest: true

      # - name: Set up QEMU
      #   uses: docker/setup-qemu-action@v1

      # - name: Set up Docker Buildx
      #   uses: docker/setup-buildx-action@v1

      - name: Login to GHCR
        uses: docker/login-action@v1
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GHCR_PASSWORD }}

      - name: Build image
        uses: docker/build-push-action@v2
        with:
          tags: ${{ steps.docker_meta.outputs.tags }}
          file: ./Dockerfile

      # - name: Monitor image for vulnerabilities with Snyk
      #   uses: snyk/actions/docker@master
      #   env:
      #       SNYK_TOKEN: ${{ secrets.SNYK }}
      #   with:
      #       command: monitor
      #       image: 'ghcr.io/gbaeke/rgapi:main'
      #       args: --file=Dockerfile --project-name=python-msi

      - name: Push image
        uses: docker/build-push-action@v2
        with:
          push: true
          tags: ${{ steps.docker_meta.outputs.tags }}
          file: ./Dockerfile
```

<br/>

Мдя. Нужно зайти на странице в Packages. Нажать на крестик с "Clear current search query, filters, and sorts", чтобы отобразились packages.

Вроде догадался. Все из-за того, что по умолчанию packages - приватные!

Интересно, как сделать, чтобы по умолчанию были public?
