{%- from 'virtualbox/map.jinja' import virtualbox with context -%}

virtualbox_pkg:
  pkg.installed:
    - name: {{ virtualbox.package }}
{% for name, value in virtualbox.pkg_options %}
    - {{ name }}: {{ value | yaml }}
{% endfor %}

{% if grains.os_family == 'FreeBSD' %}
virtualbox_vboxdrv_load:
  sysrc.managed:
    - name: vboxdrv_load
    - value: 'YES'
    - file: /boot/loader.conf
virtualbox_vboxnet_enable:
  sysrc.managed:
    - name: vboxnet_enable
    - value: 'YES'
{% endif %}
