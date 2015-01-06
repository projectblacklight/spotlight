source "https://rubygems.org"

# Declare your gem's dependencies in spotlight.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'
#
gem 'blacklight-gallery', '>= 0.1.1'
gem 'sir-trevor-rails', github: 'sul-dlss/sir-trevor-rails'

group :test do
  # Peg simplecov to < 0.8 until this is resolved:
  # https://github.com/colszowka/simplecov/issues/281
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'coveralls', require: false
end

group :development, :test do
  gem 'byebug'
end

file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
if File.exists?(file)
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
else
  gem 'rails', ENV['RAILS_VERSION']

  # explicitly include sass-rails to get compatible sprocket dependencies
  if ENV['RAILS_VERSION'] and ENV['RAILS_VERSION'] =~ /^4.2/
    gem 'coffee-rails', '~> 4.1.0'
    gem 'sass-rails', '~> 5.0'
    gem 'responders', "~> 2.0"
  else
    gem 'sass-rails', "< 5.0"
    gem 'coffee-rails', "~> 4.0.0"
  end
end
