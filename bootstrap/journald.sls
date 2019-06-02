# -*- coding: utf-8 -*-
# vim: ft=sls

# Temporary fix since remote journal doesn't rotate files on its own

journald_conf:
  file.managed:
    - name: /etc/systemd/journald.conf
    - source: salt://bootstrap/files/journald/journald.conf
    - user: root
    - group: root
    - mode: 644

journald:
  service.running:
    - name: systemd-journald
    - enable: True
    - watch:
      - file: journald_conf


