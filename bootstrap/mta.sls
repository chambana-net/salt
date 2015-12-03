{% from "bootstrap/map.jinja" import bootstrap with context %}
{% set settings = salt['pillar.get']('bootstrap:lookup:settings:mta', {}) %}

msmtp:
  pkg.installed:
    - pkgs:
      - msmtp
{% if grains['os'] != 'RedHat' %}
      - msmtp-mta
{% endif %}

  file.managed:
    - name: /etc/msmtprc
    - source: {{ settings.get('msmtp_rc', 'salt://bootstrap/files/msmtprc') }}
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - defaults:
        tls_trust_file: {{ bootstrap.tls_trust_file }}
        user: {{ settings.get('user', '') }}
        password: {{ settings.get('password', '') }}
        host: {{ settings.get('host', '') }}
        port: {{ settings.get('port', '25') }}
        maildomain: {{ settings.get('maildomain', grains['fqdn']) }}

aliases:
  file.managed:
    - name: {{ bootstrap.aliases }}
    - source: {{ settings.get('aliases', 'salt://bootstrap/files/aliases') }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        root_email: {{ settings.get('root_email', 'root@chambana.net') }}
