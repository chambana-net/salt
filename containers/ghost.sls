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
      - {{ site }}_network
    - binds:
      - chambana_{{ site }}:/var/lib/ghost/content:rw
    - environment:
      - VIRTUAL_HOST: {{ settings.virtual_host }}
      - VIRTUAL_PORT: 2368
      - LETSENCRYPT_HOST: {{ settings.letsencrypt_host }}
      - LETSENCRYPT_EMAIL: {{ settings.letsencrypt_email }}
      - url: {{ settings.url }}
      - database__client: "mysql"
      - database__connection__host: "{{ site }}-db"
      - database__connection__user: "root"
      - database__connection__password: {{ settings.mariadb_password }}
      - database__connection__database: "ghost"
      - mail__transport: "SMTP"
      - mail__options__port: 587
      - mail__options__host: {{ settings.mail_host }}
      - mail__options__secureConnection: 'true'
      - mail__options__auth__user: {{ settings.mail_user }}
      - mail__options__auth__pass: {{ settings.mail_password }}

    - require:
      - service: docker
      - docker_network: local_network
      - docker_volume: {{ site }}_ghost

{{ site }}-db:
  docker_container.running:
    - name: {{ site }}-db
    - image: mariadb:10.4
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - chambana_{{ site }}_db_data:/var/lib/mysql:rw
    - environment:
      - MYSQL_ROOT_PASSWORD: {{ settings.mariadb_password }}
    - require:
      - service: docker
      - docker_volume: limesurvey_db_data
      - docker_network: local_network

{{ site }}_ghost:
  docker_volume.present:
    - name: chambana_{{ site }}
    - driver: local

{{ site }}_db_data:
  docker_volume.present:
    - name: chambana_{{ site }}_db_data
    - driver: local

{{ site }}_network:
  docker_network.present:
    - name: {{ site }}_network
    - driver: bridge
    - internal: True

{% endfor %}

