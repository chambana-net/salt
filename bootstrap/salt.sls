# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bootstrap/map.jinja" import bootstrap with context %}

{% if grains['os_family'] == 'Debian'%}
salt_repo:
  pkgrepo.managed:
    - humanname: Saltstack repo
    - name: deb http://repo.saltstack.com/apt/debian/{{ grains['osmajorrelease'] }}/amd64/2019.2 {{ bootstrap.dist }} {{ bootstrap.components }}
    - file: /etc/apt/sources.list.d/salt.list
    - gpgcheck: 1
    - key_url: https://repo.saltstack.com/apt/debian/{{ grains['osmajorrelease'] }}/amd64/2019.2/SALTSTACK-GPG-KEY.pub
    - require:
      - pkg: apt_packages
    - require_in:
      - pkg: salt_pkg
{% endif %}

salt_pkg:
  pkg.latest:
    - pkgs:
      - {{ bootstrap.salt_pkg }}

salt_git_pkg:
  pkg.installed:
    - pkgs:
      - {{ bootstrap.pygit_pkg }}
      - git

{% if grains['os_family'] == 'Debian' %}
pip_pkg:
  pkg.installed:
    - pkgs:
      - python-pip

dockerpy_pkg:
  pip.installed:
    - name: docker
    - require:
      - pkg: pip_pkg
{% endif %}

salt_masterless_conf:
  file.managed:
    - name: /etc/salt/minion.d/10-masterless.conf
    - source: salt://bootstrap/files/salt/10-masterless.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - require:
      - pkg: salt_pkg
      - pkg: salt_git_pkg

  service.dead:
    - name: salt-minion
    - enable: False

salt_chambana_conf:
  file.managed:
    - name: /etc/salt/minion.d/20-chambana.conf
    - source: salt://bootstrap/files/salt/20-chambana.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - require:
      - pkg: salt_pkg
      - pkg: salt_git_pkg

{% if bootstrap.auto == True %}
salt_service:
  file.managed:
    - name: /etc/systemd/system/salt.service
    - source: salt://bootstrap/files/salt/salt.service
    - user: root
    - group: root
    - mode: 644

  service.enabled:
    - name: salt.service
    - require:
      - pkg: salt_pkg
      - pkg: salt_git_pkg
      - file: salt_service

salt_timer:
  file.managed:
    - name: /etc/systemd/system/salt.timer
    - source: salt://bootstrap/files/salt/salt.timer
    - user: root
    - group: root
    - mode: 644

  service.running:
    - name: salt.timer
    - enable: True
    - require:
      - pkg: salt_pkg
      - pkg: salt_git_pkg
      - file: salt_timer
      - file: salt_service
{% else %}
salt_service:
  file.absent:
    - name /etc/systemd/system/salt.service
    - require:
      - service: salt_service

  service.disable:
    - name: salt.service

salt_timer:
  file.absent:
    - name /etc/systemd/system/salt.timer
    - require:
      - service: salt_timer

  service.dead:
    - name: salt.timer
    - enable: False
{% endif %}

