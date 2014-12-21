FROM ubuntu:14.04
MAINTAINER Brian Ustas <brianustas@gmail.com>

RUN apt-get -y update && \
    apt-get -y install git

RUN git clone https://github.com/ustasb/cubecraft.git /srv/www/cubecraft && \
    rm -rf /srv/www/cubecraft/.git

WORKDIR /srv/www/cubecraft

VOLUME /srv/www/cubecraft
