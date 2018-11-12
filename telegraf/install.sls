{% from "telegraf/map.jinja" import telegraf with context %}
{% if grains['os'] == 'Ubuntu' %}
Add influx repository:
  pkgrepo.managed:
    - humanname: "InfluxData"
    - name: deb https://repos.influxdata.com/{{ salt['grains.get']("os", "ubuntu")|lower }}
    - file: /etc/apt/sources.list.d/influx.list
    - humanname: InfluxDB PPA
    - comps: stable
    - dist: {% if salt['grains.get']("oscodename") in ['artful', 'bionic', 'xenial', 'yakkety', 'zesty'] %}{{ salt['grains.get']("oscodename") }}{% else %}bionic{% endif %}
    - key_url: https://repos.influxdata.com/influxdb.key
    - clean_file: true
    - require_in:
      - pkg: telegraf

Install telegraf:
  pkg.latest:
    - name: telegraf
    - refresh: True
{% else %}
telegraf-pkg:
  file.managed:
    - name: /tmp/telegraf_{{ telegraf.version }}{{ telegraf.pkgsuffix }}
    - source: {{ telegraf.source_url }}{{ telegraf.version }}{{ telegraf.pkgsuffix }}
    - source_hash: md5={{ telegraf.source_hash }}
    - unless: test -f /tmp/telegraf_{{ telegraf.version }}{{ telegraf.pkgsuffix }}

telegraf-install:
  pkg.installed:
    - sources:
      - telegraf: /tmp/telegraf_{{ telegraf.version }}{{ telegraf.pkgsuffix }}
    - require:
      - file: telegraf-pkg
    - watch:
      - file: telegraf-pkg
{% endif %}
