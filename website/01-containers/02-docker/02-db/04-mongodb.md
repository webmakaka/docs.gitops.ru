---
layout: page
title: Docker MongoDB DataBase
description: Docker MongoDB DataBase
keywords: env, docker, database, mongodb
permalink: /tools/containers/docker/db/mongodb/
---

<br/>

# Docker MongoDB DataBase

<br/>

```
$ mkdir -p ~/projects/dev/db/mongo/
$ cd ~/projects/dev/db/mongo/
```

<br/>

```
$ vi docker-compose.yml
```

<br/>

```yaml
version: '3'
services:
  mongodb-dev:
    image: mongo
    restart: always
    ports:
      - '27017:27017'
    environment:
      MONGODB_DATABASE: mongo-database
```

<br/>

```
$ docker-compose up
```

<br/>

**Example:**
https://github.com/webmakaka/NestJS-Fundamentals-Course/blob/main/app/api-mongodb/docker-compose.yml

<br/>

### Another version with authentication

<br/>

```
$ vi docker-compose.yml
```

<br/>

```yaml
version: '3'
services:
  mongodb:
    image: mongo:4.4.6
    container_name: mongo
    restart: always
    ports:
      - ${MONGO_PORT}:27017
    environment:
      - MONGODB_DATABASE=${MONGO_DATABASE}
      - MONGO_INITDB_ROOT_USERNAME=${MONGO_LOGIN}
      - MONGO_INITDB_ROOT_PASSWORD=${MONGO_PASSWORD}
    volumes:
      - ./mongo-data-4.4:/data/db
    command: --wiredTigerCacheSizeGB 1.5
```

<br/>

**.env**

```
MONGO_HOST=localhost
MONGO_DATABASE=mongo-database

MONGO_LOGIN=admin
MONGO_PASSWORD=admin
MONGO_PORT=27017
```

<br/>

```
$ docker-compose up mongodb
```

<br/>

```sh
 | Successfully added user: {
 | 	"user" : "admin",
 | 	"roles" : [
 | 		{
 | 			"role" : "root",
 | 			"db" : "admin"
 | 		}
 | 	]
 | }
```

<br/>

### Another one version

[MERN-Stack-Front-To-Back-v2.0](https://github.com/webmakaka/MERN-Stack-Front-To-Back-v2.0)

<br/>

### Connect MongoDB from Ubuntu

```
$ sudo apt install mongodb-clients
```

<br/>

```
$ mongo "mongodb://localhost:27017/mongo-database"
```

<br/>

https://stackoverflow.com/questions/34559557/how-to-enable-authentication-on-mongodb-through-docker

<br/>

### Execute from docker-compose

```
// OK!
$ docker-compose exec mongo mongo "mongodb://admin:password@localhost:27017/logs?authSource=admin&readPreference=primary&directConnection=true&ssl=false" --quiet --eval "db.logs.find().pretty()"
```

<br/>

### Alpine add telnet package

```
$ docker exec -it mern-stack-front-to-back-api sh

# apk add busybox-extras
# telnet mongodb 27017
```

<br/>

### IDE Compass

https://www.mongodb.com/try/download/compass

<br/>

```
sudo dpkg -i mongodb-compass_1.36.4_amd64.deb
```
