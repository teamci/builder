FROM python:3-alpine

RUN apk add bash && pip install cfn-lint

ADD is-template.py tapify.py cfnlint-tap /usr/bin/

CMD [ "cfnlint-tap" ]
