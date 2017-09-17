#!/usr/bin/env bash

# This mkimage-phan.bash is a modified version from
# https://github.com/gliderlabs/docker-alpine/blob/master/builder/scripts/mkimage-alpine.bash.

declare REL="${REL:-edge}"
declare MIRROR="${MIRROR:-http://nl.alpinelinux.org/alpine}"
declare AST="${AST:-0.1.5}"

set -eo pipefail; [[ "$TRACE" ]] && set -x

build() {
  declare mirror="$1" rel="$2" ast="$3"

  # configure rootfs
  local rootfs
  rootfs="$(mktemp -d "${TMPDIR:-/var/tmp}/docker-phan-rootfs-XXXXXXXXXX")"
  mkdir -p "$rootfs/etc/apk/"

  # configure apk mirror
  {
    echo "$mirror/edge/main"
    echo "$mirror/edge/community"
  } | tee "/etc/apk/repositories" "$rootfs/etc/apk/repositories" >&2

  # install PHP7 dependencies and build dependencies
  {
    apk --no-cache add php7 php7-json php7-sqlite3 php7-mbstring git build-base autoconf curl php7-dev php7-openssl php7-phar php7-dom
  } >&2


  # install composer
  {
    cd /tmp
    curl -O https://getcomposer.org/download/1.5.1/composer.phar
    printf "2745e7b8cced2e97f84b9e9cb0f9c401702f47cecea5a67f095ac4fa1a44fb80  composer.phar" | sha256sum -c
    mv composer.phar /usr/local/bin
  } >&2

  # install runtime dependencies into rootfs
  {
    apk --no-cache --root "$rootfs" --keys-dir /etc/apk/keys add --initdb php7 php7-json php7-sqlite3 php7-mbstring php7-pcntl php7-dom tini
    cp /docker-entrypoint.sh "$rootfs"/docker-entrypoint.sh
  } >&2

  # install phan
  mkdir -p "$rootfs/opt/"
  {
    cd "$rootfs/opt/"
    if [[ "$rel" == "edge" ]]; then
      git clone --single-branch --depth 1 https://github.com/phan/phan.git
    else
      git clone -b $rel --single-branch --depth 1 https://github.com/phan/phan.git
    fi
    cd phan

    php7 /usr/local/bin/composer.phar --prefer-dist --no-dev --ignore-platform-reqs --no-interaction install
    rm -rf .git
    rm -rf tests vendor/symfony/console/Tests vendor/symfony/debug/Tests ./vendor/symfony/debug/Resources/ext/tests
  } >&2

  # install php-ast
  {
    cd /tmp
    git clone -b "v${ast}" --single-branch --depth 1 https://github.com/nikic/php-ast.git
    cd php-ast
    phpize7
    ./configure --with-php-config=php-config7
    make INSTALL_ROOT="$rootfs" install

    printf "extension=ast.so" >> "$rootfs"/etc/php7/php.ini
  } >&2


  tar -z -f rootfs.tar.gz --numeric-owner -C "$rootfs" -c .
  [[ "$STDOUT" ]] && cat rootfs.tar.gz

  return 0
}

main() {
  while getopts "a:r:m:s" opt; do
    case $opt in
      r) REL="$OPTARG";;
      a) AST="$OPTARG";;
      m) MIRROR="$OPTARG";;
      s) STDOUT=1;;
    esac
  done

  build "$MIRROR" "$REL" "$AST"
}

main "$@"
