FROM alpine:edge
MAINTAINER ukatama dev.ukatama@gmail.com

RUN apk add -X http://dl-3.alpinelinux.org/alpine/edge/testing/ --no-cache socat etcd
ADD ambassador.sh /usr/local/bin/ambassador.sh

ENTRYPOINT ["/usr/local/bin/ambassador.sh"]
