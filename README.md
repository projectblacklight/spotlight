spotlight
=========

![CI](https://github.com/projectblacklight/spotlight/workflows/CI/badge.svg) | [![Gem Version](https://badge.fury.io/rb/blacklight-spotlight.png)](http://badge.fury.io/rb/blacklight-spotlight) | [Release Notes](https://github.com/projectblacklight/spotlight/releases) | [Design Documents](https://github.com/projectblacklight/spotlight/releases/tag/v0.0.0)

Spotlight is open source software that enables librarians, curators, and other content experts to easily build feature-rich websites that showcase collections and objects from a digital repository, uploaded items, or a combination of the two. Spotlight is a plug-in for [Blacklight](https://github.com/projectblacklight/blacklight), an open source, Ruby on Rails Engine that provides a basic discovery interface for searching an Apache Solr index.

Read more about what Spotlight is, our motivations for creating it, and how to install and configure it in the [wiki pages](https://github.com/projectblacklight/spotlight/wiki). You might also want to take a look at our demo videos, especially the [tour of a completed Spotlight exhibit](https://www.youtube.com/watch?v=_A7vTbbiF4g) and the walkthrough of [building an exhibit with Spotlight](https://www.youtube.com/watch?v=qPJtgajJ4ic).

## Requirements

1. Ruby (2.7 or greater)
2. Rails (5.2 or greater)
3. Java (7 or greater) *for Solr*
4. ImageMagick (http://www.imagemagick.org/script/index.php) due to [carrierwave](https://github.com/carrierwaveuploader/carrierwave#adding-versions)

## Installation

To bootstrap a new Rails application:

```
$ SKIP_TRANSLATION=1 rails new app-name -m https://raw.githubusercontent.com/projectblacklight/spotlight/main/template.rb -a propshaft -j esbuild
```

or from an existing Rails application:

```
$ SKIP_TRANSLATION=1 rails app:template LOCATION=https://raw.githubusercontent.com/projectblacklight/spotlight/main/template.rb
```

*During this process you will be prompted to enter an initial administrator email and password (this is a super-admin that can administer any exhibit in the installation).* If you choose not to create one, the first user will be given administrative privileges.

Change directories to your new application:

```
$ cd app-name
```

Run the database migrations:

```
$ SKIP_TRANSLATION=1 rake db:migrate
```

Start Solr (possibly using `solr_wrapper` in development or testing):

```
$ solr_wrapper
```

and the Rails development server:

```
$ rails server
```

Go to http://localhost:3000 in your browser.

## Configuration

### Default ActionMailer configuration

Spotlight introduces functionality that depends on being able to send emails to exhibit curators and contacts. Be sure to configure your application's environments appropriately (see the Rails Guide for [Action Mailer Configuration](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration)).

See the [Spotlight wiki](https://github.com/projectblacklight/spotlight/wiki) for more detailed information on configuring Spotlight.

# Developing Spotlight

## Branches

* The `main` branch is for development of the upcoming 5.0 release.
* The `4.x` series is on the [release-4.x](https://github.com/projectblacklight/spotlight/tree/release-4.x) branch for backports of features and bug fixes.

## Spotlight

* is a Rails engine and needs to be used in the context of a Rails application. We use [engine_cart](https://github.com/cbeer/engine_cart) to create an internal test application at .internal_test_app/
* uses Solr as part of its integration tests. We use [solr_wrapper](https://github.com/cbeer/solr_wrapper) to manage the Solr instance used for development and test.

Our `$ rake ci` and `$ rake spotlight:server` tasks utilize Solr and the testing rails app automatically.

See more detailed instructions for development environment setup at ["Contributing to Spotlight"](https://github.com/projectblacklight/spotlight/wiki/Contributing-to-Spotlight)

## With Docker

```sh
# because of how docker compose handles named images, running `docker compose up --build` will error when the Rails images have not been built locally
docker compose build
docker compose up
```

## Tests

### Run all the tests:

```
$ rake
```

This utilizes Solr and the testing rails app automatically.

## Translations

Spotlight ships with [`i18n-tasks`](https://github.com/glebm/i18n-tasks) to help manage translations. To run a translation health check:

```sh
$ bundle exec i18n-tasks health
```

See [developer-facing instructions for enabling translation](https://github.com/projectblacklight/spotlight/wiki/Translations) on the wiki.

## Community


- Join us on the [code4lib Slack](https://code4lib.org/irc)
  - **#spotlight-development** - a developer-focused channel for Spotlight
  - **#blacklight** - a developer-focused channel for discussing implementation, customization, and other software concerns in the larger [Blacklight community](http://projectblacklight.org/)
  - **#spotlight-service** - a service-focused channel for people who support exhibit-builders at institutions already using Spotlight
- Google Groups
  - [Blacklight Development Google group](https://groups.google.com/forum/#!forum/blacklight-development)
  - [Spotlight Community Group](https://groups.google.com/forum/#!forum/spotlight-community) (equivalent to #spotlight-service)

## Updating the JavaScript bundle
The JavaScript is built by npm from sources in `app/javascript` into a bundle
in `app/assets/javascripts/spotlight/spotlight.js`. This file should not be edited
by hand as any changes would be overwritten.  When any of the JavaScript
components in the gem are changed, this bundle should be rebuilt with the
following steps:
1. [Install npm](https://www.npmjs.com/get-npm)
2. Run `npm install` to download dependencies
3. Run `npm run prepare` to build the bundle
4. If you are releasing a new version of the gem, follow the release instructions below.

## Releasing a new version and publishing the JavaScript
You only need to update `package.json` and prepare/publish the JavaScript package for npm if there are changes to the JavaScript.
1. Edit `version.rb` and `package.json` to set the new version
2. Run `npm run prepare` to build the JavaScript bundle
3. Run `npm i --package-lock-only` to update the version in `package-lock.json`
4. Commit the changes e.g. `git commit -am "Bump version to X.X.X"`
5. Push the release to rubygems and GitHub: `bundle exec rake release`
6. Run `npm publish` to push the JavaScript package to https://npmjs.org/package/spotlight-frontend

See "Updating the JavaScript bundle" above for more details.
