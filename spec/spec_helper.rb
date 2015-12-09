ENV['RAILS_ENV'] ||= 'test'

require 'factory_girl'
require 'database_cleaner'
require 'devise'
require 'engine_cart'
EngineCart.load_application!

require 'rspec/collection_matchers'
require 'rspec/its'
require 'rspec/rails'
require 'rspec/active_model/mocks'

require 'capybara/poltergeist'

if ENV['POLTERGEIST_DEBUG']
  Capybara.register_driver :poltergeist_debug do |app|
    Capybara::Poltergeist::Driver.new(app, inspector: true, phantomjs_options: ['--load-images=no'])
  end
  Capybara.javascript_driver = :poltergeist_debug
else
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--load-images=no'])
  end
  Capybara.javascript_driver = :poltergeist
end
Capybara.default_max_wait_time = 10

if ENV['COVERAGE'] || ENV['CI']
  require 'simplecov'
  require 'coveralls' if ENV['CI']

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter if ENV['CI']
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'spotlight'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

FactoryGirl.definition_file_paths = [File.expand_path('../factories', __FILE__)]
FactoryGirl.find_definitions

FIXTURES_PATH = File.expand_path('../fixtures', __FILE__)

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.use_transactional_fixtures = false

  config.before :each do
    if Capybara.current_driver == :rack_test
      DatabaseCleaner.strategy = :transaction
    else
      DatabaseCleaner.strategy = :truncation
    end
    DatabaseCleaner.start

    # The first user is automatically granted admin privileges; we don't want that behavior for many of our tests
    Spotlight::Engine.user_class.create email: 'initial+admin@example.com', password: 'password', password_confirmation: 'password'
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.filter_run_excluding js: true if ENV['CI']

  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.include Spotlight::TestViewHelpers, type: :view
  config.include Warden::Test::Helpers, type: :feature
  config.after(:each, type: :feature) { Warden.test_reset! }
  config.include Controllers::EngineHelpers, type: :controller
  config.include Capybara::DSL
  config.include Spotlight::TestFeaturesHelpers, type: :feature
end

def add_new_page_via_button(title = 'New Page')
  add_link = find('[data-expanded-add-button]')
  within(add_link) do
    expect(page).to have_css("input[type='text']", visible: false)
  end
  add_link.hover
  within(add_link) do
    input = find("input[type='text']", visible: true)
    input.set(title)
    find("input[data-behavior='save']").click
  end
end
