{% from "pki/map.jinja" import pki with context %}
{% set settings = salt['pillar.get']('pki:lookup:settings', {}) %}

pki_dir:
  file.directory:
    - name: {{ pki.dir }}

pki_cert:
  x509.pem_managed:
    - name: {{ pki.cert }}
    - text: {{ salt['mine.get']('riker', 'x509.get_pem_entries')['ca']['/etc/pki/ca.crt']|replace('\n', '') }}
