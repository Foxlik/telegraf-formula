{% from "telegraf/map.jinja" import telegraf with context %}
{% if grains['os'] == 'Ubuntu' %}
Add influx repository:
  pkgrepo.managed:
    - name: deb https://repos.influxdata.com/{{ grains['os']|lower }} xenial stable
    - file: /etc/apt/sources.list.d/influx.list
    - humanname: InfluxDB PPA
    - comps: stable
    - dist: xenial
    - key_url: https://repos.influxdata.com/influxdb.key
    - clean_file: true
    - require_in:
      - telegraf

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