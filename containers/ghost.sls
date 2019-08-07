# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import ghost with context %}

include:
  - containers.local

{% for site, settings in ghost.sites.items() %}
{{ site }}:
  docker_container.running:
    - name: {{ site }}
    - image: ghost:latest
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - chambana_{{ site }}:/var/lib/ghost/content:rw
    - environment:
      - VIRTUAL_HOST: {{ settings.virtual_host }}
      - VIRTUAL_PORT: 2368
      - LETSENCRYPT_HOST: {{ settings.letsencrypt_host }}
      - LETSENCRYPT_EMAIL: {{ settings.letsencrypt_email }}
    - require:
      - service: docker
      - docker_network: local_network
      - docker_volume: {{ site }}_ghost

{{ site }}_ghost:
  docker_volume.present:
    - name: chambana_{{ site }}
    - driver: local
{% endfor %}

