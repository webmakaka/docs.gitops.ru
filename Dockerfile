# Stage 1: Build stage
FROM ruby:3.3-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    locales \
    libcurl4 \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

WORKDIR /project

RUN gem install bundler

COPY Gemfile ./
RUN bundle install

COPY . .
RUN bundle exec jekyll build

RUN bundle exec htmlproofer ./_site

# Stage 2: Hosting stage
FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /project/_site/ /usr/share/nginx/html/
