FROM nextcloud:fpm-alpine

COPY backup.sh /

RUN set -ex; \
    apk add --no-cache mysql-client; \
    apk add --no-cache restic; \
    apk add --no-cache busybox-suid; \
    apk add --no-cache tzdata; \
    chown www-data:root /backup.sh; \
    chmod u+x /backup.sh

RUN ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

RUN echo "Europe/Berlin" > /etc/timezone

RUN echo '30 2 * * * php /var/www/html/occ preview:pre-generate -vvv \
         >> /var/www/html/data/preview-gen.log 2>&1; \
         sh /backup.sh >> /var/www/html/data/backup.log 2>&1' \
         >> /var/spool/cron/crontabs/www-data
