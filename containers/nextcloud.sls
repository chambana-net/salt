# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import nextcloud with context %}

include:
  - containers.local

nextcloud:
  docker_container.running:
    - name: nextcloud
    - image: nextcloud:apache
    - restart_policy: always
    - log_driver: journald
    - cap_add: SYS_NICE
    - networks:
      - local_network
    - binds:
      - {{ nextcloud.data_dir }}:/var/www/html:rw
      - /etc/nextcloud-extras/www.conf:/usr/local/etc/php-fpm.d/www.conf:ro
      - /etc/nextcloud-extras/custom.config.php:/var/www/html/config/custom.config.php:ro
    - environment:
      - POSTGRES_DB: nextcloud
      - POSTGRES_USER: nextcloud
      - POSTGRES_PASSWORD: {{ nextcloud.postgres_password }}
      - POSTGRES_HOST: nextcloud-db
      - NEXTCLOUD_ADMIN_USER: {{ nextcloud.admin_user }}
      - NEXTCLOUD_ADMIN_PASSWORD: {{ nextcloud.admin_password }}
      - NEXTCLOUD_TRUSTED_DOMAINS: {{ nextcloud.trusted_domains }}
      - VIRTUAL_HOST: {{ nextcloud.virtual_host }}
      - VIRTUAL_PORT: 80
      - LETSENCRYPT_HOST: {{ nextcloud.virtual_host }}
      - LETSENCRYPT_EMAIL: {{ nextcloud.email }}
    - require:
      - service: docker
      - docker_container: nextcloud-db
      - docker_container: nextcloud-redis
      - docker_network: local_network
      - file: nextcloud_php_conf
      - file: nextcloud_config

nextcloud-db:
  docker_container.running:
    - name: nextcloud-db
    - image: postgres:11
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - nextcloud_db_data:/var/lib/postgresql/data:rw
    - environment:
      - PGDATA: /var/lib/postgresql/data/pgdata
      - POSTGRES_USER: nextcloud
      - POSTGRES_PASSWORD: {{ nextcloud.postgres_password }}
      - POSTGRES_DB: whatever
    - require:
      - service: docker
      - docker_volume: nextcloud_db_data
      - docker_network: local_network

nextcloud_db_data:
  docker_volume.present:
    - name: nextcloud_db_data
    - driver: local

nextcloud-redis:
  docker_container.running:
    - name: nextcloud-redis
    - image: redis:5
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - nextcloud_redis_data:/data:rw
    - require:
      - service: docker
      - docker_volume: nextcloud_redis_data
      - docker_network: local_network

nextcloud_redis_data:
  docker_volume.present:
    - name: nextcloud_redis_data
    - driver: local

nextcloud_cron:
  file.managed:
    - name: /etc/systemd/system/nextcloud-cron.service
    - source: salt://containers/files/nextcloud-cron.service
    - user: root
    - group: root
    - mode: 0644

nextcloud_cron_timer:
  file.managed:
    - name: /etc/systemd/system/nextcloud-cron.timer
    - source: salt://containers/files/nextcloud-cron.timer
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: nextcloud-cron.timer
    - enable: True
    - require:
      - docker_container: nextcloud
      - file: nextcloud_cron_timer
      - file: nextcloud_cron

nextcloud_php_conf:
  file.managed:
    - name: /etc/nextcloud-extras/www.conf
    - source: salt://containers/files/www.conf
    - user: root
    - group: root
    - mode: 0644
    - makedirs: True

nextcloud_config:
  file.managed:
    - name: /etc/nextcloud-extras/custom.config.php
    - source: salt://containers/files/custom.config.php
    - user: root
    - group: root
    - mode: 0644
    - makedirs: True
