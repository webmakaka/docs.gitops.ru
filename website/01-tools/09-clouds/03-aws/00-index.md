---
layout: page
title: Clouds Amazon
description: Deploy Clouds, AWS
keywords: Deploy, Clouds, AWS
permalink: /tools/clouds/aws/
---

# Clouds Amazon (AWS)

<br/>

https://discord.com/channels/1018779355155013693/1023168134775054356/1023168593996808223

```
// Инсталляция cli в ubuntu linux

$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip

$ sudo ./aws/install

$ aws --version

$ aws configure
```

```
AWS Access Key ID [None]: <type key ID here>
AWS Secret Access Key [None]: <type access key>
Default region name [None]: <choose region (e.g. "us-east-1", "eu-west-1")>
Default output format [None]: <leave blank>
```

<br/>

### Прикрутить свой домен к AWS без переноса его в AWS и использованием CloudFlare

https://medium.com/@bobthomas295/combining-aws-serverless-with-cloudflare-sub-domains-338a1b7b2bd

<br/>

**В заработавшем варианте:**

Cloudflare -> SSL/TLS -> Full (strict)

В DNS

```
Type: CNAME
Name: _6be2d4c99b2c4199a3abf29716f8fd4e
Target: _f13db5c800d33fd3174874c84f677c33.bwlshdtstt.acm-validations.aws
Proxy status: DNS only
TTL: Auto

Type: CNAME
Name: api
Target: d2siadvb5bmoyb.cloudfront.net
Proxy status: Proxied
TTL: Auto

Type: CNAME
Name: webmak.site
Target: d2siadvb5bmoyb.cloudfront.net
Proxy status: Proxied
TTL: Auto
```

<!--

<a href="https://emea-resources.awscloud.com/rus-ua-cis19-webinar-how-to-split-monolith-application-into-micro-services" rel="nofollow">RUS/UA/CIS19: Webinar - How to split monolith application into micro services</a>

-->

<a href="https://aws.amazon.com/ru/getting-started/serverless-web-app/" rel="nofollow">Создание бессерверного интернет-приложения</a>

<a href="https://docs.jsdev.ru/schools/rs-school/nodejs/aws/" rel="nofollow">Лекции по AWS в RS School</a>
