# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bootstrap/map.jinja" import bootstrap with context %}

{% if grains['osarch'] == 'armv7l' %}
pacman_conf:
  file.managed:
    - name: /etc/pacman.conf
    - source: salt://bootstrap/files/pacman/pacman.conf.armv7l
    - user: root
    - group: root
    - mode: 644
{% else %}
include:
  - .reflector

pacman_conf:
  file.managed:
    - name: /etc/pacman.conf
    - source: salt://bootstrap/files/pacman/pacman.conf
    - user: root
    - group: root
    - mode: 644
{% endif %}

makepkg_conf:
  file.managed:
    - name: /etc/makepkg.conf
    - source: salt://bootstrap/files/pacman/makepkg.conf
    - user: root
    - group: root
    - mode: 644

pacman_contrib:
  pkg.installed:
    - pkgs:
      - pacman-contrib

paccache:
  service.running:
    - name: paccache.timer
    - enable: True
    - require:
      - pkg: pacman_contrib
