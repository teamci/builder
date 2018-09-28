FROM ruby:2.5-alpine

RUN sed -i -e 's/dl-cdn/dl-4/' /etc/apk/repositories \
	&& apk add --no-cache bash \
	&& apk add --no-cache --virtual .build-deps ruby-dev gcc make libc-dev \
	&& gem install rubocop -v '0.57.2' \
	&& apk del .build-deps

ADD rubocop-tap tapify.rb /usr/local/bin/

CMD [ "rubocop-tap" ]
