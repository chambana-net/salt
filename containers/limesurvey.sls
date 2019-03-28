# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import limesurvey with context %}

include:
  - containers.local

limesurvey:
  docker_container.running:
    - name: limesurvey
    - image: acspri/limesurvey:3.16.0
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - environment:
      - LIMESURVEY_DB_HOST: limesurvey-db
      - LIMESURVEY_DB_PASSWORD: {{ limesurvey.mariadb_password }}
      - LIMESURVEY_USE_INNODB: "true"
      - LIMESURVEY_ADMIN_USER: {{ limesurvey.admin_user }}
      - LIMESURVEY_ADMIN_NAME: {{ limesurvey.admin_name }}
      - LIMESURVEY_ADMIN_PASSWORD: {{ limesurvey.admin_password }}
      - LIMESURVEY_ADMIN_EMAIL: {{ limesurvey.admin_email }}
      - VIRTUAL_HOST: {{ limesurvey.virtual_host }}
      - VIRTUAL_PORT: 80
      - LETSENCRYPT_HOST: {{ limesurvey.virtual_host }}
      - LETSENCRYPT_EMAIL: {{ limesurvey.admin_email }}
    - require:
      - service: docker
      - docker_container: limesurvey-db
      - docker_network: local_network

limesurvey-db:
  docker_container.running:
    - name: limesurvey-db
    - image: mariadb:10.4
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - limesurvey_db_data:/var/lib/mysql:rw
    - environment:
      - MYSQL_ROOT_PASSWORD: {{ limesurvey.mariadb_password }}
    - require:
      - service: docker
      - docker_volume: limesurvey_db_data
      - docker_network: local_network

limesurvey_db_data:
  docker_volume.present:
    - name: limesurvey_db_data
    - driver: local
