FROM python:3.6-alpine

RUN apk add --update bash
RUN pip install editorconfig

ADD lint-editorconfig /usr/local/bin

CMD [ "lint-editorconfig" ]
