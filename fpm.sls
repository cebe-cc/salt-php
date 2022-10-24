
{% if grains['oscodename'] == 'stretch' %}
# apt dependency for debian stretch
# apt-transport-https is obsolete in newer releases of debian
apt_https:
  pkg.installed:
    -   name: 'apt-transport-https'

{% endif %}

gnupg2:
  pkg.installed

{% if pillar.php.version is defined %}
{% set php_version=pillar.php.version %}
{% elif grains['oscodename'] == 'bullseye' %}
{% set php_version='7.4' %}
{% elif grains['oscodename'] == 'buster' %}
{% set php_version='7.3' %}
{% elif grains['oscodename'] == 'stretch' %}
{% set php_version='7.0' %}
{% else %}
{% set php_version='5' %}
{% endif %}

# https://packages.sury.org/php/README.txt
php_repository:
  pkgrepo.managed:
    - humanname: PHP Debian Repository packages.sury.org
    - name: deb https://packages.sury.org/php {{ grains['oscodename'] }} main
    - dist: {{ grains['oscodename'] }}
    - key_url: https://packages.sury.org/php/apt.gpg
    - file: /etc/apt/sources.list.d/php.list
    - require:
{% if grains['oscodename'] == 'stretch' %}
        -   pkg: apt_https
{% endif %}
        - pkg: gnupg2

php_fpm_packages:
  pkg.installed:
    - pkgs:
      - php{{ php_version }}-cli
      - php{{ php_version }}-fpm
      - php{{ php_version }}-bz2
      - php{{ php_version }}-curl
      - php{{ php_version }}-gd
      - php{{ php_version }}-intl
{% if php_version != '8.1' %}
      - php{{ php_version }}-json
{% endif %}
      - php{{ php_version }}-mbstring
      - php{{ php_version }}-opcache
      - php{{ php_version }}-readline
      - php{{ php_version }}-xml
      - php{{ php_version }}-zip
{% if pillar.php.extensions is defined %}
  {% for phpext in pillar.php.extensions %}
      - php{{ php_version }}-{{ phpext }}
  {% endfor %}
{% endif %}
    - require:
      - pkgrepo: php_repository
    - watch_in:
      - service: php_fpm_service

php_fpm_service:
  service.running:
    - name: php{{ php_version }}-fpm
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
        error_log=/var/log/php/fpm-errors.log
    - watch_in:
      - service: php_fpm_service

# TODO make pools configurable
/etc/php/{{ php_version }}/fpm/pool.d/www.conf:
  file.managed:
    - contents: |
        ; Start a new pool named 'www'.
        ; the variable $pool can be used in any directive and will be replaced by the
        ; pool name ('www' here)
        [www]
        user = www-data
        group = www-data

        listen = /run/php/php{{ php_version }}-fpm.sock
        listen.owner = www-data
        listen.group = www-data

        pm = dynamic

        ; This value sets the limit on the number of simultaneous requests that will be
        ; served.
        pm.max_children = 50

        ; The number of child processes created on startup.
        ; Default Value: min_spare_servers + (max_spare_servers - min_spare_servers) / 2
        ;pm.start_servers = 7

        ; The desired minimum number of idle server processes.
        pm.min_spare_servers = 5

        ; The desired maximum number of idle server processes.
        pm.max_spare_servers = 10

        ; The number of seconds after which an idle process will be killed.
        pm.process_idle_timeout = 10s;

        ; The number of requests each child process should execute before respawning.
        ; This can be useful to work around memory leaks in 3rd party libraries. For
        ; endless request processing specify '0'. Equivalent to PHP_FCGI_MAX_REQUESTS.
        ; Default Value: 0
        ;pm.max_requests = 500

        ; The access log file
        ; Default: not set
        ;access.log = log/$pool.access.log

        ; The log file for slow requests
        ; Default Value: not set
        ; Note: slowlog is mandatory if request_slowlog_timeout is set
        ;slowlog = log/$pool.log.slow

        ; The timeout for serving a single request after which a PHP backtrace will be
        ; dumped to the 'slowlog' file. A value of '0s' means 'off'.
        ; Available units: s(econds)(default), m(inutes), h(ours), or d(ays)
        ; Default Value: 0
        ;request_slowlog_timeout = 0

        ; The timeout for serving a single request after which the worker process will
        ; be killed. This option should be used when the 'max_execution_time' ini option
        ; does not stop script execution for some reason. A value of '0' means 'off'.
        ; Available units: s(econds)(default), m(inutes), h(ours), or d(ays)
        ; Default Value: 0
        ;request_terminate_timeout = 0

        ; Default Value: nothing is defined by default except the values in php.ini and
        ;                specified at startup with the -d argument
        ;php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f www@my.domain.com
        ;php_flag[display_errors] = off
        ;php_admin_value[error_log] = /var/log/fpm-php.www.log
        ;php_admin_flag[log_errors] = on
        ;php_admin_value[memory_limit] = 32M

    - watch_in:
      - service: php_fpm_service

/var/log/php:
  file.directory:
    - mode: 0755
    - user: www-data

