# frozen_string_literal: true

# adapted from https://www.fastruby.io/blog/testing/javascript/mocking-js-requests.html
#
# RSpec:
#
# Put this file in spec/support/interceptor.rb
#
# Require the file in your rails_helper.rb:
#
#     require_relative "support/interceptor"
#
# Include the module and add the callbacks in your RSpec config in rails_helper.rb
#
#     RSpec.configure do |config|
#       config.include(Interceptor, type: :system)
#       config.before(:each, type: :system) do
#         driven_by Capybara.javascript_driver # this is required because of https://github.com/rspec/rspec-rails/issues/2550
#         start_intercepting
#       end
#
#       config.after(:each, type: :system) do
#         stop_intercepting
#       end
#
#
# How to use:
#
# Call the `intercept` method in any system spec with a url, response and an http method (optional, defaults to "GET")
#
#     test "something" do
#       intercept("some_url.com", "fixed response")
#       visit root_url
#
#       # assert something that depends on the intercepted request
#     end
#
#
# - You can configure default interceptions that should apply to all tests by overriding the `default_interceptions` method
# - You can configure the allowed requests by overriding the `allowed_requests` method (defaults to any request to the Rails app)

module Interceptor
  # Add an interception hash for a given url, http method, and response
  # @url can be a regexp or a string
  # @method can be a string or a symbol, an can be uppercase or lowercase
  def intercept(url:, response: '', method: :any, code: '200', headers: {})
    @interceptions << { url: url, method: method, response: response, code: code, headers: headers }
  end

  # rubocop:disable Metrics
  def start_intercepting
    # ignore if the driver is RackTest
    return unless page.driver.browser.respond_to?(:intercept)

    # only attach the intercept callback once to the browser
    @interceptions = default_interceptions

    return if @intercepting

    page.driver.browser.intercept do |request, &continue|
      url = request.url
      method = request.method

      if (interception = response_for(url, method))
        # set mocked body if there's an interception for the url and method
        continue.call(request) do |_response|
          # binding.break if url.starts_with?('https://purl.stanford.edu')
          # response.body = interception[:response]
          # response.code = '200'
          Selenium::WebDriver::DevTools::Response.new(
            id: request.id,
            code: interception[:code],
            body: interception[:response],
            headers: interception[:headers]
          )
        end
      elsif allowed_request?(url, method)
        # leave request untouched if allowed
        continue.call(request)
      else
        # intercept any external request with an empty response and print some logs
        continue.call(request) do |response|
          log_request(url, method)
          response.body = ''
        end
      end
    end
    @intercepting = true
  end
  # rubocop:enable Metrics

  def stop_intercepting
    return unless @intercepting

    # remove the callback, cleanup
    clear_devtools_intercepts
    @intercepting = false
    # some requests may finish after the test is done if we let them go through untouched
    sleep(0.2)
  end

  # Override this method to define default interceptions that should apply to all tests
  # Each element of the array should be a hash with `url`, `response` and `method` key, like
  # the hash added by the `intercept` method
  #
  # For example:
  # - [{url: "https://external.api.com", response: ""}, {url: another_domain, response: fixed_response, method: :get}]
  def default_interceptions
    []
  end

  # Override this method to add more allowed requests that shouldn't be intercepted
  #
  # Elements of this array can be:
  # - a string
  # - a regexp
  # - a hash with `url` and `method` keys where:
  #   - url can be a string or a regexp
  #   - method can be `:any`, can be omitted (same as setting `:any`), or can be an
  #     http method as symbol or string and lowercase or uppercase
  #
  # For example, these are valid elements for the array:
  # - "https://allowed.domain.com"
  # - {url: "https://allowed.domain.com", method: "GET"} (or {url: /allowed\.domain\.com/, method: :get})
  # - {url: /allowed\.domain\.com/, method: :any} (or {url: /allowed\.domain\.com/} or /allowed\.domain\.com/)
  #
  # NOTE that you probably always want at least the Capybara.server_host url in this array
  def allowed_requests
    [%r{http://#{Capybara.server_host}},
     'https://code.jquery.com',
     'https://ga.jspm.io/',
     'https://cdnjs.cloudflare.com',
     'https://unpkg.com',
     'https://cdn.skypack.dev']
  end

  private

  # check if the given request url and http method pair is allowed by any rule
  def allowed_request?(url, method = 'GET')
    allowed_requests.any? do |allowed|
      allowed_url = allowed.is_a?(Hash) ? allowed[:url] : allowed
      matches_url = url.match?(allowed_url)

      allowed_method = allowed.is_a?(Hash) ? allowed[:method] : :any
      allowed_method ||= :any
      matches_method = allowed_method == :any || method == allowed_method.to_s.upcase

      matches_url && matches_method
    end
  end

  # find the interception hash for a given url and http method pair
  def response_for(url, method = 'GET')
    @interceptions.find do |interception|
      matches_url = url.match?(interception[:url])
      intercepted_method = interception[:method] || :any
      matches_method = intercepted_method == :any || method == intercepted_method.to_s.upcase

      matches_url && matches_method
    end
  end

  # clears the devtools callback for the interceptions
  def clear_devtools_intercepts
    callbacks = page.driver.browser.devtools.callbacks
    return unless callbacks.key?('Fetch.requestPaused')

    callbacks.delete('Fetch.requestPaused')
  end

  def log_request(url, method)
    message = "External JavaScript request not intercepted: #{method} #{url}"
    puts message
    Rails.logger.warn message
  end
end
