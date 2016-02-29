FROM alpine:3.3
ADD rootfs.tar.gz /
ENTRYPOINT ["tini", "-g", "--", "/docker-entrypoint.sh"]
