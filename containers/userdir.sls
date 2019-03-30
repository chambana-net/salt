# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import userdir with context %}

include:
  - containers.local

{% for site, settings in userdir.sites.items() %}
{{ site }}:
  docker_container.running:
    - name: {{ site }}
    - image: chambana/userdir:latest
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - volumes:
      - /etc/ssh/auth/{{ site }}.yml:/etc/ssh/auth/{{ site }}.yml:ro
      - /home:/home:ro
    - port_bindings:
      - {{ settings.ssh_port }}:22/tcp
    - environment:
      - JEKYLL_GITHUB_USER: {{ settings.github_user }}
      - JEKYLL_GITHUB_REPO: {{ settings.github_repo }}
      - JEKYLL_GITHUB_BRANCH: {{ settings.github_branch }}
      - JEKYLL_GITHUB_SUBDIR: {{ settings.subdir }}
      - VIRTUAL_HOST: {{ settings.virtual_host }}
      - VIRTUAL_PORT: 4000
      - LETSENCRYPT_HOST: {{ settings.letsencrypt_host }}
      - LETSENCRYPT_EMAIL: {{ settings.letsencrypt_email }}
    - require:
      - service: docker
      - docker_network: local_network
      - file: {{ site }}_users
{% endfor %}
