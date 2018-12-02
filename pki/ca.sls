# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "pki/map.jinja" import pki with context %}

minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - listen:
      - file: /etc/salt/minion.d/signing_policies.conf

signing_policy:
  file.managed:
    - name: /etc/salt/minion.d/signing_policies.conf
    - source: salt://pki/files/signing_policies.conf.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
        - pki_name: {{ pki.name }}
        - pki_dir: {{ pki.dir }}
        - C: {{ pki.C }}
        - ST: {{ pki.ST }}
        - L: {{ pki.L }}

certs_dir:
  file.directory
    - name: {{ pki.dir }}

issued_certs_dir:
  file.directory
    - name: {{ pki.dir }}/issued_certs

generate_ca:
  x509.certificate_managed:
    - name: {{ pki_dir }}/{{ pki_name }}-ca.pem
    - signing_private_key: {{ pki_dir }}/{{ pki_name }}-ca-key.pem
    - CN: {{ pki.CN }}
    - C: {{ pki.C }}
    - ST: {{ pki.ST }}
    - L: {{ pki.L }}
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 0
    - backup: True
    - managed_private_key:
        name: {{ pki_dir }}/{{ pki_name }}-ca-key.pem
        bits: 4096
        backup: True
    - require:
      - file: certs_dir

issue_ca_cert:
  module.run:
    - name: mine.send
    - func: x509.get_pem_entries
    - kwargs:
        glob_path: {{ pki.dir }}/{{ name }}-ca.pem
    - onchanges:
      - x509: generate_ca
