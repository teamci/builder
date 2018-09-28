FROM python:3.6-alpine

RUN sed -i -e 's/dl-cdn/dl-4/' /etc/apk/repositories \
 && apk add --no-cache bash \
 && pip install editorconfig

ADD lint-editorconfig /usr/local/bin

CMD [ "lint-editorconfig" ]
