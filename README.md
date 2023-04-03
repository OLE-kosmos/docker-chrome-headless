# Docker Chrome Headless

This project provides a Docker image for use in [behat-chrome/behat-chrome-extension](https://gitlab.com/behat-chrome/behat-chrome-extension) & [behat-chrome/chrome-mink-driver](https://gitlab.com/behat-chrome/chrome-mink-driver).

It builds images for a range of supported PHP versions and adds the current release of Chrome.

See Dockerfile for details.

## Supported PHP versions

Version support for PHP depends on the available tags of [Official PHP image](https://hub.docker.com/_/php) in `php-fpm` variant.

When a new version of PHP is released as a `php-fpm` image from , the "latest" CI builds of this should switch to that version for future builds.

- Supported: 7.4, 8.0, 8.1, 8.2
- Default: 8.1

Merge requests to add new releases are welcome! See below.

## Updating the supported & default PHP versions

- Modify the default version in `Dockerfile` (`ARG PHP_VERSION=x.x`)
- Modify the tested/built versions in `.gitlab-ci.yml`
- Modify the list of versions above in `README.md`.
- Merge request to verify successful test builds

## Usage

This is really only intended as a tool to facilitate testing of [behat-chrome/behat-chrome-extension](https://gitlab.com/behat-chrome/behat-chrome-extension) & [behat-chrome/chrome-mink-driver](https://gitlab.com/behat-chrome/chrome-mink-driver).
