php_fpm_packages:
  pkg:
    - installed
    - pkgs:
      {% if grains['oscodename'] == 'stretch' %}
      - php-cli
      - php-fpm
      - php-curl
      - php-intl
      - php-mbstring
      - php-gd
      - php-xml
      {% else %}
      - php5-cli
      - php5-fpm
      - php5-curl
      - php5-intl
      - php5-gd
      {% endif %}

php_fpm_service:
  service.running:
    {% if grains['oscodename'] == 'stretch' %}
    - name: php7.0-fpm
    {% else %}
    - name: php5-fpm
    {% endif %}
    - enable: True
    - full_restart: True

# TODO fpm config
# TODO log rotate

/etc/php/7.0/fpm/conf.d/50-custom.ini:
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

