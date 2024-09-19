# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'factory_bot'
require 'devise'
require 'engine_cart'
EngineCart.load_application!

ActiveJob::Base.queue_adapter = :test

require 'rails-controller-testing'
require 'rspec/collection_matchers'
require 'rspec/its'
require 'rspec/rails'
require 'rspec/active_model/mocks'
require 'paper_trail/frameworks/rspec'

require 'selenium-webdriver'
require 'webmock/rspec'

Capybara.register_driver :selenium_chrome_headless do |app|
  browser_options = Selenium::WebDriver::Chrome::Options.new
  browser_options.add_argument('--window-size=1920,1080')
  browser_options.add_argument('--headless')
  browser_options.binary = ENV['CHROME_BIN'] if ENV['CHROME_BIN']
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.javascript_driver = :selenium_chrome_headless

allowed_sites = ['chromedriver.storage.googleapis.com']

WebMock.disable_net_connect!(net_http_connect_on_start: true, allow_localhost: true, allow: allowed_sites)

if ENV['COVERAGE'] || ENV['CI']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'spotlight'

# configure spotlight with all the settings necessary to test functionality
Spotlight::Engine.config.reindexing_batch_count = 1
Spotlight::Engine.config.assign_default_roles_to_first_user = false

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

FactoryBot.definition_file_paths = [File.expand_path('factories', __dir__)]
FactoryBot.find_definitions

FIXTURES_PATH = File.expand_path('fixtures', __dir__)

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.use_transactional_fixtures = true

  config.include ViewComponent::TestHelpers, type: :component

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
  config.include Rails.application.routes.url_helpers
  config.include Rails.application.routes.mounted_helpers
  config.include Spotlight::TestFeaturesHelpers, type: :feature
  config.include CapybaraDefaultMaxWaitMetadataHelper, type: :feature

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

def add_new_via_button(title = 'New Page')
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
