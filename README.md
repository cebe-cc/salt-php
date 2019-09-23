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
- FPM
- ...

