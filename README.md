spotlight
=========

[![Build Status](https://travis-ci.org/sul-dlss/spotlight.png?branch=master)](https://travis-ci.org/sul-dlss/spotlight) | [Release Notes](https://github.com/sul-dlss/spotlight/releases) | [Design Documents](https://github.com/sul-dlss/spotlight/releases/tag/v0.0.0)

Spotlight is intended to enable librarians, curators, and others who are responsible for digital collections to create attractive, feature-rich websites that feature these collections. The curator should be able to use Spotlight to produce a website that highlights a digital collection, drawn from a digital library repository, entirely on his or her own, without programming. The development and ongoing management of the website should be relatively simple and follow familiar conventions for producing online content (e.g., similar to writing and managing a blog or working with a content management system).

## Tests

Run tests:

```
$ rake
```

## Installation

Add this line to your application's Gemfile:

```
gem 'spotlight'
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
