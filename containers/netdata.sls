# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import netdata with context %}
{% set fqdn = grains['fqdn'] %}

include:
  - containers.local

netdata:
  docker_container.running:
    - name: netdata
    - hostname: netdata
    - image: netdata/netdata:v1.13.0-amd64
    - restart_policy: always
    - log_driver: journald
    - cap_add: SYS_PTRACE
    - networks:
      - local_network
    - binds:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    - environment:
      - VIRTUAL_HOST: netdata.{{ fqdn }}
      - VIRTUAL_PORT: 19999
      - LETSENCRYPT_HOST: netdata.{{ fqdn }}
      - LETSENCRYPT_EMAIL: {{ netdata.email }}
      - PGID: 999
    - require:
      - service: docker
      - docker_network: local_network



