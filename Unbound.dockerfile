FROM alpine
EXPOSE 53
RUN apk add --no-cache unbound inotify-tools
COPY docker-unbound-entrypoint.sh /
ENTRYPOINT [ "sh", "/docker-unbound-entrypoint.sh" ]
