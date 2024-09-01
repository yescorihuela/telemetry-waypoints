FROM ruby:3.2.0

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

RUN mkdir /app

WORKDIR /app

COPY ./Gemfile /app/Gemfile

COPY ./Gemfile.lock /app/Gemfile.lock

RUN bundle install

RUN bundle update

COPY . /app

COPY ./entrypoints/entrypoint.sh /usr/bin

RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]