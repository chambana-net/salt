# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bootstrap/map.jinja" import bootstrap with context %}

fortune_pkg:
  pkg.installed:
    - pkgs:
      - fortune-mod

fortunes:
  file.recurse:
    - name: {{ bootstrap.fortunes }}
    - source: salt://bootstrap/files/fortune/fortunes
    - user: root
    - group: root
    - file_mode: 644
    - dir_mode: 755

fortune_service_systemd:
  file.managed:
    - name: /etc/systemd/system/fortune-motd.service
    - source: salt://bootstrap/files/fortune/fortune-motd.service
    - user: root
    - group: root
    - mode: 644
    - replace: true
    - template: jinja
    - defaults:
        fortune_bin: {{ bootstrap.fortune_bin }}

fortune_timer_systemd:
  file.managed:
    - name: /etc/systemd/system/fortune-motd.timer
    - source: salt://bootstrap/files/fortune/fortune-motd.timer
    - user: root
    - group: root
    - mode: 644

fortune_service:
  service.enabled:
    - name: fortune-motd
    - require:
      - pkg: fortune_pkg
      - file: fortune_service_systemd

fortune_timer:
  service.running:
    - name: fortune-motd.timer
    - enable: True
    - require:
      - pkg: fortune_pkg
      - file: fortune_timer_systemd
