spotlight
=========

[![Build Status](https://travis-ci.org/sul-dlss/spotlight.png?branch=master)](https://travis-ci.org/sul-dlss/spotlight) | [![Coverage Status](https://coveralls.io/repos/sul-dlss/spotlight/badge.png?branch=master)](https://coveralls.io/r/sul-dlss/spotlight) | [![Gem Version](https://badge.fury.io/rb/blacklight-spotlight.png)](http://badge.fury.io/rb/blacklight-spotlight) | [Release Notes](https://github.com/sul-dlss/spotlight/releases) | [Design Documents](https://github.com/sul-dlss/spotlight/releases/tag/v0.0.0)

Spotlight is open source software that sits on top of a digital repository and enables librarians, curators, and other content experts to easily build feature-rich websites that showcase collections and objects from that repository. Spotlight is a plug-in for [Blacklight](https://github.com/projectblacklight/blacklight), an open source, Ruby on Rails Engine that provides a basic discovery interface for searching an Apache Solr index.

Read more about what Spotlight is, our motivations for creating it, and how to install and configure it in the [wiki pages](https://github.com/sul-dlss/spotlight/wiki). You might also want to take a look at our demo videos, especially the [tour of a completed Spotlight exhibit](https://www.youtube.com/watch?v=_A7vTbbiF4g) and the walkthrough of [building an exhibit with Spotlight](https://www.youtube.com/watch?v=qPJtgajJ4ic).

## Tests

Run tests:

```
$ rake
```

## Installation

To bootstrap a new Rails application:

```
$ rails new app-name -m https://raw.githubusercontent.com/sul-dlss/spotlight/master/template.rb
```

or

```
$ rake rails:template LOCATION=https://raw.githubusercontent.com/sul-dlss/spotlight/master/template.rb
```

Or do it manually:

Add these lines to your application's Gemfile:

```
gem 'blacklight'
gem 'blacklight-spotlight'
```

And then execute:

```
$ bundle install
```

Then install Blacklight:

```
$ rails generate blacklight:install
```

Then install Spotlight:

```
$ rails generate spotlight:install
$ rake spotlight:install:migrations
$ rake db:migrate
```

Create an initial administrator:

```
$ rake spotlight:initialize
```

If you installed jettywrapper with Blacklight (above), install Spotlight's demo solr configuration and catalog controller configuration:

```
$ rake jetty:configure_solr
```

## Configuration

### Blacklight configuration

Spotlight uses your application's Blacklight configuration to provide default values for an exhibit. The Blacklight configuration options are documented on the [Blacklight wiki](https://github.com/projectblacklight/blacklight/wiki#blacklight-configuration).

### Default ActionMailer configuration

Spotlight introduces functionality that depends on being able to send emails to exhibit curators and contacts. Be sure to configure your application's environments appropriately (See the Rails Guide for [Action Mailer Configuration](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration) ).

### Solr Indexing

Spotlight needs the ability to write exhibit-specific content to your Solr index. The default indexing strategy uses [Atomic Updates](https://cwiki.apache.org/confluence/display/solr/Updating+Parts+of+Documents), introduced in Solr 4.x. Note the [caveats, limitations and required configuration](https://wiki.apache.org/solr/Atomic_Updates#Caveats_and_Limitations) necessary to use this feature. The rake task `spotlight:check:solr` will test if your Solr configuration is suitable for Atomic Updates.

If you are unable to use the Atomic Update strategy, your `SolrDocument` class must implement a `#reindex` method that can update the document in Solr with the exhibit-specific data provided by `#to_solr`.

## To start the development/test application

 1. Clone this repo, `cd` in and run `$ bundle install`
 2. Start jetty and the dev server: `$ bundle exec rake spotlight:server` (this task will build a Spotlight-based application, start Solr, and run the built-in rails server)
 3. Visit [http://localhost:3000](http://localhost:3000)
