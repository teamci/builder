FROM ubuntu:18.04

RUN apt-get update && apt-get install -y ruby npm
RUN npm install -g eslint

ADD tapify.rb eslint-tap /usr/local/bin/

CMD [ "eslint-tap" ]
