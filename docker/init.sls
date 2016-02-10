include:
  - etcd

docker:
  pkg.installed:
    - pkgs: 
      - docker.io
      - python-docker

  file.managed:
    - name: /etc/systemd/system/docker.d/mod.conf
    - source: salt://docker/files/mod.conf
    - user: root
    - group: root
    - mode: 0644
    - replace: True
    - makedirs: True
    - require:
      - sls: etcd

docker_service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker
    - watch:
      - pkg: docker
      - file: docker
