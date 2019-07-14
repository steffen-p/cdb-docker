FROM nextcloud:fpm-alpine

COPY backup.sh /

RUN set -ex; \
    apk add --no-cache mysql-client; \
    apk add --no-cache restic; \
    chown www-data:root /backup.sh; \
    chmod u+x /backup.sh

RUN echo '30 2 * * * php occ preview:pre-generate; \
          sh /backup.sh >> /var/www/html/data/backup.log 2>&1' \
          >> /var/spool/cron/crontabs/www-data
