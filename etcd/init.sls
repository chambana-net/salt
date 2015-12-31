{% from "etcd/map.jinja" import etcd with context %}
{% set peers = salt['pillar.get']('cluster:peers', {}) %}
{% set settings = salt['pillar.get']('etcd:lookup:settings', {}) %}

etcd:
  pkg.installed:
    -name: etcd

  file.managed:
    - name: {{ etcd.configfile }}
    - source: salt://etcd/files/config
    - user: root
    - group: root
    - mode: 0644
    - replace: true
    - defaults:
        node_ip: {{ grains['fqdn_ip4'][0] }}
        peer_port: {{ settings.get('peer_port', 7001) }}
        client_port: {{ settings.get('client_port', 4001) }}
        name: {{ settings.get('name', grains['host']) }}
        data-dir: {{ settings.get('data-dir', etcd.data-dir) }}
        wal-dir: {{ settings.get('wal-dir', etcd.wal-dir) }}
        snapshot-count: {{ settings.get('snapshot-count', 10000) }}
        heartbeat-interval: {{ settings.get('heartbeat-interval', 100) }}
        election-timeout: {{ settings.get('election-timeout', 1000) }}
        max-snapshots: {{ settings.get('max-snapshots', 5) }}
        max-wals: {{ settings.get('max-wals', 5) }}
        initial-cluster-state: {{ settings.get('initial-cluster-state', "new") }}
        initial-cluster-token: {{ settings.get('initial-cluster-token', grains['fqdn']) }}

etcd_service:
  service.running:
    - enable: True
    - reload: True
    - require:
      - pkg: etcd
    - watch:
      - file: etcd
