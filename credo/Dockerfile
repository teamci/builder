FROM elixir:1.6-alpine

RUN sed -i -e 's/dl-cdn/dl-4/' /etc/apk/repositories \
	&& apk add --no-cache bash ruby jq \
	&& apk add --no-cache --virtual .build-deps ruby-dev build-base curl \
	&& gem install json --no-ri --no-rdoc \
	&& mkdir -p /usr/src/credo /usr/src/bunt \
	&& curl -sSL -o bunt.tar.gz 'https://github.com/rrrene/bunt/archive/v0.2.0.tar.gz' \
	&& tar -zxf bunt.tar.gz -C /usr/src/bunt --strip-components 1 \
	&& cd /usr/src/bunt \
	&& mix local.hex --force \
	&& mix archive.build \
	&& mix archive.install --force \
	&& curl -SSL -o credo.tar.gz 'https://github.com/rrrene/credo/archive/v0.9.3.tar.gz' \
	&& mkdir -p /usr/src/credo \
	&& tar -zxf credo.tar.gz -C /usr/src/credo --strip-components 1 \
	&& cd /usr/src/credo \
	&& mix local.hex --force \
	&& mix deps.get \
	&& mix archive.build \
	&& mix archive.install --force \
	&& apk del .build-deps

ADD credo-tap tapify.rb /usr/local/bin/

CMD [ "credo-tap" ]
