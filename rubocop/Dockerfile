FROM ruby:2.5-alpine

RUN apk add --update bash

ENV PATH /usr/local/bundle/bin:$PATH

RUN gem install rubocop

ADD rubocop-tap tapify.rb /usr/local/bin/

CMD [ "rubocop" ]
