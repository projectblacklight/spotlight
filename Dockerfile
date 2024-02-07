ARG RUBY_VERSION=3.0.6
ARG ALPINE_VERSION=3.16
FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION

ARG RAILS_VERSION=6.1.6

ENV SPOTLIGHT_ENGINE_PATH /spotlight/engine
ENV SPOTLIGHT_GEM /spotlight/engine
ENV RAILS_QUEUE inline

RUN apk --no-cache upgrade && \
  apk add --no-cache \
  build-base \
  curl \
  gcompat \
  git \
  imagemagick \
  less \
  libxml2-dev \
  libxslt-dev \
  nodejs \
  postgresql-dev \
  shared-mime-info \
  sqlite-dev \
  tini \
  tzdata \
  yarn \
  zip

RUN addgroup --gid 10001 --system spotlight && \
  adduser --uid 10000 --system \
  --ingroup spotlight --home /spotlight spotlight

USER spotlight
RUN gem update bundler
RUN gem install --no-document rails -v "${RAILS_VERSION}"

COPY --chown=10000:10001 . /spotlight/engine
WORKDIR /spotlight/engine
RUN bundle install --jobs "$(nproc)"

RUN mkdir -p /spotlight/app
WORKDIR /spotlight/app

RUN SKIP_TRANSLATION=yes rails _${RAILS_VERSION}_ new . -j webpack --force --template=../engine/template.rb
RUN bundle add pg
RUN bin/yarn add @babel/plugin-proposal-private-methods --dev
RUN bin/yarn add @babel/plugin-proposal-private-property-in-object
RUN SKIP_TRANSLATION=yes DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile

ENTRYPOINT ["/sbin/tini", "--", "/spotlight/engine/bin/docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]
