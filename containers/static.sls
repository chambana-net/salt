# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import static with context %}

include:
  - containers.local

{% for site, settings in static.sites.items() %}
{{ site }}:
  docker_container.running:
    - name: {{ site }}
    - image: chambana/nginx:latest
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - {{ settings.data_dir }}:/var/www:ro
    - environment:
      - VIRTUAL_HOST: {{ settings.virtual_host }}
      - LETSENCRYPT_HOST: {{ settings.letsencrypt_host }}
      - LETSENCRYPT_EMAIL: {{ settings.letsencrypt_email }}
    - require:
      - service: docker
      - docker_network: local_network
{% endfor %}
