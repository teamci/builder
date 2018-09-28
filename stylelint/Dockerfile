FROM node:7-alpine

RUN sed -i -e 's/dl-cdn/dl-4/' /etc/apk/repositories \
	&& apk add --no-cache bash ruby jq \
	&& apk add --no-cache --virtual .build-deps ruby-dev build-base \
	&& npm install -g stylelint stylelint-config-standard \
	&& gem install json --no-ri --no-rdoc \
	&& apk del .build-deps

ADD stylelint-tap tapify.rb /usr/local/bin/
RUN mkdir /defaults
COPY config.json /defaults

CMD [ "stylelint-tap" ]
