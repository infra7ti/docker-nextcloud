FROM nextcloud:fpm-alpine AS base

# Security updates
RUN set -ex; \
  sed -i 's|v3\.\d*|edge|' /etc/apk/repositories && \
  export SEC_UPDATES="\
    libjpeg-turbo=3.0.0-r1 \
    libraw=0.21.1-r2 \
  "; \
  apk -U add \
    --no-cache \
    ${SEC_UPDATES} && \
  sed -i 's|edge|v3.18|' /etc/apk/repositories 


FROM scratch

ENV NEXTCLOUD_VERSION 27.0.2
ENV PHP_MEMORY_LIMIT 512M
ENV PHP_UPLOAD_LIMIT 512M

VOLUME /var/www/html
COPY --from=base / /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
