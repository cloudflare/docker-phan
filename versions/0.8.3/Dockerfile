FROM alpine:3.3
ADD rootfs.tar.gz /
ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
