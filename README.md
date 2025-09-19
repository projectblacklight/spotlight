spotlight
=========

![CI](https://github.com/projectblacklight/spotlight/workflows/CI/badge.svg) | [![Gem Version](https://badge.fury.io/rb/blacklight-spotlight.png)](http://badge.fury.io/rb/blacklight-spotlight) | [Release Notes](https://github.com/projectblacklight/spotlight/releases) | [Design Documents](https://github.com/projectblacklight/spotlight/releases/tag/v0.0.0)

Spotlight is open source software that enables librarians, curators, and other content experts to easily build feature-rich websites that showcase collections and objects from a digital repository, uploaded items, or a combination of the two. Spotlight is a plug-in for [Blacklight](https://github.com/projectblacklight/blacklight), an open source, Ruby on Rails Engine that provides a basic discovery interface for searching an Apache Solr index.

In addition to the information found below, you read more about what Spotlight is, our motivations for creating it, and how to configure it in the [wiki pages](https://github.com/projectblacklight/spotlight/wiki). You might also want to take a look at our demo videos, especially the [tour of a completed Spotlight exhibit](https://www.youtube.com/watch?v=_A7vTbbiF4g) and the walkthrough of [building an exhibit with Spotlight](https://www.youtube.com/watch?v=qPJtgajJ4ic).

If you have questions or are interested in contributing, please reach out to the [Spotlight Community](#spotlight-community)

## Requirements

1. [Ruby](https://www.ruby-lang.org/) 3.2+
2. [Ruby on Rails](https://rubyonrails.org/) 7.1+
3. Java (11 or greater) *for Solr*
4. ImageMagick (http://www.imagemagick.org/script/index.php) due to [carrierwave](https://github.com/carrierwaveuploader/carrierwave#adding-versions)

## Installation

The following installation instructions are for setting up a new instance of Spotlight. To set up an environment for Spotlight development, see [Developing Spotlight](#contributing-to-spotlight).

To bootstrap a new Rails application using [importmap-rails](https://github.com/rails/importmap-rails):

```
$ SKIP_TRANSLATION=1 rails new app-name -m https://raw.githubusercontent.com/projectblacklight/spotlight/main/template.rb -a propshaft --css bootstrap
```

or using [jsbundling-rails](https://github.com/rails/jsbundling-rails) with [esbuild](https://esbuild.github.io/):

```
$ SKIP_TRANSLATION=1 rails new app-name -m https://raw.githubusercontent.com/projectblacklight/spotlight/main/template.rb -a propshaft -j esbuild --css bootstrap
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
$ bin/dev
```

Go to http://localhost:3000 in your browser.

## Configuration

### Default ActionMailer configuration

Spotlight introduces functionality that depends on being able to send emails to exhibit curators and contacts. Be sure to configure your application's environments appropriately (see the Rails Guide for [Action Mailer Configuration](https://guides.rubyonrails.org/v7.2/action_mailer_basics.html#action-mailer-configuration)).

See the [Spotlight wiki](https://github.com/projectblacklight/spotlight/wiki) for more detailed information on configuring Spotlight.

## Translations

Spotlight ships with [`i18n-tasks`](https://github.com/glebm/i18n-tasks) to help manage translations. To run a translation health check:

```sh
bundle exec i18n-tasks health
```

See [developer-facing instructions for enabling translation](https://github.com/projectblacklight/spotlight/wiki/Translations) on the wiki.

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

See [Updating the JavaScript bundle](#updating-the-javascript-bundle) above for more details.

## Developing Spotlight

### Branches

* The `main` branch is for development of the upcoming 5.0 release.
* The `4.x` series is on the [release-4.x](https://github.com/projectblacklight/spotlight/tree/release-4.x) branch for backports of features and bug fixes.

### Tooling

* Spotlight is a Rails engine and needs to be used in the context of a Rails application. We use [engine_cart](https://github.com/cbeer/engine_cart) to create an internal test application at `.internal_test_app/`. 
* Spotlight relies on Solr for its integration tests and to run a development instance. [solr_wrapper](https://github.com/cbeer/solr_wrapper) allows us to provide terse commands for development and testing. For more granular control, you can run Solr in Docker, then execute services and processes individually.
* Spotlight's `rake spotlight:server` and `rake ci` tasks use engine_cart and Solr automatically, but you can refer to [engine_cart](https://github.com/cbeer/engine_cart) and [solr_wrapper](https://github.com/cbeer/solr_wrapper) documentation to work with these tools outside of those rake tasks.

### Initial setup

1. Install the [requirements above](#requirements). Note: You do not need to install Java if you plan to run Solr in Docker. 
2. Clone the spotlight repository locally and `cd` into it.
3. Install the Ruby gems used by spotlight: `bundle install`.

Note: if your system is confused by conflicting gem versions, you may need to add "bundle exec" to the beginning of each command below, e.g. `bundle exec rake engine_cart:generate`. This ensures that the command is run in the context of bundler's gem version management.

### Run a development server

After following one of the instructions below, visit http://localhost:3000. A Solr instance will be running on port 8983. When using importmap (the default configuration), JavaScript changes in development should not require [bundling](#updating-the-javascript-bundle) or a server restart.

#### With solr_wrapper

The following rake task will build a Spotlight-based application, start Solr with solr_wrapper, and run the built-in rails server. In the process, you will be prompted to create an admin user and password.

```sh
rake spotlight:server
```

Alternatively, you can use [individual commands](#individual-commands) to start Solr separately and set everything else up.

```sh
solr_wrapper # Run in separate tab
rake engine_cart:generate
rake spotlight:fixtures
cd .internal_test_app
bin/rails spotlight:initialize
bin/dev
```

#### With Docker

The following will run Solr in Docker and then use individual commands to set up a running development server.

```sh
docker compose up -d
rake engine_cart:generate
rake spotlight:fixtures
cd .internal_test_app
rake spotlight:seed_admin_user
bin/dev
```

### Run tests

#### With solr_wrapper

The following rake task will build a Spotlight-based application, start Solr, run the tests, and then shut down Solr when the tests are finished. Solr should not be running already when you run this.
```sh
rake
```

#### With Docker (or solr_wrapper, if Solr is started separately)

If you're using Solr on Docker, run `docker compose up -d` to start Solr if you haven't already. Once you have Solr running (either on Docker or with solr_wrapper), run the tests using the following commands:
```sh
rake engine_cart:generate
rake spotlight:fixtures
cd .internal_test_app && rake spec:prepare && cd - # not needed if you ran the dev server
rspec
```

Using rspec directly allows you to run individual test files / lines. You can delete these tests again with `rake assets:clobber`.

Once you are set up, you can also run `rubocop` to enforce consistent coding style.


### Individual commands

#### Using solr_wrapper

Start Solr with solr_wrapper: 
```
solr_wrapper
```
Reset Solr using solr_wrapper to a pristine state (e.g. remove Solr docs, core, etc.):
```
solr_wrapper clean
```
Note: Sometimes solr doesn't shut down properly.  You can check by seeing if solr is running:
```
ps -eaf | grep solr
```

#### Using test fixtures

Add fixture data to Solr:
```
rake spotlight:fixtures
```
Delete an existing solr index:
```
rails c
> Blacklight.default_index.connection.delete_by_query "*:*"
> Blacklight.default_index.connection.commit
```

#### Generating and running the test app

Build the test app: 
```
rake engine_cart:generate
```
From `./internal_test_app`, create the initial admin user:

*With [default credientials](https://github.com/projectblacklight/spotlight/blob/9acd4bf5d4f2806b6e76aa03c31176ea5f6943de/lib/tasks/spotlight_tasks.rake#L20-L21)*
```
rake spotlight:seed_admin_user
```
*With user-provided credientials*
```
bin/rails spotlight:initialize
```
From `./internal_test_app`, start Rails to run the test app:
```
bin/dev
```
From the project root, delete the test app (if you want to regenerate from scratch):
```
$ rake engine_cart:clean
```
## Spotlight Community

See [Contributing to Spotlight](/CONTRIBUTING.md) for general information about participation in the Spotlight community.

### Where to find us

- Join us on the [code4lib Slack](https://code4lib.org/irc)
  - **#spotlight-development** - a developer-focused channel for Spotlight
  - **#blacklight** - a developer-focused channel for discussing implementation, customization, and other software concerns in the larger [Blacklight community](http://projectblacklight.org/)
  - **#spotlight-service** - a service-focused channel for people who support exhibit-builders at institutions already using Spotlight
- Google Groups
  - [Blacklight Development Google group](https://groups.google.com/forum/#!forum/blacklight-development)
  - [Spotlight Community Group](https://groups.google.com/forum/#!forum/spotlight-community) (equivalent to #spotlight-service)