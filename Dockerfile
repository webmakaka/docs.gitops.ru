# Build layer
# FROM ruby:latest
FROM ruby:2.7

# Install program to configure locales
RUN apt-get update && apt-get install -y locales vim less
RUN dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
  /usr/sbin/update-locale LANG=C.UTF-8

# Install needed default locale for Makefly
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
  locale-gen

# Set default locale for the environment
ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

RUN mkdir -p /project
WORKDIR /project
# RUN gem install bundler
RUN gem install bundler -v 2.4.22
COPY Gemfile Gemfile
RUN bundle install
COPY . .
RUN bundle exec jekyll build
RUN bundle exec htmlproofer ./_site --file-ignore /.git/,./_site/404.html --only-4xx --check-html --allow-hash-href --assume-extension

# Hosting Layer
FROM nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=0 /project/_site/ /usr/share/nginx/html/
