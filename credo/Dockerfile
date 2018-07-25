FROM elixir:1.6-alpine

RUN apk add --update bash ruby ruby-dev build-base jq curl
RUN gem install json --no-ri --no-rdoc

RUN mkdir -p /usr/src/credo /usr/src/bunt
RUN curl -sSL -o bunt.tar.gz 'https://github.com/rrrene/bunt/archive/v0.2.0.tar.gz' \
	&& tar -zxf bunt.tar.gz -C /usr/src/bunt --strip-components 1 \
	&& cd /usr/src/bunt \
	&& mix local.hex --force \
	&& mix archive.build \
	&& mix archive.install --force

RUN curl -SSL -o credo.tar.gz 'https://github.com/rrrene/credo/archive/v0.9.3.tar.gz' \
	&& mkdir -p /usr/src/credo \
	&& tar -zxf credo.tar.gz -C /usr/src/credo --strip-components 1 \
	&& cd /usr/src/credo \
	&& mix local.hex --force \
	&& mix deps.get \
	&& mix archive.build \
	&& mix archive.install --force

ADD credo-tap tapify.rb /usr/local/bin/

CMD [ "credo-tap" ]
