ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'

require 'engine_cart'
EngineCart.load_application!

require 'rspec/rails'

require 'factory_girl_rails'
FactoryGirl.definition_file_paths ||= []
FactoryGirl.definition_file_paths << "#{Gem.loaded_specs['blacklight-spotlight'].full_gem_path}/spec/factories"
FactoryGirl.find_definitions

require 'database_cleaner'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.before :each do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction # non-js tests
    else
      DatabaseCleaner.strategy = :truncation # js tests
    end
    DatabaseCleaner.start

    # The first user is automatically granted admin privileges; we don't want that behavior for many of our tests
    User.create email: 'initial+admin@example.com', password: 'password', password_confirmation: 'password'
  end

  config.after { DatabaseCleaner.clean }
  config.include Warden::Test::Helpers, type: :feature # use login_as helper
end
