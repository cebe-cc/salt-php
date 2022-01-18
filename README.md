# salt-php

Saltstack states to set up PHP on a server.

This state installs PHP from [Ondřej Surýs PHP packages](https://packages.sury.org/php/README.txt).
Please consider [supporting them](https://www.patreon.com/oerdnj) if you use this package.

## Usage

Add these to your saltstack states:

    git submodule add https://github.com/cebe-cc/salt-php.git salt/php
    
The states are independent of their actual location in the state file tree, so you may replace `salt/php` with a location of your choice.

## Supported OSs

- Debian
  - 9, `stretch`
  - 10, `buster`
  - 11, `bullseye`

## Features

- Install Composer
  - if pillar `composer-github-token` is present it will be used as github token for composer.
    It is required to authenticate against the github API to get hight API rate limit, mainly useful
    for running composer update on bigger projects.
- Installs PHP as FPM and CLI
- Default extensions installed: `bz2`, `curl`, `gd`, `intl`, `json`, `mbstring`, `opcache`, `readline`, `xml`, `zip`
- Install additional extensions by listing them in pillar:

  ```yaml
  php:
    extensions:
      - mysql
      - sqlite
  #   - ...
  ```

## Pillar example

```yaml
php:
  version: 7.4
  extensions:
    - mysql

composer-github-token: xxxxx
composer-home: '/opt/composer' # default - /root/.config/composer
composer-allow-superuser: 0 # default - 1
composer-plugins:  # name also used for match that plugin installed in composer global show
  - name: "composer-asset-plugin"
    src: "fxp/composer-asset-plugin:~1.4.4"
  - name: "prestissimo"
    src: "hirak/prestissimo"
  ...  
```
