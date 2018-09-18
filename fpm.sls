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
