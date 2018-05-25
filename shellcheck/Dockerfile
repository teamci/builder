FROM ruby:2.5

RUN apt-get update && apt-get install -y ghc cabal-install
RUN cabal update && cabal install ShellCheck

ENV PATH /root/.cabal/bin:$PATH

COPY tapify.rb shellcheck-tap /usr/local/bin/
