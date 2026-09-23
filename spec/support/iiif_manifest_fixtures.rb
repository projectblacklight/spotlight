# frozen_string_literal: true

# JavaScript feature specs load IIIF manifests from the browser, which WebMock
# can't intercept. Serve fixture manifests from the Capybara app server instead
# so specs don't depend on network access to external IIIF servers.
module IiifManifestFixtures
  PATH = '/iiif_manifest_fixtures'
  DIR = File.expand_path('../fixtures/iiif_manifests', __dir__)

  # Point the autocomplete responses for documents at their fixture manifests
  # (spec/fixtures/iiif_manifests/<document_id>.json). The controller instance
  # is created by the app server, so it can only be reached with any_instance.
  def stub_iiif_manifest_for(*document_ids)
    allow_any_instance_of(Spotlight::CatalogController).to( # rubocop:disable RSpec/AnyInstance
      receive(:autocomplete_json_response_for_document).and_wrap_original do |original, doc|
        response = original.call(doc)
        response[:iiif_manifest] = "#{PATH}/#{doc.id}.json" if response[:iiif_manifest] && document_ids.include?(doc.id)
        response
      end
    )
  end
end

app = Capybara.app
Capybara.app = Rack::Builder.new do
  map(IiifManifestFixtures::PATH) { run Rack::Files.new(IiifManifestFixtures::DIR) }
  run app
end

RSpec.configure do |config|
  config.include IiifManifestFixtures, type: :feature
end
