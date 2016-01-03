{% from "kubernetes/map.jinja" import kubernetes with context %}
{% set settings = salt['pillar.get']('kubernetes:lookup:settings', {}) %}

{% if grains['os'] == 'Arch'%}
include:
  - kubernetes.arch
{% elif grains['os'] == 'Debian'%}
include:
  - kubernetes.debian
{% elif grains['os'] == 'RedHat'%}
include:
  - kubernetes.fedora
{% endif %}

