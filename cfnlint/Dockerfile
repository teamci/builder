FROM python:3-alpine

RUN sed -i -e 's/dl-cdn/dl-4/' /etc/apk/repositories && \
	apk add --no-cache bash \
	&& pip install cfn-lint

ADD is-template.py tapify.py cfnlint-tap /usr/bin/

CMD [ "cfnlint-tap" ]
