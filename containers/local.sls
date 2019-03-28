# -*- coding: utf-8 -*-
# vim: ft=sls

local_network:
  docker_network.present:
    - name: local_network
    - driver: bridge
