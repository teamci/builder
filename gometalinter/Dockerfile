FROM golang:1.10-alpine

RUN apk add --update ruby ruby-dev build-base bash git \
	&& go get -u gopkg.in/alecthomas/gometalinter.v2 \
	&& ln -sf $GOPATH/bin/gometalinter.v2 $GOPATH/bin/gometalinter \
	&& gometalinter --install\
	&& gem install json --no-ri --no-rdoc

COPY tapify.rb gometalinter-tap /usr/bin/

CMD [ "gometalinter-tap" ]
