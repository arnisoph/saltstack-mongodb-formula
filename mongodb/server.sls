#!jinja|yaml

{% from 'mongodb/defaults.yaml' import rawmap_osfam with context %}
{% from 'mongodb/defaults.yaml' import rawmap_os with context %}
{% set datamap = salt['grains.filter_by'](rawmap_osfam, merge=salt['grains.filter_by'](rawmap_os, grain='os', merge=salt['pillar.get']('mongodb:lookup'))) %}

include: {{ datamap.server.sls_include|default(['mongodb.client']) }}
extend: {{ datamap.server.sls_extend|default({}) }}

{% set srv = datamap.server %}

mongodb_server:
  pkg:
    - installed
    - pkgs: {{ srv.pkgs }}
  service:
    - running
    - name: {{ srv.service.name }}
    - enable: {{ srv.service.enable|default(True) }}

{% for k, v in salt['pillar.get']('mongodb:users', {}).items() %}
mongodb_user_{{ k }}:
  mongodb_user:
    - {{ v.ensure|default('present') }}
    - name: {{ v.name|default(k) }}
    - passwd: {{ v.passwd }}
    - database: {{ v.database|default('admin') }}
    - require:
      - service: mongodb_server
{% endfor %}

{% for k, v in salt['pillar.get']('mongodb:databases', {}).items() %}
mongodb_database_{{ k }}:
  mongodb_database:
    - absent
    - name: {{ v.name|default(k) }}
    - require:
      - service: mongodb_server
{% endfor %}
