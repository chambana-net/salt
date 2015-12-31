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
        data_dir: {{ settings.get('data_dir', etcd.data_dir) }}
        wal_dir: {{ settings.get('wal_dir', etcd.wal_dir) }}
        snapshot_count: {{ settings.get('snapshot_count', 10000) }}
        heartbeat_interval: {{ settings.get('heartbeat_interval', 100) }}
        election_timeout: {{ settings.get('election_timeout', 1000) }}
        max_snapshots: {{ settings.get('max_snapshots', 5) }}
        max_wals: {{ settings.get('max_wals', 5) }}
        initial_cluster_state: {{ settings.get('initial_cluster_state', "new") }}
        initial_cluster_token: {{ settings.get('initial_cluster_token', grains['fqdn']) }}

etcd_service:
  service.running:
    - enable: True
    - reload: True
    - require:
      - pkg: etcd
    - watch:
      - file: etcd
