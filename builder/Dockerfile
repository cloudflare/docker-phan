FROM alpine:3.3
COPY scripts/mkimage-phan.bash /
COPY scripts/docker-entrypoint.sh /
RUN apk --no-cache add bash
RUN apk --no-cache add --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ tini
ENTRYPOINT ["/sbin/tini", "-g", "--", "/mkimage-phan.bash"]
