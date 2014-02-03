ENV["RAILS_ENV"] ||= 'test'

require 'devise'
require 'engine_cart'
EngineCart.load_application!

require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

require 'database_cleaner'
require 'factory_girl'

if ENV["COVERAGE"] or ENV["CI"]
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start
end

require 'spotlight'


Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

FactoryGirl.definition_file_paths = [File.expand_path("../factories", __FILE__)]
FactoryGirl.find_definitions


RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before :each do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :truncation
    end
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.include Warden::Test::Helpers, type: :feature
  config.include Controllers::EngineHelpers, type: :controller
  config.include Capybara::DSL
end
