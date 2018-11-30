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

sources_list:
  file.absent:
    - name: /etc/apt/sources.list

sources_list_default:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} packages
    - name: deb http://httpredir.debian.org/debian {{ bootstrap.dist }} {{ bootstrap.dist }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - file: sources_list
    - require_in:
      - pkg: apt_packages

sources_list_default_src:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} sources
    - name: deb-src http://httpredir.debian.org/debian {{ bootstrap.dist }} {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/distro.list

sources_list_security:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} security updates
    - name: deb http://security.debian.org/ {{ bootstrap.dist }}/updates {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/distro.list

sources_list_security_src:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} security updates sources
    - name: deb-src http://security.debian.org/ {{ bootstrap.dist }}/updates {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/distro.list

sources_list_updates:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} updates
    - name: deb http://httpredir.debian.org/debian {{ bootstrap.dist }}-updates {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/distro.list

sources_list_updates_src:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} updates sources
    - name: deb-src http://httpredir.debian.org/debian {{ bootstrap.dist }}-updates {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/distro.list

sources_list_testing:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} packages
    - name: deb http://httpredir.debian.org/debian testing {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/testing.list

sources_list_testing_src:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} sources
    - name: deb-src http://httpredir.debian.org/debian testing {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/testing.list

sources_list_testing_security:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} security updates
    - name: deb http://security.debian.org/ testing/updates {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/testing.list

sources_list_testing_security_src:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} security updates sources
    - name: deb-src http://security.debian.org/ testing/updates {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/testing.list

sources_list_experimental:
  pkgrepo.managed:
    - humanname: {{ bootstrap.dist }} updates
    - name: deb http://httpredir.debian.org/debian experimental {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/experimental.list

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

apt_preferences_pinning:
  file.managed:
    - name: /etc/apt/preferences.d/distro
    - source: salt://bootstrap/files/apt/preferences.d/distro
    - template: jinja
    - defaults:
        dist: {{ bootstrap.dist }}
    - user: root
    - group: root
    - mode: 644
