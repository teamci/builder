FROM node:7-alpine

RUN apk add --no-cache bash ruby jq \
	&& apk add --no-cache --virtual .build-deps ruby-dev build-base \
	&& npm install -q -g eslint@4.19.1 eslint-plugin-vue eslint-plugin-react eslint-plugin-ember \
	&& gem install json --no-ri --no-rdoc \
	&& apk del .build-deps

ADD tapify.rb eslint-tap /usr/local/bin/

CMD [ "eslint-tap" ]
