FROM alpine:3.6
MAINTAINER Brian Ustas <brianustas@gmail.com>

ARG APP_PATH="/srv/www/cubecraft"

RUN apk add --update \
  nodejs \
  nodejs-npm \
  && rm -rf /var/cache/apk/*

# CoffeeScript
RUN npm install -g coffeescript@1.6.3

WORKDIR $APP_PATH
COPY . $APP_PATH
VOLUME $APP_PATH
