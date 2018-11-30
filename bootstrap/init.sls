# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bootstrap/map.jinja" import bootstrap with context %}

{% if grains['os'] == 'Arch'%}
include:
  - bootstrap.pacman
  - bootstrap.reflector
  - bootstrap.pacserve
  - bootstrap.archaudit
  - bootstrap.fortune
  - bootstrap.neovim
{% elif grains['os'] == 'Debian'%}
include:
  - bootstrap.apt
  - bootstrap.fortune
  - bootstrap.neovim
{% endif %}

utilities:
  pkg.installed:
    - pkgs:
      - screen
      - less
      - sudo
      - git
      - wget
      - rsync
      - etckeeper
      - curl
issue:
  file.managed:
    - name: {{ bootstrap.issue }}
    - source: salt://bootstrap/files/issue
    - user: root
    - group: root
    - mode: 644

issue_net:
  file.managed:
    - name: {{ bootstrap.issue_net }}
    - source: salt://bootstrap/files/issue.net
    - user: root
    - group: root
    - mode: 644

skel:
  file.recurse:
    - name: {{ bootstrap.skel }}
    - source: salt://dotfiles/files
    - user: root
    - group: root
    - file_mode: 644
    - dir_mode: 755

bash_bashrc:
  file.managed:
    - name: {{ bootstrap.bash_bashrc }}
    - source: salt://dotfiles/files/.bashrc
    - user: root
    - group: root
    - mode: 644
