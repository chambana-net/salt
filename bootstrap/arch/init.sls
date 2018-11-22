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

arch_packages:
  pkg.installed:
    - pkgs:
      - pacserve
      - reflector
      - arch-audit
      - git
      - wget
      - rsync
      - neovim

pacserve_service:
  service.running:
    - name: pacserve
    - enable: True
    - watch:
      - pkg: pacserve
    - require:
      - pkg: arch_packages
      
pacserve_ports:
  service.running:
    - name: pacserve-ports
    - enable: True
    - watch:
      - pkg: pacserve
    - require:
      - pkg: arch_packages

pacserve_conf:
  cmd:
    - name: pacman.conf-insert_pacserve
    - watch:
      - file: pacserve
    - require:
      - pkg: arch_packages

reflector_service:
  service.running:
    - name: reflector
    - enable: True
    - watch:
      - pkg: reflector
    - require:
      - pkg: arch_packages
      - file: reflector_service_systemd

reflector_timer:
  service.running:
    - name: reflector.timer
    - enable: True
    - watch:
      - pkg: reflector
    - require:
      - pkg: arch_packages
      - file: reflector_timer_systemd

archaudit_service:
  service.running:
    - name: archaudit
    - enable: True
    - require:
      - pkg: arch_packages
      - file: archaudit_service_systemd
      - file: archaudit_script

archaudit_timer:
  service.running:
    - name: archaudit.timer
    - enable: True
    - require:
      - pkg: arch_packages
      - file: archaudit_timer_systemd
      - file: archaudit_script
