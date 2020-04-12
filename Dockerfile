FROM ruby:2.6-alpine3.11

# Patch to get global bins
ENV BUNDLE_BIN="$GEM_HOME/bin"
ENV PATH $BUNDLE_BIN:$PATH
ENV RAILS_ENV=production

RUN mkdir -p "$BUNDLE_BIN"
RUN chmod 777 "$BUNDLE_BIN"

RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc && \
    apk --update add --virtual build-dependencies build-base postgresql-dev && \
    apk --update add libpq bash libxml2 libxml2-dev libxml2-utils libxslt \
                        openssl zlib tzdata git openssh file imagemagick \
                        nodejs && \
    gem update --system && \
    gem install bundler

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle config set deployment 'true' && \
    bundle install --jobs 8 && \
    apk del build-dependencies

ADD . ./

# ENV DEVISE_SECRET_KEY_BASE=123
# ENV SECRET_KEY_BASE=123

RUN bundle exec rails assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
