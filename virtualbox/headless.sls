{%- from 'virtualbox/map.jinja' import virtualbox with context -%}

{%- set deps = [] -%}
{%- if grains.os_family == 'FreeBSD' -%}
  {%- do deps.extend(['virtualbox_vboxdrv_load', 'virtualbox_vboxnet_enable',
                      'virtualbox_headless_enable', 'virtualbox_headless_machines',
                      'virtualbox_headless_user', 'virtualbox_headless_stopcmd',]) -%}
{%- endif -%}

{% if grains.os_family == 'FreeBSD' %}
virtualbox_headless_enable:
  sysrc.managed:
    - name: vboxheadless_enable
    - value: 'YES'

virtualbox_headless_machines:
  sysrc.managed:
    - name: vboxheadless_machines
    - value: {{ virtualbox.headless.machines.keys() | join }}

virtualbox_headless_user:
  sysrc.managed:
    - name: vboxheadless_user
    - value: {{ virtualbox.headless.user | yaml_encode }}

virtualbox_headless_stopcmd:
  sysrc.managed:
    - name: vboxheadless_stop
    - value: {{ virtualbox.headless.stop_cmd | yaml_encode }}

{% for name, machine in virtualbox.headless.machines.items() %}
virtualbox_headless_machine_{{ name }}:
  sysrc.managed:
    - name: vboxheadless_{{ name }}_name
    - value: {{ name | yaml_encode }}
  {%- for key in ['user', 'flags', 'stop', 'delay'] %}
    {%- if key in machine %}
virtualbox_headless_machine_{{ name }}_{{ key }}:
  sysrc.managed:
    - name: vboxheadless_{{ name }}_{{ key }}
    - value: {{ machine[key] | yaml_encode }}
    {%- endif %}
  {%- endfor %}
{% endfor %}
{% endif %}

virtualbox_headless_service:
  service.enabled:
    - name: vboxheadless
    - require:
{% for label in deps %}
      - sysrc: {{ label }}
{% endfor %}

  module.run:
    - name: service.start
    - m_name: vboxheadless
    - require:
      - service: virtualbox_headless_service
{% for label in deps %}
      - sysrc: {{ label }}
{% endfor %}
    - check_cmd:
      # TODO: check for running VMs
      - /usr/bin/true
