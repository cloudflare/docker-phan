#!/usr/bin/env bash

# This mkimage-phan.bash is a modified version from
# https://github.com/gliderlabs/docker-alpine/blob/master/builder/scripts/mkimage-alpine.bash.

declare REL="${REL:-edge}"
declare MIRROR="${MIRROR:-http://nl.alpinelinux.org/alpine}"

set -eo pipefail; [[ "$TRACE" ]] && set -x

build() {
  declare mirror="$1" rel="$2"

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

  # install runtime dependencies into rootfs
  {
    apk --no-cache --root "$rootfs" --keys-dir /etc/apk/keys add --initdb php7 php7-json php7-sqlite3 php7-mbstring php7-pcntl php7-dom tini
    cp /docker-entrypoint.sh "$rootfs"/docker-entrypoint.sh
  } >&2

  # install composer
  {
    cd /tmp
    EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
    php7 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_SIGNATURE=$(php7 -r "echo hash_file('SHA384', 'composer-setup.php');")

    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
    then
      >&2 echo 'ERROR: Invalid installer signature'
      rm composer-setup.php
      exit 1
    fi

    php7 composer-setup.php --quiet
    RESULT=$?
    rm composer-setup.php
    mv composer.phar /usr/local/bin
    exit $RESULT
  } >&2

  # install phan
  mkdir -p "$rootfs/opt/"
  {
    cd "$rootfs/opt/"
    if [[ "$rel" == "edge" ]]; then
      git clone --single-branch --depth 1 https://github.com/etsy/phan.git
    else
      git clone -b $rel --single-branch --depth 1 https://github.com/etsy/phan.git
    fi
    cd phan

    php7 /usr/local/bin/composer.phar --prefer-dist --no-dev --ignore-platform-reqs --no-interaction install
    rm -rf .git
  } >&2

  # install php-ast
  {
    cd /tmp
    git clone -b "v0.1.5" --single-branch --depth 1 https://github.com/nikic/php-ast.git
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
  while getopts "r:m:s" opt; do
    case $opt in
      r) REL="$OPTARG";;
      m) MIRROR="$OPTARG";;
      s) STDOUT=1;;
    esac
  done

  build "$MIRROR" "$REL"
}

main "$@"
