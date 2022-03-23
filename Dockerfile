FROM ruby:2.5.5-alpine3.8

RUN mkdir -p /srv/code

WORKDIR /srv/code
COPY . /srv/code

RUN apk add --update \
  curl curl-dev \
  libxml2-dev \
  build-base \
  libxml2-dev \
  libxslt-dev \
  mysql-client \
  mysql-dev \
  tzdata \
  nodejs \
  linux-headers \
  pcre pcre-dev

# manages the applications in ruby
RUN gem install bundler --version 2.0.1

RUN bundle init
# install default version of passenger
# this is a web server 
RUN gem install passenger --version 6.0.2

RUN bundle install -j64
RUN passenger-config compile-agent --auto --optimize && \
  passenger-config install-standalone-runtime --auto --url-root=fake --connect-timeout=1 && \
  passenger-config build-native-support

EXPOSE 9393
RUN rm -rf /srv/code/public/assets
# RUN rm -rf /srv/code/public/assets && rake assets:precompile
RUN rm -rf /srv/code/public/assets
ENTRYPOINT bundle exec passenger start --port 3000 --log-level 3 --min-instances 5 --max-pool-size 5 
#bRUN rm -rf /srv/code/public/assets && rake assets:precompile