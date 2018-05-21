FROM ruby:2.5

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN gem install sinatra thin

ADD config.ru /usr/src/app

CMD [ "rackup", "-o", "0.0.0.0" ]
