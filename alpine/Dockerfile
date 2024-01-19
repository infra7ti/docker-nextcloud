# Dockerfile for Nextcloud

ARG VERSION_MAJOR=${VERSION_MAJOR}
FROM nextcloud:${VERSION_MAJOR}-fpm-alpine AS base

# Security updates
ARG TARGET_OS_VERSION=${TARGET_OS_VERSION}
ARG SEC_EDGE=${SEC_EDGE:-false}
ARG SEC_UPDATES=${SEC_UPDATES:-}
RUN set -ex; \
  if [ "${SEC_EDGE:-false}" == "true" ]; then \
    sed -i "s|v\d+\.\d+\..*|edge|" /etc/apk/repositories; \
  fi; \
  apk -U add --no-cache $(echo -e ${SEC_UPDATES}); \
  if [ "${SEC_EDGE:-false}" == "true" ]; then \
    sed -i "s|edge|v${TARGET_OS_VERSION}|" /etc/apk/repositories; \
  fi;

# -- Main image ----------------------------------------------------------------

FROM scratch

ARG VERSION
ENV NEXTCLOUD_VERSION ${VERSION}
ENV PHP_MEMORY_LIMIT 512M
ENV PHP_UPLOAD_LIMIT 512M

VOLUME /var/www/html
COPY --from=base / /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]

# --
