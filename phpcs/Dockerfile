FROM php:7-cli-alpine

RUN apk add --update bash ruby ruby-dev build-base jq
RUN pear install PHP_CodeSniffer
RUN gem install json --no-ri --no-rdoc

ADD phpcs-tap tapify.rb /usr/local/bin/

CMD [ "phpcs-tap" ]
