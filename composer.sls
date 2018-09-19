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
      - HOME: '/root'
    - unless: test -x /usr/local/bin/composer
    - require:
        - pkg: composer_php

# install composer-asset-plugin
composer_asset_plugin:
  cmd.run:
    - name: '/usr/local/bin/composer global require "fxp/composer-asset-plugin:~1.4.4"'
    - env:
      - HOME: '/root'
    - unless: /usr/local/bin/composer global show | grep composer-asset-plugin
    - require:
        - cmd: composer_installed
