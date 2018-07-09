FROM ruby:2.5-alpine

RUN apk add --update bash ruby-dev gcc make libc-dev

RUN gem install rubocop -v '0.57.2'

ADD rubocop-tap tapify.rb /usr/local/bin/

CMD [ "rubocop" ]
