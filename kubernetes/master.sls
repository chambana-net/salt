{% from "kubernetes/map.jinja" import kubernetes with context %}
{% set settings = salt['pillar.get']('kubernetes:lookup:settings', {}) %}

kube_group:
  group.present:
    - name: kube
    - system: True

kube_user:
  user.present:
    - name: kube
    - full_name: Kubernetes User
    - system: True
    - gid_from_name: True
    - home: /opt/kubernetes
    - require:
      - group: kube_group

kube-apiserver:
  file.managed:
    - name: /opt/kubernetes/sbin/kube-apiserver
    - source: salt://kubernetes/vendor/kube-apiserver
    - user: root
    - group: root
    - mode: 0750

kube-apiserver_config:
  file.managed:
    - name: /etc/kubernetes/kube-apiserver.conf
    - source: salt://kubernetes/files/config/kube-apiserver.conf
    - template: kinja
    - user: root
    - group: root
    - mode: 0644

kube-apiserver_service:
  file.managed:
    - name: /etc/systemd/system/kube-apiserver.service
    - source: salt://kubernetes/files/systemd/kube-apiserver.service
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: kube-apiserver
    - enable: True
    - require:
      - file: kube-apiserver_service
      - file: kube-apiserver_config
      - file: kube-apiserver
      - user: kube_user
      - group: kube_group

kube-controller-manager:
  file.managed:
    - name: /opt/kubernetes/sbin/kube-controller-manager
    - source: salt://kubernetes/vendor/kube-controller-manager
    - user: root
    - group: root
    - mode: 0750

kube-controller-manager_config:
  file.managed:
    - name: /etc/kubernetes/kube-controller-manager.conf
    - source: salt://kubernetes/files/config/kube-controller-manager.conf
    - template: kinja
    - user: root
    - group: root
    - mode: 0644

kube-controller-manager_service:
  file.managed:
    - name: /etc/systemd/system/kube-controller-manager.service
    - source: salt://kubernetes/files/systemd/kube-controller-manager.service
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: kube-controller-manager
    - enable: True
    - require:
      - file: kube-controller-manager_service
      - file: kube-controller-manager_config
      - file: kube-controller-manager
      - user: kube_user
      - group: kube_group

kubectl:
  file.managed:
    - name: /opt/kubernetes/bin/kubectl
    - source: salt://kubernetes/vendor/kubectl
    - user: root
    - group: root
    - mode: 0750

kubectl_config:
  file.managed:
    - name: /etc/kubernetes/kubectl.conf
    - source: salt://kubernetes/files/config/kubectl.conf
    - template: kinja
    - user: root
    - group: root
    - mode: 0644

kube-scheduler:
  file.managed:
    - name: /opt/kubernetes/sbin/kube-scheduler
    - source: salt://kubernetes/vendor/kube-scheduler
    - user: root
    - group: root
    - mode: 0750

kube-scheduler_config:
  file.managed:
    - name: /etc/kubernetes/kube-scheduler.conf
    - source: salt://kubernetes/files/config/kube-scheduler.conf
    - template: kinja
    - user: root
    - group: root
    - mode: 0644

kube-scheduler_service:
  file.managed:
    - name: /etc/systemd/system/kube-scheduler.service
    - source: salt://kubernetes/files/systemd/kube-scheduler.service
    - user: root
    - group: root
    - mode: 0644

  service.running:
    - name: kube-scheduler
    - enable: True
    - require:
      - file: kube-scheduler_service
      - file: kube-scheduler_config
      - file: kube-scheduler
      - user: kube_user
      - group: kube_group
