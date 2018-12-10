# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bootstrap/map.jinja" import bootstrap with context %}

salt_pkg:
  pkg.installed:
    - pkgs:
      - {{ bootstrap.salt_pkg }}
    - require:
      - file: pacman_conf

salt_masterless_conf:
  file.managed:
    - name: /etc/salt/minion.d/10-masterless.conf
    - source: salt://bootstrap/files/salt/10-masterless.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: salt_pkg

salt_chambana_conf:
  file.managed:
    - name: /etc/salt/minion.d/20-chambana.conf
    - source: salt://bootstrap/files/salt/20-chambana.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: salt_pkg

{% if bootstrap.auto == True %}
salt_service:
  file.managed:
    - name: /etc/systemd/system/salt.service
    - source: salt://bootstrap/files/salt/salt.service
    - user: root
    - group: root
    - mode: 644

  service.enabled:
    - name: salt.service
    - require:
      - pkg: salt_pkg
      - file: salt_service

salt_timer:
  file.managed:
    - name: /etc/systemd/system/salt.timer
    - source: salt://bootstrap/files/salt/salt.timer
    - user: root
    - group: root
    - mode: 644

  service.running:
    - name: salt.timer
    - enable: True
    - require:
      - pkg: salt_pkg
      - file: salt_timer
      - file: salt_service
{% else %}
salt_service:
  file.absent:
    - name /etc/systemd/system/salt.service
    - require:
      - service: salt_service

  service.disable:
    - name: salt.service

salt_timer:
  file.absent:
    - name /etc/systemd/system/salt.timer
    - require:
      - service: salt_timer

  service.dead:
    - name: salt.timer
    - enable: False
{% endif %}
