FROM alpine:3.7

RUN apk add --update bats

RUN mkdir -p /usr/src/app
ADD self_test.bats /usr/src/app

CMD [ "bats", "/usr/src/app/self_test.bats" ]
