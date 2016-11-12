FROM ruby:2.2.0
RUN apt-get update -qq && apt-get install -y build-essential
RUN mkdir /elvis
WORKDIR /elvis
ADD Gemfile /elvis/Gemfile
ADD Gemfile.lock /elvis/Gemfile.lock
RUN bundle install
ADD . /elvis
