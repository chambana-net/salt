# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import pleroma with context %}

include:
  - containers.local

pleroma:
  docker_container.running:
    - name: pleroma
    - image: pandentia/pleroma:latest
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
      - private_network
    - binds:
      - pleroma_uploads:/pleroma/uploads:rw
      - {{ pleroma.config }}:/pleroma/config/prod.secret.exs
    - environment:
      - VIRTUAL_HOST: {{ pleroma.virtual_host }}
      - VIRTUAL_PORT: 4000
      - LETSENCRYPT_HOST: {{ pleroma.virtual_host }}
      - LETSENCRYPT_EMAIL: {{ pleroma.letsencrypt_email }}
    - require:
      - service: docker
      - docker_container: pleroma-postgres
      - docker_network: local_network
      - docker_network: private_network

pleroma-postgres:
  docker_container.running:
    - name: pleroma-postgres
    - image: postgres:11
    - restart_policy: always
    - log_driver: journald
    - networks:
      - private_network
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
      - docker_network: private_network

pleroma_uploads:
  docker_volume.present:
    - name: pleroma_uploads
    - driver: local

pleroma_db_data:
  docker_volume.present:
    - name: pleroma_postgres
    - driver: local
