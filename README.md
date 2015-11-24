[![Build Status](https://travis-ci.org/sul-dlss/spotlight-iiif-resources.svg?branch=master)](https://travis-ci.org/sul-dlss/spotlight-iiif-resources) [![Coverage Status](https://coveralls.io/repos/sul-dlss/spotlight-iiif-resources/badge.svg?branch=master&service=github)](https://coveralls.io/github/sul-dlss/spotlight-iiif-resources?branch=master) [![Dependency Status](https://gemnasium.com/sul-dlss/spotlight-iiif-resources.svg)](https://gemnasium.com/sul-dlss/spotlight-iiif-resources) [![Gem Version](https://badge.fury.io/rb/spotlight-iiif-resources.png)](http://badge.fury.io/rb/spotlight-iiif-resources)

# Spotlight::Iiif::Resources

Spotlight Resource Indexer for IIIF manifests or collections.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spotlight-iiif-resources'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spotlight-iiif-resources

## Usage

This gem adds a new "Repository Item" form to your Spotlight application. This form allows curators to input one or more URLs to a IIIF Manifest or collection, and the contents of the feed will be harvested as new items in the Spotlight exhibit.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sul-dlss/spotlight-iiif-resources.

## Contributing

1. Fork it (https://help.github.com/articles/fork-a-repo/)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request (https://help.github.com/articles/using-pull-requests/)


