---
layout: page
title: Подготовка окружения запуска приложений и программирования в Linux на Golang
description: Подготовка окружения запуска приложений и программирования в Linux на Golang
keywords: dev, golang, linux, setup
permalink: /dev/go/setup/
---

# Подготовка окружения запуска приложений и программирования в Linux на Golang

<br/>

### Мой вариант инсталляции GO (в каталог /opt)

<br/>

**Делаю:**  
2026.01.25

<br/>

```
$ mkdir ~/tmp
$ cd ~/tmp/
$ wget --no-check-certificate https://golang.org/dl/go1.24.12.linux-amd64.tar.gz
```

<br/>

```
$ tar -xvzpf go1.24.12.linux-amd64.tar.gz
$ sudo mkdir -p /opt/go.1.24
$ sudo mv go/* /opt/go.1.24/
$ sudo ln -s /opt/go.1.24/ /opt/go
```

<br/>

```
$ mkdir -p ~/projects/golang/
```

<br/>

```
$ sudo vi /etc/profile.d/golang.sh
```

<br/>

```
#### GO 1.24 ########################

export GO_HOME=/opt/go
export PATH=${GO_HOME}/bin:$PATH

export PATH=${HOME}/go/bin:$PATH

#### GO 1.24 ########################
```

<br/>

```
$ sudo chmod +x /etc/profile.d/golang.sh
$ source /etc/profile.d/golang.sh
```

<br/>

```
$ go version
go version go1.24.12 linux/amd64
```

<br/>

### Доп плагины для разработки на GO в Visual Studio Code

```
^Ctrl + Shift + x

Rich Go Language support for Visual Studio
```

<br/>

```
^Ctrl + p
> Go Install/Update Tools
```

<br/>

### Металинтеры

https://github.com/golangci/golangci-lint/

```
$ go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.50.1

$ /home/marley/go/bin/golangci-lint --version

$ /home/marley/go/bin/golangci-lint run .
```

<br/>

```
$ vi .golangci.yml
```

<br/>

```
// вариант конфига
https://raw.githubusercontent.com/wildmakaka/diasoft-golang-quick-start/refs/heads/main/.golangci.yml
```

<br/>

```
$ golangci-lint run . --config ../.golangci.yml
```
