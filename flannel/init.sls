include:
  - etcd

flannel_packages:
  pkg.installed:
    - pkgs: 
      - linux-libc-dev
      - golang
      - gcc

flannel_install:
  git.latest:
    - name: https://github.com/coreos/flannel
    - rev: v0.5.5
    - target: /usr/local/src/flannel
    - require:
      - pkg: flannel_packages

  cmd.run:
    - cwd: /usr/local/src/flannel
    - name: ./build
    - require:
      - pkg: flannel_packages

  file.copy:
    - name: /usr/local/bin/flanneld
    - source: /usr/local/src/flannel/bin/flanneld
    - user: root
    - group: root
    - mode: 0775

flannel_config:
  etcd.set:
    - name: /coreos.com/network/config
    - value: '{ "Network": "172.16.0.0/12", "Backend": { "Type": "vxlan", "VNI": 1 } }'
    - profile: etcd_local
    - require:
      - sls: etcd

flannel_service:
  file.managed:
    - name: /etc/systemd/system/flannel.service
    - source: salt://flannel/files/flannel.service
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: flannel
    - enable: True
    - require:
      - file: flannel_service
      - etcd: flannel_config
