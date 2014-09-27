#!jinja|yaml

{% from 'mongodb/defaults.yaml' import rawmap_osfam with context %}
{% from 'mongodb/defaults.yaml' import rawmap_os with context %}
{% set datamap = salt['grains.filter_by'](rawmap_osfam, merge=salt['grains.filter_by'](rawmap_os, grain='os', merge=salt['pillar.get']('mongodb:lookup'))) %}

include: {{ datamap.client.sls_include|default(['mongodb.client']) }}
extend: {{ datamap.client.sls_extend|default({}) }}

{% set client = datamap.client %}

mongodb_client:
  pkg:
    - installed
    - pkgs: {{ client.pkgs }}
