{% set code_name = salt['grains.get']('oscodename', 'jessie') %}

kismatic_pkgs:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates

kismatic_repo:
  pkgrepo.managed:
    - humanname: kismatic packages
    - name: deb [arch=amd64] https://repos.kismatic.com/debian {{ code_name }} main
    - file: /etc/apt/sources.list.d/kismatic.list
    - keyserver: hkp://keyserver.ubuntu.com:80
    - keyid: 834BE34E616EE0EE20A5003A5C919141D83BE32B
    - require:
      - pkg: kismatic_pkgs
