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
      - synapse_network
    - port_bindings:
      - 8448:8448/tcp
    - binds:
      - chambana_synapse_data:/data:rw
      - {{ synapse.letsencrypt_dir}}/{{ synapse.virtual_host }}:/certs:ro
    - environment:
      - VIRTUAL_HOST: {{ synapse.virtual_host }}
      - VIRTUAL_PORT: 8008
      - LETSENCRYPT_HOST: {{ synapse.letsencrypt_host }}
      - LETSENCRYPT_EMAIL: {{ synapse.letsencrypt_email }}
      - UID: 65534
      - GID: 65534
    - require:
      - service: docker
      - docker_container: synapse-postgres
      - docker_network: local_network
      - docker_network: synapse_network

synapse-postgres:
  docker_container.running:
    - name: synapse-postgres
    - image: postgres:11
    - restart_policy: always
    - log_driver: journald
    - networks:
      - synapse_network
    - binds:
      - chambana_synapse_postgres:/var/lib/postgresql/data:rw
    - environment:
      - PGDATA: /var/lib/postgresql/data/pgdata
      - POSTGRES_DB: synapse
      - POSTGRES_USER: synapse
      - POSTGRES_PASSWORD: {{ synapse.postgres_password }}
    - require:
      - service: docker
      - docker_volume: synapse_db_data
      - docker_network: synapse_network

synapse_data:
  docker_volume.present:
    - name: chambana_synapse_data
    - driver: local

synapse_db_data:
  docker_volume.present:
    - name: chambana_synapse_postgres
    - driver: local

synapse_network:
  docker_network.present:
    - name: synapse_network
    - driver: bridge
    - internal: True
