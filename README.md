spotlight
=========

[![Build Status](https://travis-ci.org/sul-dlss/spotlight.png?branch=master)](https://travis-ci.org/sul-dlss/spotlight) | [![Coverage Status](https://coveralls.io/repos/sul-dlss/spotlight/badge.png?branch=master)](https://coveralls.io/r/sul-dlss/spotlight) | [![Gem Version](https://badge.fury.io/rb/blacklight-spotlight.png)](http://badge.fury.io/rb/blacklight-spotlight) | [Release Notes](https://github.com/sul-dlss/spotlight/releases) | [Design Documents](https://github.com/sul-dlss/spotlight/releases/tag/v0.0.0)

Spotlight is open source software that sits on top of a digital repository and enables librarians, curators, and other content experts to easily build feature-rich websites that showcase collections and objects from that repository. Spotlight is a plug-in for [Blacklight](https://github.com/projectblacklight/blacklight), an open source, Ruby on Rails Engine that provides a basic discovery interface for searching an Apache Solr index.

Read more about what Spotlight is, our motivations for creating it, and how to install and configure it in the [wiki pages](https://github.com/sul-dlss/spotlight/wiki). You might also want to take a look at our demo videos, especially the [tour of a completed Spotlight exhibit](https://www.youtube.com/watch?v=_A7vTbbiF4g) and the walkthrough of [building an exhibit with Spotlight](https://www.youtube.com/watch?v=qPJtgajJ4ic).

## Requirements

1. Ruby (2.0.0 or greater)
2. Rails (4.2.0 or greater)
3. Java (7 or greater) *for solr*
4. ImageMagick

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

Spotlight introduces functionality that depends on being able to send emails to exhibit curators and contacts. Be sure to configure your application's environments appropriately (See the Rails Guide for [Action Mailer Configuration](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration) ).

### More

See the [Spotlight wiki](https://github.com/sul-dlss/spotlight/wiki) for more detailed information on configuring Spotlight.

## To start the development/test application

 1. Clone this repo, `cd` in and run `$ bundle install`
 2. Start jetty and the dev server: `$ bundle exec rake spotlight:server` (this task will build a Spotlight-based application, start Solr, and run the built-in rails server)
 3. Visit [http://localhost:3000](http://localhost:3000)

## Tests

Run tests:

```
$ rake
```