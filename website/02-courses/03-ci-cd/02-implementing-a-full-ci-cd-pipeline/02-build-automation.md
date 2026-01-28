---
layout: page
title: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - 03. Автоматизация сборки
description: Видеокурсы по DevOps - Внедрение полного конвейера CI/CD - 03. Автоматизация сборки
keywords: Видеокурсы по DevOps, Внедрение полного конвейера CI/CD, Автоматизация сборки
permalink: /courses/ci-cd/implementing-a-full-ci-cd-pipeline/build-automation/
---

# [A Cloud Guru, Linux Academy] Внедрение полного конвейера CI/CD [RUS, 2020]

<br/>

## 03. Автоматизация сборки

<br/>

### 11. Установка Gradle

Устанавливаю <a href="//javadev.org/devtools/jdk/setup/linux/">JDK8</a>

Устанавливаю <a href="//javadev.org/devtools/build/gradle/linux/ubuntu/">Gradle</a>

<br/>

### Запуск Gradle Wrapper

    $ cd cicd-pipeline-train-schedule-git
    $ gradle wrapper

<br/>

Добавить в .gitignore

<br/>

```
.gradle
```

<br/>

    $ ./gradlew build
