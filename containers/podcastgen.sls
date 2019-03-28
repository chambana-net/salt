# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import podcastgen with context %}

include:
  - containers.local

{% for site, settings in podcastgen.sites.items() %}
{{ site }}:
  docker_container.running:
    - name: {{ site }}
    - image: chambana/podcastgen:latest
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - chambana_{{ site }}:/var/www:rw
    - environment:
      - VIRTUAL_HOST: {{ settings.virtual_host }}
      - LETSENCRYPT_HOST: {{ settings.letsencrypt_host }}
      - LETSENCRYPT_EMAIL: {{ settings.letsencrypt_email }}
    - require:
      - service: docker
      - docker_network: local_network
      - docker_volume: {{ site }}_podcastgen

{{ site }}_podcastgen:
  docker_volume.present:
    - name: chambana_{{ site }}
    - driver: local
{% endfor %}
