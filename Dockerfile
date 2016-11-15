FROM ruby:2.2.0
RUN apt-get update -qq \
    && apt-get install -yqq \
       mongodb-clients \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists

WORKDIR /elvis
COPY Gemfile* ./
RUN bundle install
COPY . .

CMD bundle exec rails s -p 3000 -b '0.0.0.0'
