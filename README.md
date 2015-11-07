spotlight
=========

[![Build Status](https://travis-ci.org/sul-dlss/spotlight.png?branch=master)](https://travis-ci.org/sul-dlss/spotlight) | [![Coverage Status](https://coveralls.io/repos/sul-dlss/spotlight/badge.png?branch=master)](https://coveralls.io/r/sul-dlss/spotlight) | [![Gem Version](https://badge.fury.io/rb/blacklight-spotlight.png)](http://badge.fury.io/rb/blacklight-spotlight) | [Release Notes](https://github.com/sul-dlss/spotlight/releases) | [Design Documents](https://github.com/sul-dlss/spotlight/releases/tag/v0.0.0)

Spotlight is open source software that enables librarians, curators, and other content experts to easily build feature-rich websites that showcase collections and objects from a digital repository, uploaded items, or a combination of the two. Spotlight is a plug-in for [Blacklight](https://github.com/projectblacklight/blacklight), an open source, Ruby on Rails Engine that provides a basic discovery interface for searching an Apache Solr index.

Read more about what Spotlight is, our motivations for creating it, and how to install and configure it in the [wiki pages](https://github.com/sul-dlss/spotlight/wiki). You might also want to take a look at our demo videos, especially the [tour of a completed Spotlight exhibit](https://www.youtube.com/watch?v=_A7vTbbiF4g) and the walkthrough of [building an exhibit with Spotlight](https://www.youtube.com/watch?v=qPJtgajJ4ic).

## Requirements

1. Ruby (2.2.0 or greater)
2. Rails (4.2.0 or greater)
3. Java (7 or greater) *for Solr*
4. ImageMagick (http://www.imagemagick.org/script/index.php) due to [carrierwave](https://github.com/carrierwaveuploader/carrierwave#adding-versions)

## Installation

To bootstrap a new Rails application:

```
$ rails new app-name -m https://raw.githubusercontent.com/sul-dlss/spotlight/master/template.rb
```

or from an existing Rails application:

```
$ rake rails:template LOCATION=https://raw.githubusercontent.com/sul-dlss/spotlight/master/template.rb
```

*During this process you will be prompted to enter an initial administrator email and password (this is a super-admin that can administer any exhibit in the installation).* If you choose not to create one, the first user will be given administrative privileges.

Change directories to your new application:

```
$ cd app-name
```

Run the database migrations:

```
$ rake db:migrate
```

Start solr:

```
$ rake jetty:start
```

Start the rails development server:

```
$ rails s
```

Go to http://localhost:3000 in your browser.


## Configuration

### Default ActionMailer configuration

Spotlight introduces functionality that depends on being able to send emails to exhibit curators and contacts. Be sure to configure your application's environments appropriately (see the Rails Guide for [Action Mailer Configuration](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration)).

### More

See the [Spotlight wiki](https://github.com/sul-dlss/spotlight/wiki) for more detailed information on configuring Spotlight.

# Developing Spotlight

Spotlight:

* is a Rails engine and needs to be used in the context of a Rails application. We use [engine_cart](https://github.com/cbeer/engine_cart) to create an internal test application at .internal_test_app/
* uses Solr as part of its integration tests. We use [jettywrapper](https://github.com/projecthydra/jettywrapper) to manage the Solr instance used for development and test.

Our `$ rake ci` and `$ rake spotlight:server` tasks utilize Solr and the testing rails app automatically.

##  More Information for Developers

* [Contributing to Spotlight](https://github.com/sul-dlss/spotlight/wiki/Contributing-to-Spotlight)
* [Testing](https://github.com/sul-dlss/spotlight/wiki/Testing)

## Tests

### Prerequisites

PhantomJS (https://github.com/teampoltergeist/poltergeist#installing-phantomjs) is an addition requirement for testing javascript.

### Run all the tests:

```
$ rake
```

This utilizes Solr and the testing rails app automatically.
