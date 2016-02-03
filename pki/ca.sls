pki_ca_minion:
  service.running:
    - name: salt-minion
    - enable: True
    - listen:
      - file: /etc/salt/minion.d/signing_policies.conf

pki_ca_signing_policies:
  file.managed:
    - name: /etc/salt/minion.d/signing_policies.conf
    - source: salt://signing_policies.conf

pki_ca_dir:
  file.directory: 
    - name: /etc/pki
    - user: root
    - group: root
    - dir_mode: 0700

pki_ca_dir_issued_certs:
  file.directory:
    - name: /etc/pki/issued_certs
    - user: root
    - group: root
    - dir_mode: 0700
    - makedirs: True

pki_ca_key:
  x509.private_key_managed:
    - name: /etc/pki/ca.key
    - bits: 4096
    - backup: True
    - require:
      - file: /etc/pki

pki_ca_cert:
  x509.certificate_managed:
    - signing_private_key: /etc/pki/ca.key
    - CN: ca.example.com
    - C: US
    - ST: Utah
    - L: Salt Lake City
    - basicConstraints: "critical CA:true"
    - keyUsage: "critical cRLSign, keyCertSign"
    - subjectKeyIdentifier: hash
    - authorityKeyIdentifier: keyid,issuer:always
    - days_valid: 3650
    - days_remaining: 0
    - backup: True
    - require:
      - x509: /etc/pki/ca.key

pki_ca_pem_entries:
  module.run:
    - func: x509.get_pem_entries
    - kwargs:
        glob_path: /etc/pki/ca.crt
    - onchanges:
      - x509: pki_ca_cert
