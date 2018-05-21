FROM ruby:2.5

RUN mkdir -p /usr/src/app
ENV PATH /usr/src/app/bin:$PATH
WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

CMD [ "ls", "bin" ]
