FROM garethr/kubeval:0.7.1-offline

RUN sed -i -e 's/dl-cdn/dl-4/' /etc/apk/repositories \
	&& apk add --update --no-cache bash ruby \
	&& apk add --no-cache --virtual .build-deps build-base ruby-dev \
	&& gem install json --no-ri --no-rdoc \
	&& apk del .build-deps

RUN ln -s /kubeval /usr/local/bin

COPY is-manifest.rb kubeval-tap /usr/bin/

ENTRYPOINT [ "sh", "-c" ]

CMD [ "kubeval-tap" ]
