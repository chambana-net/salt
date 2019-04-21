# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bootstrap/map.jinja" import bootstrap with context %}

{% if grains['osarch'] == 'armv71' %}
pacman_conf:
  file.managed:
    - name: /etc/pacman.conf
    - source: salt://bootstrap/files/pacman/pacman.conf.armv71
    - user: root
    - group: root
    - mode: 644
{% else %}
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
