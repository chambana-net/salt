# -*- coding: utf-8 -*-
# vim: ft=sls

pacserve_pkg:
  pkg.installed:
    - pkgs:
      - pacserve
    - require:
      - file: pacman_conf

pacserve_service:
  service.enabled:
    - name: pacserve
    - require:
      - pkg: pacserve_pkg
      
pacserve_ports:
  service.enabled:
    - name: pacserve-ports
    - require:
      - pkg: pacserve_pkg

pacserve_conf:
  cmd.run:
    - name: pacman.conf-insert_pacserve
    - onchanges:
      - file: pacman_conf

