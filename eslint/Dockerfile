FROM node:7-alpine

RUN apk add --no-cache bash ruby \
	&& apk add --no-cache --virtual .build-deps ruby-dev build-base \
	&& npm install -g eslint@4.19.1 \
	&& gem install json --no-ri --no-rdoc \
	&& apk del .build-deps

ADD tapify.rb eslint-tap /usr/local/bin/

CMD [ "eslint-tap" ]
