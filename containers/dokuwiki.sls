# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import dokuwiki with context %}

include:
  - containers.local

{% for site, settings in dokuwiki.sites.items() %}
{{ site }}:
  docker_container.running:
    - name: {{ site }}
    - image: chambana/dokuwiki:latest
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - chambana_{{ site }}_config:/etc/dokuwiki
      - chambana_{{ site }}_data:/var/lib/dokuwiki
    - environment:
      - VIRTUAL_HOST: {{ settings.virtual_host }}
      - LETSENCRYPT_HOST: {{ settings.letsencrypt_host }}
      - LETSENCRYPT_EMAIL: {{ settings.letsencrypt_email }}
    - require:
      - service: docker
      - docker_network: local_network
      - docker_volume: {{ site }}_config
      - docker_volume: {{ site }}_data

{{ site }}_config:
  docker_volume.present:
    - name: chambana_{{ site }}_config
    - driver: local

{{ site }}_data:
  docker_volume.present:
    - name: chambana_{{ site }}_data
    - driver: local
{% endfor %}
