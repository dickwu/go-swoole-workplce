FROM golang:1.15.0-buster

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive

# install build essentials
RUN apt-get update && \
    apt-get install -y wget build-essential pkg-config --no-install-recommends

ENV SWOOLE_VERSION=4.5.2

# php
RUN apt -y install lsb-release apt-transport-https ca-certificates && \
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
	apt update && \
	apt install -q -y composer php7.4 php7.4-dev php7.4-mysql php7.4-bcmath php7.4-bz2 php7.4-curl php7.4-gd php7.4-mbstring php7.4-zip php7.4-xmlreader

# php protobuf
RUN pecl install protobuf && \
	echo "extension=protobuf" > /etc/php/7.4/cli/conf.d/20-protobuf.ini
# php imagick
RUN echo "" | pecl install imagick && \
	echo "extension=imagick" > /etc/php/7.4/cli/conf.d/20-imagick.ini
# php igbinary
RUN echo no | pecl install igbinary && \
	echo "extension=igbinary" > /etc/php/7.4/cli/conf.d/20-igbinary.ini
# php redis
RUN echo yes | pecl install redis && \
	echo "extension=redis" > /etc/php/7.4/cli/conf.d/20-redis.ini
# php swoole
RUN cd && \
	wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz && \
	tar xvzf v${SWOOLE_VERSION}.tar.gz && \
	cd swoole* && \
	phpize && \
	./configure  --enable-openssl --enable-sockets --enable-http2 --enable-mysqlnd && \
	make && make install && \
	echo "extension=swoole" > /etc/php/7.4/cli/conf.d/20-swoole.ini

VOLUME /usr/code
WORKDIR /usr/code
