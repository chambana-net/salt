# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bootstrap/map.jinja" import bootstrap with context %}

apt_packages:
  pkg.installed:
    - pkgs:
      - python-apt
      - aptitude
      - debconf-utils
      - apt-utils
      - apt-transport-https

sources_list_d:
  file.directory:
    - name: /etc/apt/sources.list.d
    - clean: True

sources_list_default:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} packages
    - name: deb http://deb.debian.org/debian {{ bootstrap.dist }} {{ bootstrap.components }}
    - file: /etc/apt/sources.list
    - clean_file: True
    - require:
      - pkg: apt_packages

sources_list_default_src:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} sources
    - name: deb-src http://deb.debian.org/debian {{ bootstrap.dist }} {{ bootstrap.components }}
    - file: /etc/apt/sources.list
    - require:
      - pkgrepo: sources_list_default

sources_list_security:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} security updates
    - name: deb http://deb.debian.org/debian-security {{ bootstrap.dist }}/updates {{ bootstrap.components }}
    - file: /etc/apt/sources.list
    - require:
      - pkgrepo: sources_list_default

sources_list_security_src:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} security updates sources
    - name: deb-src http://deb.debian.org/debian-security {{ bootstrap.dist }}/updates {{ bootstrap.components }}
    - file: /etc/apt/sources.list
    - require:
      - pkgrepo: sources_list_default

sources_list_updates:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} updates
    - name: deb http://deb.debian.org/debian {{ bootstrap.dist }}-updates {{ bootstrap.components }}
    - file: /etc/apt/sources.list
    - require:
      - pkgrepo: sources_list_default

sources_list_updates_src:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} updates sources
    - name: deb-src http://deb.debian.org/debian {{ bootstrap.dist }}-updates {{ bootstrap.components }}
    - file: /etc/apt/sources.list
    - require:
      - pkgrepo: sources_list_default

apt_conf_defaultrelease:
  file.managed:
    - name: /etc/apt/apt.conf.d/99default-release
    - source: salt://bootstrap/files/apt/apt.conf.d/99default-release
    - template: jinja
    - defaults:
        dist: {{ bootstrap.dist }}
    - user: root
    - group: root
    - mode: 644
