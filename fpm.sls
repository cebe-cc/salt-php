
{% if grains['oscodename'] == 'bullseye' %}
{% set php_version='7.4' %}
{% elif grains['oscodename'] == 'buster' %}
{% set php_version='7.3' %}
{% elif grains['oscodename'] == 'stretch' %}
apt_https:
  pkg.installed:
    -   name: 'apt-transport-https'
# https://packages.sury.org/php/README.txt
php_repository:
  pkgrepo.managed:
    - humanname: PHP Debian Repository packages.sury.org
    - name: deb https://packages.sury.org/php/ {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - key_url: https://packages.sury.org/php/apt.gpg
    - file: /etc/apt/sources.list.d/php.list
    - require:
        -   pkg: apt_https
{% set php_version='7.3' %}
{% else %}
{% set php_version='5' %}
{% endif %}

php_fpm_packages:
  pkg:
    - installed
    - pkgs:
      {% if grains['oscodename'] == 'stretch' or grains['oscodename'] == 'buster' %}
      - php{{ php_version }}-cli
      - php{{ php_version }}-fpm
      - php{{ php_version }}-curl
      - php{{ php_version }}-intl
      - php{{ php_version }}-mbstring
      - php{{ php_version }}-gd
      - php{{ php_version }}-xml
{% if grains['oscodename'] == 'stretch' %}
    - require:
        - pkgrepo: php_repository
{% endif %}
      {% else %}
      - php5-cli
      - php5-fpm
      - php5-curl
      - php5-intl
      - php5-gd
      {% endif %}

php_fpm_service:
  service.running:
    {% if grains['oscodename'] == 'stretch' or grains['oscodename'] == 'buster' %}
    - name: php{{ php_version }}-fpm
    {% else %}
    - name: php5-fpm
    {% endif %}
    - enable: True
    - full_restart: True

# TODO fpm config
# TODO log rotate
# TODO lower error reporting for production env

/etc/php/{{ php_version }}/fpm/conf.d/50-custom.ini:
  file.managed:
    - contents: |
        error_reporting=-1
        log_errors=On
        display_errors=Off
        display_startup_errors=Off
        error_log=/var/log/php/errors.log
    - watch_in:
      - service: php_fpm_service

/var/log/php:
  file.directory:
    - mode: 0755
    - user: www-data

