# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import synapse with context %}

include:
  - containers.local

synapse:
  docker_container.running:
    - name: synapse
    - image: matrixdotorg/synapse:latest
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
      - private_network
    - binds:
      - synapse_data:/data:rw
    - environment:
      - VIRTUAL_HOST: {{ synapse.virtual_host }}
      - VIRTUAL_PORT: 8008
      - LETSENCRYPT_HOST: {{ synapse.letsencrypt_host }}
      - LETSENCRYPT_EMAIL: {{ synapse.letsencrypt_email }}
      - UID: nobody
      - GID: nobody
    - require:
      - service: docker
      - docker_container: synapse-postgres
      - docker_network: local_network
      - docker_network: private_network

synapse-postgres:
  docker_container.running:
    - name: synapse-postgres
    - image: postgres:11
    - restart_policy: always
    - log_driver: journald
    - networks:
      - private_network
    - binds:
      - synapse_postgres:/var/lib/postgresql/data:rw
    - environment:
      - PGDATA: /var/lib/postgresql/data/pgdata
      - POSTGRES_DB: synapse
      - POSTGRES_USER: synapse
      - POSTGRES_PASSWORD: {{ synapse.postgres_password }}
    - require:
      - service: docker
      - docker_volume: synapse_db_data
      - docker_network: private_network

synapse_data:
  docker_volume.present:
    - name: synapse_data
    - driver: local

synapse_db_data:
  docker_volume.present:
    - name: synapse_postgres
    - driver: local
