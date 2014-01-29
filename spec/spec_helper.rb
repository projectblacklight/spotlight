ENV["RAILS_ENV"] ||= 'test'

require 'devise'
require 'engine_cart'
EngineCart.load_application!

require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/poltergeist'
require 'spotlight'

Capybara.javascript_driver = :poltergeist

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

FactoryGirl.definition_file_paths = [File.expand_path("../factories", __FILE__)]
FactoryGirl.find_definitions


RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include Devise::TestHelpers, type: :controller
  config.include Controllers::EngineHelpers, type: :controller
end
