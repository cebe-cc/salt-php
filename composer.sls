# TODO add signature check like described on https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
#
# https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md

# ensure php is installed with zip extension and we have git to clone repos
composer_php:
  pkg.installed:
    - pkgs:
        - php-cli
        - php-zip
        - unzip
        - git

# install composer
composer_installed:
  cmd.run:
    - name: cd /usr/local/bin && curl -sS https://getcomposer.org/installer | php && ln -sf composer.phar composer
    - env:
       - HOME: '{{pillar.get('composer-home', '/root')}}'
    - unless: test -x /usr/local/bin/composer
    - require:
        - pkg: composer_php

# install composer plugins
{% for plugin in pillar.get('composer-plugins', []) %}
composer_{{plugin.name}}:
   cmd.run:
       - name: '/usr/local/bin/composer global require "{{plugin.src}}"'
       - env:
          - HOME: '{{pillar.get('composer-home', '/root')}}'
       - unless: /usr/local/bin/composer global show | grep {{plugin.name}}
       - require:
           - cmd: composer_installed
{% endfor %}

{% if pillar['composer-github-token'] is defined %}
composer_github_token:
  cmd.run:
    - name: composer config --global github-oauth.github.com {{ pillar['composer-github-token'] }}
    - unless: test $(composer config --global github-oauth.github.com) = "{{ pillar['composer-github-token'] }}"
    - require:
        - cmd: composer_installed
{% endif %}
