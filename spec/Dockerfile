FROM ruby:2.5-alpine

RUN bundle config --global frozen 1

RUN adduser -u 1000 -G users tester -s /bin/sh -D

RUN mkdir /build && chown tester: /build
WORKDIR /build

COPY Gemfile Gemfile.lock ./
RUN set -ex; \
    apk --no-cache --virtual .build-deps add build-base libxml2-dev libxslt-dev; \
    apk --no-cache add bash; \
    bundle install; \
    apk del .build-deps

COPY docker-entrypoint.sh /usr/local/bin/
RUN set -ex; \
    delgroup ping; \
    apk add --no-cache su-exec; \
    chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
