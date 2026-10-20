# frozen_string_literal: true

# Avoid real DNS lookups when SsrfFilter checks IIIF URLs. Hostnames resolve to
# an arbitrary public address (WebMock intercepts the request, so nothing
# connects to it); IP literals resolve to themselves.
RSpec.configure do |config|
  config.before do
    stub_const('SsrfFilter::DEFAULT_RESOLVER', lambda do |host|
      [IPAddr.new(host.match?(Resolv::AddressRegex) ? host : '1.1.1.1')]
    end)
  end
end
