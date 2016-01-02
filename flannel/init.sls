flannel_packages:
  pkg.latest:
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

flannel_config:
  etcd.set:
    - name: /coreos.com/network/config
    - value: '{ "Network": "172.16.0.0/12", "Backend": { "Type": "vxlan", "VNI": 1 } }'
    - profile: etcd_local
    - require:
      - sls: etcd

flannel_run:
  cmd.run:
    - name: /usr/local/bin/flanneld

