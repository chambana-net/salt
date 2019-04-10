# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "containers/map.jinja" import nginx_proxy with context %}

include:
  - containers.local

nginx:
  docker_container.running:
    - name: nginx
    - image: nginx:latest
    - restart_policy: always
    - log_driver: journald
    - networks:
      - local_network
    - port_bindings:
      - 80:80/tcp
      - 443:443/tcp
    - volumes:
      - /etc/nginx/conf.d
      - /etc/nginx/vhost.d
      - /usr/share/nginx/html
    - binds:
      - {{ nginx_proxy.letsencrypt_dir }}:/etc/nginx/certs:ro

docker_gen:
  docker_container.running:
    - name: docker-gen
    - image: jwilder/docker-gen:latest
    - hostname: docker-gen
    - log_driver: journald
    - networks:
      - local_network
    - volumes_from: nginx
    - environment:
      - DEFAULT_HOST: {{ nginx_proxy.default_host }}
    - binds:
      - {{ nginx_proxy.nginx_template }}:/etc/docker-gen/templates/nginx.tmpl:ro
      - {{ nginx_proxy.docker_socket }}:/tmp/docker.sock:ro
    - labels:
      - "com.github.jrcs.letsencrypt_nginx_proxy_companion.docker_gen"
    - command: -notify-sighup nginx -watch /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
    - require:
      - file: docker_gen
    - watch:
      - docker_container: nginx

  file.managed:
    - name: {{ nginx_proxy.nginx_template }}
    - source: salt://containers/files/nginx.tmpl
    - user: root
    - group: root
    - mode: 0644
    - makedirs: True

letsencrypt:
  docker_container.running:
    - name: letsencrypt
    - image: jrcs/letsencrypt-nginx-proxy-companion:latest
    - hostname: letsencrypt
    - log_driver: journald
    - networks:
      - local_network
    - volumes_from: nginx
    - binds:
      - {{ nginx_proxy.letsencrypt_dir }}:/etc/nginx/certs:rw
      - {{ nginx_proxy.docker_socket }}:/var/run/docker.sock:ro
    - environment:
      - NGINX_DOCKER_GEN_CONTAINER=docker-gen
    - require:
      - docker_container: docker_gen
    - watch:
      - docker_container: nginx
