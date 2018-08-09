FROM koalaman/shellcheck-alpine:v0.5.0

RUN apk add --no-cache bash ruby \
	&& apk add --no-cache --virtual .build-deps ruby-dev gcc make libc-dev \
	&& gem install json --no-ri --no-rdoc \
	&& apk del .build-deps

COPY tapify.rb shellcheck-tap /usr/local/bin/
