FROM php:7-cli-alpine

RUN apk add --no-cache bash ruby jq \
	&& apk add --no-cache --virtual .build-deps ruby-dev build-base \
	&& pear install PHP_CodeSniffer \
	&& gem install json --no-ri --no-rdoc \
	&& apk del .build-deps

ADD phpcs-tap tapify.rb /usr/local/bin/

CMD [ "phpcs-tap" ]
