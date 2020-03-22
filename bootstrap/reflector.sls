# -*- coding: utf-8 -*-
# vim: ft=sls

reflector_service_systemd:
  file.managed:
    - name: /etc/systemd/system/reflector.service
    - source: salt://bootstrap/files/reflector/reflector.service
    - user: root
    - group: root
    - mode: 644

reflector_timer_systemd:
  file.managed:
    - name: /etc/systemd/system/reflector.timer
    - source: salt://bootstrap/files/reflector/reflector.timer
    - user: root
    - group: root
    - mode: 644

reflector_pkg:
  pkg.installed:
    - pkgs:
      - reflector
    - require:
      - file: pacman_conf

reflector_timer:
  service.running:
    - name: reflector.timer
    - enable: True
    - watch:
      - pkg: reflector_pkg
    - require:
      - file: reflector_timer_systemd
