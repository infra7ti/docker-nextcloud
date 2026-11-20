# syntax=docker/dockerfile:1
# Dockerfile for Nextcloud

ARG VERSION_MAJOR=${VERSION_MAJOR}
FROM nextcloud:${VERSION_MAJOR}-fpm-alpine AS base-hardened

# Security updates & hardening
ARG SEC_EDGE=${SEC_EDGE:-false}
ARG SEC_UPDATES=${SEC_UPDATES:-}
RUN set -ex; \
  apk -U upgrade --no-cache; \
  \
  if [ -n "${SEC_UPDATES}" ]; then \
    if [ "${SEC_EDGE}" = "true" ]; then \
      MIRROR=$(head -n 1 /etc/apk/repositories | sed -E 's|/v[0-9]+\.[0-9]+/.*||'); \
      apk add --no-cache --upgrade \
        --repository="${MIRROR}/edge/main" \
        --repository="${MIRROR}/edge/community" \
        ${SEC_UPDATES}; \
    else \
      apk add --no-cache --upgrade ${SEC_UPDATES}; \
    fi; \
  fi; \
  \
  rm -rf \
    /sbin/apk \
    /etc/apk \
    /var/cache/apk/* \
    /usr/share/apk \
    /usr/share/man/* \
    /usr/share/doc/* \
    /tmp/* \
    /var/tmp/*; \
  \
  sed -i -E 's|^([^:]+:[^:]+:[0-9]+:[0-9]+:[^:]*:[^:]*):/bin/(ba)?sh$|\1:/sbin/nologin|' /etc/passwd; \
  \
  chown -R root:root /usr/src/nextcloud; \
  chmod -R go-w /usr/src/nextcloud

# -- Main image ----------------------------------------------------------------

FROM scratch

ARG VERSION
ENV NEXTCLOUD_VERSION ${VERSION}
ENV PHP_MEMORY_LIMIT 512M
ENV PHP_UPLOAD_LIMIT 512M

VOLUME /var/www/html
COPY --from=base-hardened / /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]

# --
