# salt-php
Saltstack states to set up PHP on a server.

## Usage

Add these to your saltstack states:

    git submodule add https://github.com/cebe-cc/salt-php.git salt/php
    
The states are independent of their actual location in the state file tree, so you may replace `salt/php` with a location of your choice.

## Supported OSs

- Debian
  - 8, `jessie`
  - 9, `stretch`
  - 10, `buster`

## Features

- Install Composer
  - if pillar `composer-github-token` is present it will be used as github token for composer.
    It is required to authenticate against the github API to get hight API rate limit, mainly useful
    for running composer update on bigger projects.
- FPM
- ...

## Pillar example

```yaml
composer-github-token: xxxxx
composer-home: '/opt/composer' # default - /root
composer-plugins:  # name also used for match that plugin installed in composer global show
  - name: "composer-asset-plugin"
    src: "fxp/composer-asset-plugin:~1.4.4"
  - name: "prestissimo"
    src: "hirak/prestissimo"
  ...  
```
