# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bootstrap/map.jinja" import bootstrap with context %}

netdata_conf:
  file.managed:
    - name: {{ bootstrap.netdata_conf_dir }}/netdata.conf
    - source: salt://bootstrap/files/netdata/netdata.conf
    - user: {{ bootstrap.netdata_user }}
    - group: {{ bootstrap.netdata_group }}
    - mode: 644
    - require:
      - pkg: netdata

stream_conf:
  file.managed:
    - name: {{ bootstrap.netdata_conf_dir }}/stream.conf
    - source: salt://bootstrap/files/netdata/stream.conf.tmpl
    - user: {{ bootstrap.netdata_user }}
    - group: {{ bootstrap.netdata_group }}
    - mode: 644
    - template: jinja
    - defaults:
        host: {{ bootstrap.netdata_host }}
        port: {{ bootstrap.netdata_port }}
        uuid: {{ grains['uuid'] }}
    - require:
      - pkg: netdata

netdata:
  pkg.installed:
    - pkgs:
      - {{ bootstrap.netdata_pkg }}

  service.running:
    - name: netdata
    - enable: True
    - watch:
      - pkg: netdata
      - file: netdata_conf
      - file: stream_conf


