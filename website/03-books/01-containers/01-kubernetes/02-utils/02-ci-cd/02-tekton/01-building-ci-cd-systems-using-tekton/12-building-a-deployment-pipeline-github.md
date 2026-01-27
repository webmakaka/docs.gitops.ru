---
layout: page
title: Building CI/CD Systems Using Tekton - Building a Deployment Pipeline
description: Building CI/CD Systems Using Tekton - Building a Deployment Pipeline
keywords: books, ci-cd, tekton, Building a Deployment Pipeline
permalink: /books/containers/kubernetes/utils/ci-cd/tekton/building-ci-cd-systems-using-tekton/building-a-deployment-pipeline-github/
---

# [OK!] Chapter 13. Building a Deployment Pipeline

<br/>

**Делаю:**  
2025.12.13

<br/>

Тоже самое. За исключением мелочей, вроде установки ngrok, который в РФ не работает.

<br/>

### [Устанавливаю ngrok](/tools/clouds/google/google-cloud-shell/get-access-ngrok/)

<br/>

```
$ ngrok http 8080
Forwarding                    https://b26d9bc503c7.ngrok-free.app -> http://localhost:8080
```

<br/>

```
Fork -> https://github.com/PacktPublishing/tekton-book-app
```

<br/>

**Github -> MyProject -> Settings -> Webhooks -> Add webhook**

<br/>

• Payload URL: This is your ngrok URL. (https://b26d9bc503c7.ngrok-free.app)
• Content type: application/json.
• Secret: Use the secret token you created earlier. You can view your token with the echo ${TEKTON_SECRET_TOKEN} command.

<br/>

Which events would you like to trigger this webhook?

- Just the push event

<br/>

Add Webhook

<br/>

Вносим изменения в исходный код.

https://github.com/<YOUR_USERNAME>/tekton-book-app/blob/main/server.js

<br/>

```
change: "here"
```

<br/>

Меняем на

```
change: "the end"
```

<br/>

```
Commit changes
```
