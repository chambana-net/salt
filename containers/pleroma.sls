# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import pleroma with context %}

include:
  - containers.local

pleroma_src:
  git.latest:
    - name: https://git.pleroma.social/pleroma/pleroma.git
    - target: /var/tmp/pleroma
    - force_reset: True

pleroma_image:
  docker_image.present:
    - build: /var/tmp/pleroma
    - tag: local
    - require:
      - service: docker
      - git: pleroma_src

pleroma:
  docker_container.running:
    - name: pleroma
    - image: pleroma_image:local
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
      - pleroma_network
    - binds:
      - pleroma_data:/var/lib/pleroma:rw
    - environment:
      - DOMAIN: {{ pleroma.domain }}
      - ADMIN_EMAIL: hostmaster@chambana.net
      - NOTIFY_EMAIL: notifications@chambana.net
      - DB_HOST: pleroma-postgres
      - DB_PASS: {{ pleroma.postgres_password }}
      - VIRTUAL_HOST: {{ pleroma.virtual_host }}
      - VIRTUAL_PORT: 4000
      - LETSENCRYPT_HOST: {{ pleroma.virtual_host }}
      - LETSENCRYPT_EMAIL: {{ pleroma.letsencrypt_email }}
    - require:
      - service: docker
      - docker_volume: pleroma_data
      - docker_container: pleroma-postgres
      - docker_network: local_network
      - docker_network: pleroma_network

pleroma-postgres:
  docker_container.running:
    - name: pleroma-postgres
    - image: postgres:11
    - restart_policy: always
    - log_driver: journald
    - networks:
      - pleroma_network
    - binds:
      - pleroma_postgres:/var/lib/postgresql/data:rw
    - environment:
      - PGDATA: /var/lib/postgresql/data/pgdata
      - POSTGRES_DB: pleroma
      - POSTGRES_USER: pleroma
      - POSTGRES_PASSWORD: {{ pleroma.postgres_password }}
    - require:
      - service: docker
      - docker_volume: pleroma_db_data
      - docker_network: pleroma_network

pleroma_data:
  docker_volume.present:
    - name: pleroma_data
    - driver: local

pleroma_db_data:
  docker_volume.present:
    - name: pleroma_postgres
    - driver: local

pleroma_network:
  docker_network.present:
    - name: pleroma_network
    - driver: bridge
    - internal: True
