{% set settings = salt['pillar.get']('bootstrap:lookup:settings:arch', {}) %}

pacman_conf:
  file.managed:
    - name: /etc/pacman.conf
    - source: salt://bootstrap/arch/files/pacman/pacman.conf
    - user: root
    - group: root
    - mode: 644
    - require_in:
      - pkg: arch_packages

makepkg_conf:
  file.managed:
    - name: /etc/makepkg.conf
    - source: salt://bootstrap/arch/files/pacman/makepkg.conf
    - user: root
    - group: root
    - mode: 644

arch_packages:
  pkg.installed:
    - pkgs:
      - git
      - wget
      - rsync
      - neovim

pacserve_pkg:
  pkg.installed:
    - pkgs:
      - pacserve

pacserve_service:
  service.enabled:
    - name: pacserve
    - require:
      - pkg: pacserve_pkg
      
pacserve_ports:
  service.enabled:
    - name: pacserve-ports
    - require:
      - pkg: pacserve_pkg

pacserve_conf:
  cmd.run:
    - name: pacman.conf-insert_pacserve
    - onchanges:
      - file: pacman_conf

reflector_service_systemd:
  file.managed:
    - name: /etc/systemd/system/reflector.service
    - source: salt://bootstrap/arch/files/reflector/reflector.service
    - user: root
    - group: root
    - mode: 644

reflector_timer_systemd:
  file.managed:
    - name: /etc/systemd/system/reflector.timer
    - source: salt://bootstrap/arch/files/reflector/reflector.timer
    - user: root
    - group: root
    - mode: 644

reflector_pkg:
  pkg.installed:
    - pkgs:
      - reflector

reflector_service:
  service.enabled:
    - name: reflector
    - require:
      - pkg: reflector_pkg
      - file: reflector_service_systemd

reflector_timer:
  service.running:
    - name: reflector.timer
    - enable: True
    - watch:
      - pkg: reflector_pkg
    - require:
      - file: reflector_timer_systemd

archaudit_service_systemd:
  file.managed:
    - name: /etc/systemd/system/archaudit.service
    - source: salt://bootstrap/arch/files/archaudit/archaudit.service
    - user: root
    - group: root
    - mode: 644

archaudit_timer_systemd:
  file.managed:
    - name: /etc/systemd/system/archaudit.timer
    - source: salt://bootstrap/arch/files/archaudit/archaudit.timer
    - user: root
    - group: root
    - mode: 644

archaudit_script:
  file.managed:
    - name: /usr/local/sbin/archaudit.sh
    - source: salt://bootstrap/arch/files/archaudit/archaudit.sh
    - user: root
    - group: root
    - mode: 755

archaudit_pkg:
  pkg.installed:
    - pkgs:
      - arch-audit

archaudit_service:
  service.enabled:
    - name: archaudit
    - require:
      - pkg: archaudit_pkg
      - file: archaudit_service_systemd
      - file: archaudit_script

archaudit_timer:
  service.running:
    - name: archaudit.timer
    - enable: True
    - require:
      - pkg: archaudit_pkg
      - file: archaudit_timer_systemd
      - file: archaudit_script
