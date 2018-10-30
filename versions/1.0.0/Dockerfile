ARG ALPINE_VERSION=3.8
ARG APK_MIRROR="http://nl.alpinelinux.org/alpine"
ARG AST_VERSION=0.1.5
ARG PHAN_RELEASE="edge"

# Baseline
# ==========
FROM alpine:$ALPINE_VERSION AS base

# configure apk mirror
RUN echo "$APK_MIRROR/edge/main" >> "/etc/apk/repositories" \
    && echo "$APK_MIRROR/edge/community" >> "/etc/apk/repositories"

# install runtime dependencies
RUN apk --no-cache add \
    php7 \
    php7-dom \
    php7-json \
    php7-mbstring \
    php7-pcntl \
    php7-sqlite3 \
    php7-tokenizer \
    tini

# Builder
# ==========
FROM base AS builder

ARG AST_VERSION
ARG PHAN_RELEASE

# install build dependencies
RUN apk --no-cache add git build-base autoconf curl php7-dev php7-openssl php7-phar

COPY --from=composer:1.7 /usr/bin/composer /usr/local/bin/composer

# install php-ast
RUN set -xe; \
    \
    mkdir -p /src; \
    cd /src; \
    \
    git clone -b "v${AST_VERSION}" --single-branch --depth 1 https://github.com/nikic/php-ast.git; \
    \
    cd php-ast; \
    phpize7; \
    ./configure --with-php-config=php-config7; \
    make install; \
    echo "extension=ast.so" >> /etc/php7/php.ini

# install phan
RUN set -xe; \
    \
    mkdir -p /src; \
    cd /src; \
    \
    if [[ "$PHAN_RELEASE" == "edge" ]]; then \
      git clone --single-branch --depth 1 https://github.com/phan/phan.git; \
    else \
      git clone -b $PHAN_RELEASE --single-branch --depth 1 https://github.com/phan/phan.git; \
    fi; \
    \
    cd phan; \
    /usr/local/bin/composer --prefer-dist --no-dev --no-interaction install; \
    rm -rf .git

# Runtime
# ==========
FROM base AS runtime

COPY --from=builder /src/phan /opt/phan
COPY --from=builder /usr/lib/php7/modules/ast.so /usr/lib/php7/modules/ast.so

RUN echo "extension=ast.so" >> /etc/php7/php.ini

COPY ./docker-entrypoint.sh /

VOLUME /mnt/src

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
