{% set settings = salt['pillar.get']('bootstrap:lookup:settings:debian', {}) %}

packages:
  pkg.installed:
    - python-apt
    - aptitude
    - debconf-utils
    - apt-utils

sources_list_default:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} packages
    - name: deb http://httpredir.debian.org/debian {{ settings.get('dist', 'jessie') }} {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

sources_list_default_src:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} sources
    - name: deb-src http://httpredir.debian.org/debian {{ settings.get('dist', 'jessie') }} {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

sources_list_security:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} security updates
    - name: deb http://security.debian.org/debian {{ settings.get('dist', 'jessie') }}/updates {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

sources_list_security_src:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} security updates sources
    - name: deb-src http://security.debian.org/debian {{ settings.get('dist', 'jessie') }}/updates {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

sources_list_updates:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} updates
    - name: deb http://httpredir.debian.org/debian {{ settings.get('dist', 'jessie') }}-updates {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

  file.managed:
    - name: /etc/apt/preferences.d/updates
    - source: salt://bootstrap/debian/files/apt/preferences.d/updates
    - template: jinja
    - defaults:
        dist: {{ settings.get('dist', 'jessie') }}
    - user: root
    - group: root
    - mode: 644

  file.managed:
    - name: /etc/apt/preferences.d/updates
    - source: salt://bootstrap/debian/files/apt/apt.conf.d/99default-release
    - template: jinja
    - defaults:
        dist: {{ settings.get('dist', 'jessie') }}
    - user: root
    - group: root
    - mode: 644

sources_list_updates_src:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} updates sources
    - name: deb-src http://httpredir.debian.org/debian {{ settings.get('dist', 'jessie') }}-updates {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

sources_list_experimental:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} updates
    - name: deb http://httpredir.debian.org/debian experimental {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate
