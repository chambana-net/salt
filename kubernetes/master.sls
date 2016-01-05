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
    - home: {{ kubernetes.prefix }}
    - require:
      - group: kube_group

kube-apiserver:
  file.managed:
    - name: {{ kubernetes.prefix }}/sbin/kube-apiserver
    - source: salt://kubernetes/vendor/kube-apiserver
    - user: root
    - group: root
    - mode: 0750

kube-apiserver_config:
  file.managed:
    - name: {{ kubernetes.config_dir }}/kube-apiserver.conf
    - source: salt://kubernetes/files/config/kube-apiserver.conf
    - template: kinja
    - user: root
    - group: root
    - mode: 0644
    - defaults:
        insecure-bind-address: {{ settings.get('insecure-bind-address', '0.0.0.0') }}
        insecure-port: {{ settings.get('insecure-port', '8080') }}
        etcd-servers: {{ settings.get('etcd-servers', 'http://127.0.0.1:4001') }}
        server-cluster-ip-range: {{ settings.get('server-cluster-ip-range', '') }}
        admission-control: {{ settings.get('admission-control', '') }}
        service-node-port-range: {{ settings.get('service-node-port-range', '') }}
        advertise-address: {{ settings.get('advertise-address', '' ) }}
        client-ca-file: {{ settings.get('client-ca-file', kubernetes.resource_dir ~ '/ca.crt') }}
        tls-cert-file: {{ settings.get('tls-cert-file', kubernetes.resource_dir ~ '/server.cert') }}
        tls-private-key-file: {{ settings.get('tls-private-key-file', kubernetes.resource_dir ~ '/server.key') }}
        other-opts: {{ settings.get('other-opts', '') }}

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
    - name: {{ kubernetes.prefix }}/sbin/kube-controller-manager
    - source: salt://kubernetes/vendor/kube-controller-manager
    - user: root
    - group: root
    - mode: 0750

kube-controller-manager_config:
  file.managed:
    - name: {{ kubernetes.config_dir }}/kube-controller-manager.conf
    - source: salt://kubernetes/files/config/kube-controller-manager.conf
    - template: kinja
    - user: root
    - group: root
    - mode: 0644
    - defaults:
        master: {{ settings.get('master', '127.0.0.1:8080') }}
        root-ca-file: {{ settings.get('root-ca-file', kubernetes.resource_dir ~ '/ca.crt') }}
        service-account-private-key-file: {{ settings.get('service-account-private-key-file', kubernetes.resource_dir ~ '/server.key') }}
        other-opts: {{ settings.get('other-opts', '') }}

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

kube-scheduler:
  file.managed:
    - name: {{ kubernetes.prefix }}/sbin/kube-scheduler
    - source: salt://kubernetes/vendor/kube-scheduler
    - user: root
    - group: root
    - mode: 0750

kube-scheduler_config:
  file.managed:
    - name: {{ kubernetes.config_dir }}/kube-scheduler.conf
    - source: salt://kubernetes/files/config/kube-scheduler.conf
    - template: kinja
    - user: root
    - group: root
    - mode: 0644
    - defaults:
        master: {{ settings.get('master', '127.0.0.1:8080') }}
        other-opts: {{ settings.get('other-opts', '') }}

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

kubectl:
  file.managed:
    - name: {{ kubernetes.prefix }}/bin/kubectl
    - source: salt://kubernetes/vendor/kubectl
    - user: root
    - group: root
    - mode: 0750

kube_profile:
  file.managed:
    - name: /etc/profile.d/kubectl.sh
    - source: salt://kubernetes/files/kubectl.sh
    - user: root
    - group: root
    - mode: 0644
    - require:
      - file: kubectl
