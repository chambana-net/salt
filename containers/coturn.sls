# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import coturn with context %}

coturn:
  docker_container.running:
    - name: coturn
    - image: instrumentisto/coturn:latest
    - restart_policy: always
    - log_driver: journald
    - networks:
      - coturn_network
    - tmpfs:
      - /var/lib/coturn: rw,noexec,nosuid,size=65536k
    - command: -n --log-file=stdout --external-ip='$(detect-external-ip)' --relay-ip='$(detect-external-ip)' --use-auth-secret --static-auth-secret={{ coturn.secret }} --no-tcp-relay --realm=turn.chambana.net --denied-peer-ip=10.0.0.0-10.255.255.255 --denied-peer-ip=172.16.0.0-172.31.255.255 --denied-peer-ip=192.168.0.0-192.168.255.255 --user-quota=12 --total-quota=1200
    - require:
      - service: docker
      - docker_network: coturn_network

coturn_network:
  docker_network.present:
    - name: coturn_network
    - driver: host
