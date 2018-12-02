# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "pki/map.jinja" import pki with context %}

certs_dir:
  file.directory:
    - name: {{ pki.ca_install_path }}
    - user: root
    - group: root
    - mode: 644

ca_cert:
  x509.pem_managed:
    - name: {{ pki.ca_install_path }}
    - text: {{ salt['mine.get']('ca', 'x509.get_pem_entries')['ca']['{{ pki.dir }}/{{ pki.name }}-ca.pem']|replace('\n', '') }}
    - kwargs:
      - user: root
      - group: root
      - mode: 644
    - require:
      - file: certs_dir

{% if grains['os'] == 'Arch' %}
  cmd.run:
    - name: /usr/bin/trust {{ pki.ca_install_path }}
    - runas: root
    - onchanges:
      - x509: ca_cert
{% elif grains['os'] == 'Debian'%}
  cmd.run:
    - name: /usr/sbin/update-ca-certificates
    - runas: root
    - onchanges:
      - x509: ca_cert
{% endif %}

cert:
  x509.certificate_managed:
    - name: {{ pki.dir }}/{{ pki.name }}.pem
    - ca_server: {{ pki.ca_server }}
    - signing_policy: {{ pki.name }}
    - public_key: {{ pki.dir }}/{{ pki.name }}-key.pem
    - CN: {{ grains['hostname'] }}
    - days_remaining: 30
    - backup: True
    - managed_private_key:
        name: {{ pki.dir }}/{{ pki.name }}-key.pem
        bits: 4096
        backup: True

