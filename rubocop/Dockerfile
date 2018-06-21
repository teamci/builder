FROM ruby:2.5

RUN gem install rubocop -v '0.57.2'

ADD rubocop-tap tapify.rb /usr/local/bin/

CMD [ "rubocop" ]
