{% set settings = salt['pillar.get']('bootstrap:lookup:settings:debian', {}) %}

packages:
	pkg.installed:
		- python-apt
		- aptitude
		- debconf-utils
		- apt-utils

sources_list:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} packages
    - name: deb http://httpredir.debian.org/debian {{ settings.get('dist', 'jessie') }} {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} sources
    - name: deb-src http://httpredir.debian.org/debian {{ settings.get('dist', 'jessie') }} {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} security updates
    - name: deb http://security.debian.org/debian {{ settings.get('dist', 'jessie') }}/updates {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} security updates sources
    - name: deb-src http://security.debian.org/debian {{ settings.get('dist', 'jessie') }}/updates {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} updates
    - name: deb http://httpredir.debian.org/debian {{ settings.get('dist', 'jessie') }}-updates {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} updates sources
    - name: deb-src http://httpredir.debian.org/debian {{ settings.get('dist', 'jessie') }}-updates {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'jessie') }} updates
    - name: deb http://httpredir.debian.org/debian experimental {{ settings.get('components', 'main') }}
    - dist: {{ settings.get('dist', 'jessie') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - pkg: python-apt
    - consolidate

apt_conf_defaultrelease:
  file:
    - managed
    - name: /etc/apt/preferences.d/updates
    - source: salt://bootstrap/debian/files/apt/apt.conf.d/99default-release
    - template: jinja
    - defaults:
        dist: {{ settings.get('dist', 'jessie') }}
    - user: root
    - group: root
    - mode: 644

apt_preferences_updates:
  file:
    - managed
    - name: /etc/apt/preferences.d/updates
    - source: salt://bootstrap/debian/files/apt/preferences.d/updates
    - template: jinja
    - defaults:
        dist: {{ settings.get('dist', 'jessie') }}
    - user: root
    - group: root
    - mode: 644
