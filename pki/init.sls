pki_dir:
  file.directory:
    - name: /usr/local/share/ca-certificates

pki_cert:
  x509.pem_managed:
    - name: /usr/local/share/ca-certificates/cluster.crt
    - text: {{ salt['mine.get']('ca', 'x509.get_pem_entries')['ca']['/etc/pki/ca.crt']|replace('\n', '') }}
