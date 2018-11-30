# -*- coding: utf-8 -*-
# vim: ft=sls

archaudit_service_systemd:
  file.managed:
    - name: /etc/systemd/system/archaudit.service
    - source: salt://bootstrap/files/archaudit/archaudit.service
    - user: root
    - group: root
    - mode: 644

archaudit_timer_systemd:
  file.managed:
    - name: /etc/systemd/system/archaudit.timer
    - source: salt://bootstrap/files/archaudit/archaudit.timer
    - user: root
    - group: root
    - mode: 644

archaudit_script:
  file.managed:
    - name: /usr/local/sbin/archaudit.sh
    - source: salt://bootstrap/files/archaudit/archaudit.sh
    - user: root
    - group: root
    - mode: 755

archaudit_pkg:
  pkg.installed:
    - pkgs:
      - arch-audit
    - require:
      - file: pacman_conf

archaudit_service:
  service.enabled:
    - name: archaudit
    - require:
      - pkg: archaudit_pkg
      - file: archaudit_service_systemd
      - file: archaudit_script

archaudit_timer:
  service.running:
    - name: archaudit.timer
    - enable: True
    - require:
      - pkg: archaudit_pkg
      - file: archaudit_timer_systemd
      - file: archaudit_script
