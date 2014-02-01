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


group :test do
  gem 'simplecov', require: false
  gem 'coveralls', require: false
  gem 'devise'
  gem 'devise-guests'
  gem "bootstrap-sass"
  gem 'turbolinks'
  gem 'jquery-rails'
end

if File.exists?('spec/test_app_templates/Gemfile.extra')
  eval File.read('spec/test_app_templates/Gemfile.extra'), nil, 'spec/test_app_templates/Gemfile.extra'
end
