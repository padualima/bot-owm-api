FROM ruby:3.2.0

RUN apt-get update && apt-get install -qq -y --no-install-recommends \
  build-essential \
  libpq-dev \
  git-all \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem install bundler:2.4.3

WORKDIR /app

COPY Gemfile ./

ENV BUNDLE_PATH /gems

COPY . .

EXPOSE 3000
