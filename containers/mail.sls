# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import mail with context %}

include:
  - containers.local

postfix:
  docker_container.running:
    - name: postfix
    - image: chambana/postfix:latest
    - hostname: smtp.chambana.net
    - log_driver: journald
    - networks:
      - local_network
    - port_bindings:
      - 25:25/tcp
      - 587:587/tcp
    - binds:
      - {{ mail.postfix_certs_dir }}:/etc/letsencrypt:ro
      - {{ mail.postfix_virtual_aliases }}:/etc/postfix/virtual-alias.cf:ro
      - {{ mail.postfix_virtual_senders }}:/etc/postfix/virtual-sender.cf:ro
      - chambana_lists:/var/lib/mailman:rw
      - {{ mail.opendkim_keydir }}:/etc/postfix/dkim:ro
    - environment:
      - VIRTUAL_HOST: {{ mail.postfix_virtual_hosts }}
      - LETSENCRYPT_HOST: {{ mail.postfix_letsencrypt_host }}
      - LETSENCRYPT_EMAIL: {{ mail.postfix_letsencrypt_email }}
      - POSTFIX_MAILNAME: {{ mail.postfix_mailname }}
      - POSTFIX_MYHOSTNAME: {{ mail.postfix_myhostname }}
      - POSTFIX_PROXY_INTERFACES: {{ mail.postfix_proxy_interfaces }}
      - POSTFIX_MYDESTINATION: {{ mail.postfix_mydestination }}
      - POSTFIX_MYNETWORKS: {{ mail.postfix_mynetworks }}
      - POSTFIX_VIRTUAL_ALIAS_DOMAINS: {{ mail.postfix_virtual_alias_domains }}
      - POSTFIX_VIRTUAL_MAILBOX_DOMAINS: {{ mail.postfix_virtual_mailbox_domains }}
      - POSTFIX_RELAY_DOMAINS: {{ mail.postfix_relay_domain }}
      - POSTFIX_RELAYHOST: {{ mail.postfix_relayhost }}
      - POSTFIX_LDAP_SERVER_HOST: {{ mail.postfix_ldap_server_host }}
      - POSTFIX_LDAP_SEARCH_BASE: {{ mail.postfix_ldap_search_base }}
      - POSTFIX_LDAP_START_TLS: '{{ mail.postfix_ldap_start_tls }}'
      - POSTFIX_LDAP_BIND_DN: {{ mail.postfix_ldap_bind_dn }}
      - POSTFIX_LDAP_BIND_PW: {{ mail.postfix_ldap_bind_pw }}
      - POSTFIX_SPAM_HOST: amavis
      - MAILMAN_ENABLE: '{{ mail.mailman_enable }}'
      - MAILMAN_DOMAIN: {{ mail.mailman_domain }}
      - MAILMAN_LISTMASTER: {{ mail.mailman_sitepass }}
      - OPENDKIM_ENABLE: '{{ mail.opendkim_enable }}'
    - require:
      - service: docker
      - docker_container: docker_gen
      - docker_container: letsencrypt
      - docker_network: local_network
      - docker_volume: lists

dovecot:
  docker_container.running:
    - name: dovecot
    - image: chambana/dovecot:latest
    - hostname: imap.chambana.net
    - log_driver: journald
    - networks:
      - local_network
    - port_bindings:
      - 143:143/tcp
      - 993:993/tcp
    - binds:
      - {{ mail.dovecot_certs_dir }}:/etc/letsencrypt:ro
      - spam_bayes:/var/lib/amavis/.spamassassin:rw
      - mailboxes:/var/mail:rw
    - environment:
      - VIRTUAL_HOST: {{ mail.dovecot_virtual_host }}
      - LETSENCRYPT_HOST: {{ mail.dovecot_letsencrypt_host }}
      - LETSENCRYPT_EMAIL: {{ mail.dovecot_letsencrypt_email }}
      - DOVECOT_LDAP_URIS: {{ mail.dovecot_ldap_uris }}
      - DOVECOT_LDAP_BASE: {{ mail.dovecot_ldap_base }}
      - DOVECOT_LDAP_AUTH_BIND_USERDN: {{ mail.dovecot_ldap_auth_bind_userdn }}
    - require:
      - service: docker
      - docker_container: docker_gen
      - docker_container: letsencrypt
      - docker_network: local_network
      - docker_volume: mailboxes

amavis:
  docker_container.running:
    - name: amavis
    - image: chambana/amavis:latest
    - hostname: spam.chambana.net
    - log_driver: journald
    - networks:
      - local_network
    - binds:
      - spam_bayes:/var/lib/amavis/.spamassassin:rw
    - environment:
      - AMAVIS_MAILNAME: {{ mail.amavis_mailname }}

mailboxes:
  docker_volume.present:
    - name: chambana_mailboxes
    - driver: local

lists:
  docker_volume.present:
    - name: chambana_lists
    - driver: local

spam_bayes:
  docker_volume.present:
    - name: chambana_spam_bayes
    - driver: local
