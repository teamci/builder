FROM node:7-alpine

RUN apk add --update bash ruby ruby-dev build-base jq
RUN npm install -g stylelint stylelint-config-standard
RUN gem install json --no-ri --no-rdoc

ADD stylelint-tap tapify.rb /usr/local/bin/
RUN mkdir /defaults
COPY config.json /defaults

CMD [ "stylelint-tap" ]
