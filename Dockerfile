FROM alpine:3.7

RUN apk add --no-cache \
	bash

RUN mkdir -p /usr/src/app
ENV PATH /usr/src/app/bin:$PATH
WORKDIR /usr/src/app

COPY . /usr/src/app
