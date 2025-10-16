---
layout: page
title: Docker PostgreSQL DataBase
description: Docker PostgreSQL DataBase
keywords: env, docker, database, postgresql
permalink: /tools/containers/docker/db/postgresql/
---

# Docker PostgreSQL DataBase

<br/>

**Делаю:**  
2025.05.02

<br/>

```
$ mkdir -p ~/projects/dev/db/postgres/
$ cd ~/projects/dev/db/postgres/
```

<br/>

```
$ sudo apt install -y postgresql-client-common postgresql-client
```

<br/>

```
$ sudo vi /etc/hosts
```

<br/>

```
127.0.0.1 postgreshost
```

<br/>

```
$ vi .env
```

<br/>

```
DATABASE_HOST=postgreshost
DATABASE_NAME=postgresdb
DATABASE_PORT=5432
DATABASE_USER=admin1
DATABASE_PASSWORD=pA55w0rd123
```

<br/>

```
$ vi docker-compose.yml
```

<br/>

```yaml
version: '3'
services:
  postgres:
    container_name: postgres
    image: postgres:17.4-alpine3.21
    restart: always
    hostname: ${DATABASE_HOST}
    ports:
      - ${DATABASE_PORT}:5432
    environment:
      POSTGRES_DB: ${DATABASE_NAME}
      POSTGRES_USER: ${DATABASE_USER}
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD}
    volumes:
      - ./PGDATA:/var/lib/postgresql/data
    healthcheck:
      test:
        [
          'CMD-SHELL',
          "psql -U ${DATABASE_USER} -d ${DATABASE_NAME} -c 'SELECT 1' || exit 1",
        ]
      interval: 10s
      retries: 5
      start_period: 5s
```

<br/>

```
$ docker-compose up
```

<br/>

**Example:**  
https://github.com/webmakaka/Uber-Eats-Clone

<br/>

**Import data into postgresql from sql dump file**

```
$ cd data/

// Connect
$ PGPASSWORD=pA55w0rd123 psql -U admin1 -h postgreshost -p 5432 -d postgresdb

// Import data from sql
// $ PGPASSWORD=pA55w0rd123 psql -U admin1 -h postgreshost -p 5432 -d postgresdb < go_movies.sql
```

<br/>

```
$ PGPASSWORD=pA55w0rd123 psql --host=postgreshost --username=admin1 --port=5432 --dbname=go_movies -c 'select id, title, description, year, release_date, rating, runtime, mpaa_rating, created_at, updated_at from movies where id = 1'
```

<br/>

```
$ PGPASSWORD=pA55w0rd123 psql --host=postgreshost --username=admin1 --port=5432 --dbname=go_movies -c "INSERT INTO movies_genres (movie_id, genre_id, created_at, updated_at) VALUES (1, 1, '2021-05-19', '2021-05-19');"
```

<br/>

### Run pgadmin in docker container:

```
$ docker run -e PGADMIN_DEFAULT_EMAIL='postgres@test.com' -e PGADMIN_DEFAULT_PASSWORD='password1234' -p 5555:80 --name pgadmin dpage/pgadmin4
```

<br/>

http://localhost:5555/

```
login: postgres@test.com
pass: password1234
```

<br/>

To connect, use host ip address

<br/>

### Docker-compose config with postgres and pgadmin

<br/>

[From video course](https://github.com/webmakaka/Microservices-and-Distributed-Systems)

<br/>

```yaml
services:
  postgres:
    container_name: postgres
    image: postgres
    environment:
      POSTGRES_USER: amigoscode
      POSTGRES_PASSWORD: password
      PGDATA: /data/postgres
    volumes:
      - postgres:/data/postgres
    ports:
      - '5432:5432'
    networks:
      - postgres
    restart: unless-stopped

  pgadmin:
    container_name: pgadmin
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL:-pgadmin4@pgadmin.org}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD:-admin}
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    volumes:
      - pgadmin:/var/lib/pgadmin
    ports:
      - '5050:80'
    networks:
      - postgres
    restart: unless-stopped

networks:
  postgres:
    driver: bridge

volumes:
  postgres:
  pgadmin:
```
