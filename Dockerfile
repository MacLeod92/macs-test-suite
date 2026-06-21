FROM alpine:3.20

ARG VERSION=0.1.0
ENV VERSION=${VERSION}

RUN apk add --no-cache busybox-extras

COPY entrypoint.sh /entrypoint.sh
COPY VERSION /VERSION

RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:8080/health || exit 1

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
