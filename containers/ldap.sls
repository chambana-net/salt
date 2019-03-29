# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import ldap with context %}
{% from "containers/map.jinja" import phpldapadmin with context %}

ldif_dir:
  file.directory:
    - name: /tmp/ldif
    - makedirs: True
    - user: root
    - group: root
    - mode: 0755

ldif_preseed:
  file.managed:
    - name: /tmp/ldif/users.ldif
    - source: salt://containers/files/users.ldif.tmpl
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - defaults:
        base_dn: {{ ldap.base_dn }}
    - require:
      - file: ldif_dir

ldap_backup_dir:
  file.directory:
    - name: /var/backups/ldap
    - makedirs: True
    - user: root
    - group: root
    - mode: 0750

ldap_backup:
  docker_container.running:
    - name: ldap-backup
    - hostname: ldap-backup
    - image: osixia/openldap-backup:1.2.4
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - /var/backups/ldap:/data/backup:rw
    - environment:
      - LDAP_BACKUP_CONFIG_CRON_EXP: "30 0 * * *"
    - require:
      - file: ldap_backup_dir

ldap:
  docker_container.running:
    - name: ldap
    - hostname: ldap
    - image: osixia/openldap:1.2.4
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - chambana_ldap_config:/etc/ldap/slapd.d:rw
      - chambana_ldap_data:/var/lib/ldap:rw
      - /tmp/ldif:/container/service/slapd/assets/config/bootstrap/ldif/custom:ro
    - environment:
      - LDAP_ORGANISATION: {{ ldap.org }}
      - LDAP_DOMAIN: {{ ldap.domain }}
      - LDAP_BASE_DN: {{ ldap.base_dn }}
      - LDAP_ADMIN_PASSWORD: {{ ldap.password }}
      - LDAP_CONFIG_PASSWORD: {{ ldap.password }}
      - LDAP_READONLY_USER: {{ ldap.readonly_user_enable }}
      - LDAP_READONLY_USER_USERNAME: {{ ldap.readonly_user_username }}
      - LDAP_READONLY_USER_PASSWORD: {{ ldap.readonly_user_password }}
      - LDAP_TLS: false
      - LDAP_RFC2307BIS_SCHEMA: true
    - command: --copy-service
    - require:
      - file: ldif_preseed
      - service: docker
      - docker_network: local_network
      - docker_volume: ldap_config
      - docker_volume: ldap_data

phpldapadmin:
  docker_container.running:
    - name: phpldapadmin
    - hostname: phpldapadmin
    - image: osixia/phpldapadmin:latest
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - environment:
      - PHPLDAPADMIN_LDAP_HOSTS: ldap
      - PHPLDAPADMIN_HTTPS: false
      - PHPLDAPADMIN_TRUST_PROXY_SSL: true
      - PHPLDAPADMIN_SERVER_ADMIN: {{ phpldapadmin.email }}
      - PHPLDAPADMIN_SERVER_PATH: /
      - VIRTUAL_HOST: {{ phpldapadmin.domain }}
      - LETSENCRYPT_HOST: {{ phpldapadmin.domain }}
      - LETSENCRYPT_EMAIL: {{ phpldapadmin.email }}
    - require:
      - file: ldif_preseed
      - service: docker
      - docker_network: local_network

ldap_config:
  docker_volume.present:
    - name: chambana_ldap_config
    - driver: local

ldap_data:
  docker_volume.present:
    - name: chambana_ldap_data
    - driver: local
