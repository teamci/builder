FROM ruby:2.5-alpine

RUN apk add --no-cache bash \
	&& apk add --no-cache --virtual .build-deps ruby-dev gcc make libc-dev \
	&& gem install oj -v '3.6.0' \
	&& apk del .build-deps

RUN mkdir -p /usr/src/app
ENV PATH /usr/src/app/bin:$PATH
WORKDIR /usr/src/app

COPY . /usr/src/app

CMD [ "check-syntax" ]
