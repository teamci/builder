FROM ruby:2.5-alpine

RUN apk add --update ruby-dev gcc make libc-dev

RUN gem install oj -v 3.6.0

RUN mkdir -p /usr/src/app
ENV PATH /usr/src/app/bin:$PATH
WORKDIR /usr/src/app

COPY . /usr/src/app

CMD [ "check-syntax" ]
