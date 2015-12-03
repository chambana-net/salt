{% from "bootstrap/map.jinja" import bootstrap with context %}
{% set settings = salt['pillar.get']('bootstrap:lookup:settings', {}) %}

{% if grains['os'] == 'Arch'%}
include:
  - bootstrap.arch
{% elif grains['os'] == 'Debian'%}
include:
  - bootstrap.debian
{% elif grains['os'] == 'RedHat'%}
include:
  - bootstrap.fedora
{% endif %}

utilities:
  pkg.installed:
    - pkgs:
      - vim
      - screen
      - less
      - sudo
      - git
      - wget
      - rsync
      - etckeeper

issue:
  file.managed:
    - name: {{ bootstrap.issue }}
    - source: {{ settings.get('issue', 'salt://bootstrap/files/issue') }}
    - user: root
    - group: root
    - mode: 644

issue_net:
  file.managed:
    - name: {{ bootstrap.issue_net }}
    - source: {{ settings.get('issue_net', 'salt://bootstrap/files/issue.net') }}
    - user: root
    - group: root
    - mode: 644

fortunes:
  pkg.installed:
    - pkg:
      - fortune-mod

  file.recurse:
    - name: {{ bootstrap.fortunes }}
    - source: {{ settings.get('fortunes', 'salt://bootstrap/files/fortunes') }}
    - user: root
    - group: root
    - file_mode: 644
    - dir_mode: 755

fortune-motd:
  file.managed:
    - name: /etc/systemd/system/fortune-motd.service
    - source: salt://bootstrap/files/fortune-motd.service
    - user: root
    - group: root
    - mode: 644
    - replace: true

skel:
  file.recurse:
    - name: {{ bootstrap.skel }}
    - source: {{ settings.get('skel', 'salt://bootstrap/files/skel') }}
    - user: root
    - group: root
    - file_mode: 644
    - dir_mode: 755

bash_bashrc:
  file.managed:
    - name: {{ bootstrap.bash_bashrc }}
    - source: {{ settings.get('bash_bashrc', 'salt://bootstrap/files/skel/.bashrc') }}
    - user: root
    - group: root
    - mode: 644
