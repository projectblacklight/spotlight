ENV['RAILS_ENV'] ||= 'test'
require 'factory_girl'
require 'database_cleaner'
require 'devise'
require 'engine_cart'
EngineCart.load_application!

Internal::Application.config.active_job.queue_adapter = :inline

require 'rails-controller-testing' if Rails::VERSION::MAJOR >= 5
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
  config.filter_rails_from_backtrace!

  config.use_transactional_fixtures = false

  config.before :each do
    DatabaseCleaner.strategy = if Capybara.current_driver == :rack_test
                                 :transaction
                               else
                                 :truncation
                               end
    DatabaseCleaner.start

    # The first user is automatically granted admin privileges; we don't want that behavior for many of our tests
    Spotlight::Engine.user_class.create email: 'initial+admin@example.com', password: 'password', password_confirmation: 'password'
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.filter_run_excluding js: true if ENV['CI']

  if defined? Devise::Test::ControllerHelpers
    config.include Devise::Test::ControllerHelpers, type: :controller
    config.include Devise::Test::ControllerHelpers, type: :view
  else
    config.include Devise::TestHelpers, type: :controller
    config.include Devise::TestHelpers, type: :view
  end

  config.include Spotlight::TestViewHelpers, type: :view
  config.include Warden::Test::Helpers, type: :feature

  config.include(ControllerLevelHelpers, type: :helper)
  config.before(:each, type: :helper) { initialize_controller_helpers(helper) }

  config.include(ControllerLevelHelpers, type: :view)
  config.before(:each, type: :view) { initialize_controller_helpers(view) }

  config.after(:each, type: :feature) { Warden.test_reset! }
  config.include Controllers::EngineHelpers, type: :controller
  config.include Capybara::DSL
  if Rails::VERSION::MAJOR >= 5
    config.include ::Rails.application.routes.url_helpers
    config.include ::Rails.application.routes.mounted_helpers
  else
    config.include BackportTestHelpers, type: :controller
  end
  config.include Spotlight::TestFeaturesHelpers, type: :feature

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  config.example_status_persistence_file_path = 'spec/examples.txt'
  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  # config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
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
