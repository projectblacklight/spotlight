[![Build Status](https://travis-ci.org/sul-dlss/spotlight-resources-iiif.svg?branch=master)](https://travis-ci.org/sul-dlss/spotlight-resources-iiif) [![Coverage Status](https://coveralls.io/repos/sul-dlss/spotlight-resources-iiif/badge.svg?branch=master&service=github)](https://coveralls.io/github/sul-dlss/spotlight-resources-iiif?branch=master) [![Dependency Status](https://gemnasium.com/sul-dlss/spotlight-resources-iiif.svg)](https://gemnasium.com/sul-dlss/spotlight-resources-iiif) [![Gem Version](https://badge.fury.io/rb/spotlight-resources-iiif.png)](http://badge.fury.io/rb/spotlight-resources-iiif)

# Spotlight::Resources::Iiif

Spotlight Resource Indexer for IIIF manifests or collections.  A Rails engine gem for use in the blacklight-spotlight Rails engine gem.

## Installation

Add this line to your blacklight-spotlight Rails application's Gemfile:

```ruby
gem 'spotlight-resources-iiif'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spotlight-resources-iiif

## Usage

This is a Rails engine gem to be used along with blacklight-spotlight, another Rails engine gem used to build exhibits sites while leveraging the blacklight Rails engine gem.

This gem adds a new "Repository Item" form to your Spotlight application. This form allows curators to input one or more URLs to a IIIF Manifest or collection, and the contents of the feed will be harvested as new items in the Spotlight exhibit.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sul-dlss/spotlight-resources-iiif.

## Contributing

1. Fork it (https://help.github.com/articles/fork-a-repo/)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request (https://help.github.com/articles/using-pull-requests/)


