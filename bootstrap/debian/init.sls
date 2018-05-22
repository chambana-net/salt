{% set settings = salt['pillar.get']('bootstrap:lookup:settings:debian', {}) %}

apt_packages:
  pkg.installed:
    - pkgs:
      - python-apt
      - aptitude
      - debconf-utils
      - apt-utils

sources_list:
  file.absent:
    - name: /etc/apt/sources.list

sources_list_default:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} packages
    - name: deb http://httpredir.debian.org/debian {{ settings.get('dist', 'stretch') }} {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/distro.list
    - require:
      - file: sources_list
    - require_in:
      - pkg: apt_packages

sources_list_default_src:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} sources
    - name: deb-src http://httpredir.debian.org/debian {{ settings.get('dist', 'stretch') }} {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/distro.list

sources_list_security:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} security updates
    - name: deb http://security.debian.org/ {{ settings.get('dist', 'stretch') }}/updates {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/distro.list

sources_list_security_src:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} security updates sources
    - name: deb-src http://security.debian.org/ {{ settings.get('dist', 'stretch') }}/updates {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/distro.list

sources_list_updates:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} updates
    - name: deb http://httpredir.debian.org/debian {{ settings.get('dist', 'stretch') }}-updates {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/distro.list

sources_list_updates_src:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} updates sources
    - name: deb-src http://httpredir.debian.org/debian {{ settings.get('dist', 'stretch') }}-updates {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/distro.list

sources_list_testing:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} packages
    - name: deb http://httpredir.debian.org/debian testing {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/testing.list

sources_list_testing_src:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} sources
    - name: deb-src http://httpredir.debian.org/debian testing {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/testing.list

sources_list_testing_security:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} security updates
    - name: deb http://security.debian.org/ testing/updates {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/testing.list

sources_list_testing_security_src:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} security updates sources
    - name: deb-src http://security.debian.org/ testing/updates {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/testing.list

sources_list_experimental:
  pkgrepo.managed:
    - humanname: {{ settings.get('dist', 'stretch') }} updates
    - name: deb http://httpredir.debian.org/debian experimental {{ settings.get('components', 'main') }}
    - file: /etc/apt/sources.list.d/experimental.list

apt_conf_defaultrelease:
  file.managed:
    - name: /etc/apt/apt.conf.d/99default-release
    - source: salt://bootstrap/debian/files/apt/apt.conf.d/99default-release
    - template: jinja
    - defaults:
        dist: {{ settings.get('dist', 'stretch') }}
    - user: root
    - group: root
    - mode: 644

apt_preferences_pinning:
  file.managed:
    - name: /etc/apt/preferences.d/distro
    - source: salt://bootstrap/debian/files/apt/preferences.d/distro
    - template: jinja
    - defaults:
        dist: {{ settings.get('dist', 'stretch') }}
    - user: root
    - group: root
    - mode: 644
