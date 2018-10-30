#!/bin/sh
cd /mnt/src
exec php7 /opt/phan/phan "$@"
