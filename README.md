spotlight
=========

[![Build Status](https://travis-ci.org/sul-dlss/spotlight.png?branch=master)](https://travis-ci.org/sul-dlss/spotlight) | [![Coverage Status](https://coveralls.io/repos/sul-dlss/spotlight/badge.png?branch=master)](https://coveralls.io/r/sul-dlss/spotlight) | [![Gem Version](https://badge.fury.io/rb/blacklight-spotlight.png)](http://badge.fury.io/rb/blacklight-spotlight) | [Release Notes](https://github.com/sul-dlss/spotlight/releases) | [Design Documents](https://github.com/sul-dlss/spotlight/releases/tag/v0.0.0)

Spotlight is intended to enable librarians, curators, and others who are responsible for digital collections to create attractive, feature-rich websites that feature these collections. The curator should be able to use Spotlight to produce a website that highlights a digital collection, drawn from a digital library repository, entirely on his or her own, without programming. The development and ongoing management of the website should be relatively simple and follow familiar conventions for producing online content (e.g., similar to writing and managing a blog or working with a content management system).

### Demo Videos
* [Sprint 9](https://www.youtube.com/watch?v=ALVwecIw5Rw)
* [Sprint 8](https://www.youtube.com/watch?v=l25_TWTV1uE)
* [Sprint 7](https://www.youtube.com/watch?v=qTv33JqUoH8)
* [Sprint 6](https://www.youtube.com/watch?v=HxQ6khYqezU)
* [Sprint 5](https://www.youtube.com/watch?v=pnpqiIDXHHw)
* [Sprint 4](https://www.youtube.com/watch?v=4S0iRzvdk5M)
* [Sprint 3](https://www.youtube.com/watch?v=XEOsMRY_3mY)
* [Sprint 2](https://www.youtube.com/watch?v=8BqWSEmOK3g)
* [Sprint 1](https://www.youtube.com/watch?v=LAoTIdP2Gsk)

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

Add this line to your application's Gemfile:

```
gem 'blacklight-spotlight'
```

And then execute:

```
$ bundle
```

Then run:

```
$ rails g spotlight:install
```

Create an administrator
```
$ rake spotlight:initialize
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
