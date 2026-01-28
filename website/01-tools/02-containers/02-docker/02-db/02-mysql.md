---
layout: page
title: Docker MySQL DataBase
description: Docker MySQL DataBase
keywords: env, docker, database, mysql
permalink: /tools/containers/docker/db/mysql/
---

<br/>

# Docker MySQL DataBase

<br/>

```
$ mkdir -p ~/projects/dev/db/mysql/
$ cd ~/projects/dev/db/mysql/
```

<br/>

```
$ vi docker-compose.yml
```

<br/>

```yaml
version: '3'
services:
  mysql-dev:
    restart: always
    image: mysql:8.1
    ports:
      - '3306:3306'
    volumes:
      - ./mysql:/etc/mysql/conf.d
    environment:
      MYSQL_DATABASE: db
      MYSQL_ROOT_PASSWORD: pA55w0rd123
```

<br/>

```
$ docker-compose up
```

<br/>

```
$ telnet localhost 3306
```

<br/>

```
$ sudo apt update -y
$ sudo apt install -y mysql-client
```

<br/>

```
$ mysql --user=root --password=pA55w0rd123 -h 127.0.0.1 db
```

<br/>

```
mysql> SELECT DATABASE();
+------------+
| DATABASE() |
+------------+
| nextapp    |
+------------+
1 row in set (0.00 sec)

mysql> use nextapp
Database changed
```

<br/>

```sql
-- Просто пример
INSERT INTO Issue (title, description, status, createdAt, updatedAt)
VALUES
  ('Website Login Issue 1', 'Users are unable to log in to the website 1', 'OPEN', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Monitor shows youtube', 'Cant start working', 'CLOSED', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 3', 'Users are unable to log in to the website 3', 'IN_PROGRESS', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 4', 'Users are unable to log in to the website 4', 'OPEN', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 5', 'Users are unable to log in to the website 5', 'CLOSED', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 6', 'Users are unable to log in to the website 6', 'IN_PROGRESS', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 7', 'Users are unable to log in to the website 7', 'OPEN', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 8', 'Users are unable to log in to the website 8', 'CLOSED', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 9', 'Users are unable to log in to the website 9', 'IN_PROGRESS', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 10', 'Users are unable to log in to the website 10', 'OPEN', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 11', 'Users are unable to log in to the website 11', 'CLOSED', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 12', 'Users are unable to log in to the website 12', 'IN_PROGRESS', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 13', 'Users are unable to log in to the website 13', 'OPEN', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 14', 'Users are unable to log in to the website 14', 'CLOSED', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 15', 'Users are unable to log in to the website 15', 'OPEN', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 16', 'Users are unable to log in to the website 16', 'CLOSED', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 17', 'Users are unable to log in to the website 17', 'OPEN', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 18', 'Users are unable to log in to the website 18', 'IN_PROGRESS', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 19', 'Users are unable to log in to the website 19', 'CLOSED', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 20', 'Users are unable to log in to the website 20', 'OPEN', '2023-09-01 10:00:00', '2023-09-01 12:00:00'),
  ('Website Login Issue 21', 'Users are unable to log in to the website 21', 'CLOSED', '2023-09-01 10:00:00', '2023-09-01 12:00:00');
```
