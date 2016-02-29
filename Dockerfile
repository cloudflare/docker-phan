FROM alpine:3.3

COPY ./docker-entrypoint.sh /
ADD ./rootfs.tar.gz /
ENTRYPOINT ["tini", "-g", "--", "/docker-entrypoint.sh"]
