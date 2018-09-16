FROM garethr/kubeval:0.7.1-offline

COPY repositories /etc/apk/repositories

RUN apk add --update --no-cache bash ruby \
	&& apk add --no-cache --virtual .build-deps build-base ruby-dev \
	&& gem install json --no-ri --no-rdoc \
	&& apk del .build-deps

RUN ln -s /kubeval /usr/local/bin

COPY is-manifest.rb kubeval-tap /usr/bin/

ENTRYPOINT [ "sh", "-c" ]

CMD [ "kubeval-tap" ]
