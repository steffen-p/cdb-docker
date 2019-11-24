# **C**loud, **D**NS and **B**ackup - *a homeserver setup described in docker*
This project is intended to serve as an exemplary homeserver setup.
It describes the infrastructure in docker-compose for easy deployment on new setups.
The information were gathered from various resources. Special thanks to all projects listed in [references](#References).

## Features

- **nextcloud** (fpm) with MariaDB
    - cron job for preview generator plugin
    - ssl by automatically generated self-signed certificate
- **restic** backup solution
        - automatic backup of data and sql database
    - numerous [backends](https://restic.readthedocs.io/en/stable/030_preparing_a_new_repo.html) supported
- **pihole** dns proxy
    - blocks advertisement and malicious urls
    - includes nice GUI for statistics
- **nginx** reverse proxy
    - proxies the requests to services (nextcloud resp. pihole)

## How to start

0. `git clone https://github.com/steffen-p/cdb-docker; cd cdb-docker`
1. Change *host ip* address in `docker-compose.yml` (`192.168.1.132` in my case)
2. `docker-compose build --pull`
3. `docker-compose up -d`¹
4. Change default DNS-Proxy to your *host ip*
5. Go to your browser and connect to [nextcloud](https://nextcloud.example.lan) (accept exception for self-signed certificate) or [pihole](http://pihole.example.lan)
6. Optionally: Install *preview generator* plugin according to this [installation guide](https://github.com/rullzer/previewgenerator#how-to-use-the-app)²

¹ Note: If you get errors during start up of *pihole* container like `Error starting userland proxy: listen tcp 0.0.0.0:53: bind: address already in use`, make sure you don't already have dns service listening on these ports. This may be true in case you use libvirt for virtual network bridges (qemu etc.) or just *systemd-resolvd* (a dns resolver for local dns queries often running in popular distributions like *Ubuntu* or *Fedora*).

² Note: This plugin is especially useful if you run on small SoCs or embedded devices. Managing and viewing your pictures in the cloud will be awfully slow without pre-generated thumbnails and previews.

## Settings
### Environment

Many settings can be done via environment variables as already used in this example. For a comprehensive summary on all options please refere to the respective project documentation linked in [references](#References).

### Restic
If `RESTIC_REPOSITORY` is set, the backup script runs once per night. Putting nextcloud in maintenance mode during this action.
Many backends are supported by restic and can be configured via environment added to **cron** container. For reference please see the following example for a *Backblaze* backend.

``` diff
cron:
     build: ./nextcloud
     restart: always
     volumes:
       - nextcloud:/var/www/html
       - data:/var/www/html/data
       - config:/var/www/html/config
+    environment:
+      - RESTIC_REPOSITORY=b2:yourbucket:/resticrepo
+      - B2_ACCOUNT_ID=009885347c68e3535000000003
+      - B2_ACCOUNT_KEY=K00sdfasdfhfkjhsadkjfsomekeyb0
+      - RESTIC_PASSWORD=Y28uniqeresticrepopassword34234F
+      - RESTIC_FORGET_ARGS=--prune --keep-last 7 --keep-monthly 1
     env_file:
       - db.env
     entrypoint: /cron.sh
```

`RESTIC_FORGET_ARGS` is not provided by *restic* but will be passed to `restic forget` command as an argument within the backup script.

## How to migrate from existing nextcloud setup

You might be already using a native nextcloud instance and want to migrate. In this scenario you will start of with a [fresh installation](#How-to-Start) as well. After the first start you will want to copy your data to the newly created docker volumes as described [here](https://github.com/nextcloud/docker#migrating-an-existing-installation)
Note: See `nextcloud/backup.sh` on how to dump MySQL database from your old setup.

## References
- [nextloud docker](https://github.com/nextcloud/docker)
- [pihole docker](https://github.com/pi-hole/docker-pi-hole)
- [resticker](https://github.com/djmaze/resticker)
- [restic docs](https://restic.readthedocs.io/en/latest/index.html)
- [docker docs](https://docs.docker.com/)
- [installation guide](https://github.com/rullzer/previewgenerator#how-to-use-the-app)
