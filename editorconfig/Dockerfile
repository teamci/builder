FROM python:3.6-alpine

RUN apk add --no-cache bash \
 && pip install editorconfig

ADD lint-editorconfig /usr/local/bin

CMD [ "lint-editorconfig" ]
