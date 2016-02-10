{% from "pki/map.jinja" import pki with context %}
{% set settings = salt['pillar.get']('pki:lookup:settings', {}) %}
{% set peers = salt['pillar.get']('cluster:peers', {}) %}

{% set peer_string = [] -%}

{% for host,_ in peers.items() -%}
{% if peer_string.append( host ) -%}
{% endif -%}
{% endfor %}

pki:
  pkg.installed:
    - pkgs:
      - python-m2crypto

pki_ca_minion:
  service.running:
    - name: {{ pki.ca_minion }}
    - enable: True
    - listen:
      - file: {{ pki.ca_signing_policies }}

pki_ca_signing_policies:
  file.managed:
    - name: {{ pki.ca_signing_policies }}
    - source: salt://pki/files/signing_policies.conf
    - template: jinja
    - defaults:
        minions: {{ peer_string|join(',') }}
        ca_key: {{ pki.ca_key }}
        ca_cert: {{ pki.ca_cert }}
        country: {{ settings.get('country', 'US') }}
        state: {{ settings.get('state', 'IL') }}
        locality: {{ settings.get('locality', 'Urbana') }}
        days_valid: 90
        ca_dir_issued_certs: {{ pki.ca_dir_issued_certs }}

pki_ca_dir:
  file.directory: 
    - name: {{ pki.ca_dir }}
    - user: root
    - group: root
    - dir_mode: 0700

pki_ca_dir_issued_certs:
  file.directory:
    - name: {{ pki.ca_dir_issued_certs }}
    - user: root
    - group: root
    - dir_mode: 0700
    - makedirs: True

pki_ca_key:
  x509.private_key_managed:
    - name: {{ pki.ca_key }}
    - bits: 4096
    - backup: True
    - require:
      - pkg: pki
      - file: pki_ca_dir

pki_ca_cert:
  x509.certificate_managed:
    - signing_private_key: {{ pki.ca_key }}
    - CN: {{ settings.get('cn', 'chambana.net') }}
    - C: {{ settings.get('country', 'US') }}
    - ST: {{ settings.get('state', 'IL') }}
    - L: {{ settings.get('locality', 'Urbana') }}
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: {{ settings.get('days_valid', '3650') }}
    - days_remaining: 0
    - backup: True
    - require:
      - pkg: pki
      - x509: pki_ca_key

mine.send:
  module.run:
    - func: x509.get_pem_entries
    - kwargs:
        glob_path: {{ pki.ca_cert }}
    - onchanges:
      - x509: pki_ca_cert
