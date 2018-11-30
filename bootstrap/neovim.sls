# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bootstrap/map.jinja" import bootstrap with context %}

neovim_pkg:
  pkg.installed:
    - pkgs:
      - neovim

neovim_scripts:
  file.recurse:
    - name: /usr/bin
    - source: salt://bootstrap/files/neovim
    - user: root
    - group: root
    - file_mode: 755

{% for alias in ["edit", "vedit", "vi", "vim"] %}
neovim_ln_{{ alias }}:
  file.symlink:
    - name: /usr/bin/{{ alias }}
    - target: /usr/bin/nvim
    - force: true
{% endfor %}

{% for man in ["vi", "vim", "vimdiff"] %}
neovim_man_{{ man }}:
  file.symlink:
    - name: /usr/share/man/man1/{{ man }}.1.gz
    - target: /usr/share/man/man1/nvim.1.gz
    - force: true
{% endfor %}
