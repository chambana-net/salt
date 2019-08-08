# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import keycloak with context %}

include:
  - containers.local

keycloak:
  docker_container.running:
    - name: keycloak
    - image: jboss/keycloak:6.0.1
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - environment:
      - KEYCLOAK_USER: eviloverlord
      - KEYCLOAK_PASSWORD: {{ keycloak.password }}
      - KEYCLOAK_HOSTNAME: {{ keycloak.main_host }}
      - PROXY_ADDRESS_FORWARDING: true
      - VIRTUAL_HOST: {{ keycloak.virtual_host }}
      - VIRTUAL_PORT: 8080
      - LETSENCRYPT_HOST: {{ keycloak.virtual_host }}
      - LETSENCRYPT_EMAIL: {{ keycloak.letsencrypt_email }}
      - DB_USER: keycloak
      - DB_VENDOR: postgres
      - DB_ADDR: keycloak-postgres
      - DB_PASSWORD: {{ keycloak.postgres_password }}
    - require:
      - service: docker
      - docker_container: keycloak-postgres
      - docker_network: local_network

keycloak-postgres:
  docker_container.running:
    - name: keycloak-postgres
    - image: postgres:11
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - chambana_keycloak_postgres:/var/lib/postgresql/data:rw
    - environment:
      - PGDATA: /var/lib/postgresql/data/pgdata
      - POSTGRES_DB: keycloak
      - POSTGRES_USER: keycloak
      - POSTGRES_PASSWORD: {{ keycloak.postgres_password }}
    - require:
      - service: docker
      - docker_volume: keycloak_db_data
      - docker_network: local_network

keycloak_db_data:
  docker_volume.present:
    - name: chambana_keycloak_postgres
    - driver: local
