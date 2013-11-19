require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/poltergeist'
require 'spotlight'
require 'engine_cart'

EngineCart.load_application!

Capybara.javascript_driver = :poltergeist

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

RSpec.configure do |config|

end