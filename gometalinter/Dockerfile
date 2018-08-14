FROM golang:1.10-alpine

RUN apk add --no-cache bash ruby git subversion mercurial bzr build-base \
	&& apk add --no-cache --virtual .build-deps ruby-dev \
	&& go get -u gopkg.in/alecthomas/gometalinter.v2 \
	&& ln -sf $GOPATH/bin/gometalinter.v2 $GOPATH/bin/gometalinter \
	&& gometalinter --install \
	&& gem install json --no-ri --no-rdoc \
	&& apk del .build-deps

COPY tapify.rb gometalinter-tap /usr/bin/

CMD [ "gometalinter-tap" ]
