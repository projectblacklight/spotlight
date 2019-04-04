# frozen_string_literal: true

require 'fixtures/iiif_responses'
module StubIiifResponse
  def stub_iiif_response_for_url(url, response)
    allow(Spotlight::Resources::IiifService).to receive(:iiif_response).with(url).and_return(response)
  end

  def stub_default_collection
    allow_any_instance_of(Spotlight::Resources::IiifHarvester).to receive_messages(url_is_iiif?: true)
    stub_iiif_response_for_url('uri://for-top-level-collection', complex_collection)
    stub_iiif_response_for_url('uri://for-child-collection1', child_collection1)
    stub_iiif_response_for_url('uri://for-child-collection2', child_collection2)
    stub_iiif_response_for_url('uri://for-child-collection3', child_collection3)

    stub_iiif_response_for_url('uri://for-manifest1', test_manifest1)
    stub_iiif_response_for_url('uri://for-manifest2', test_manifest2)
    stub_iiif_response_for_url('uri://for-manifest3', test_manifest3)
    stub_iiif_response_for_url('uri://for-manifest4', test_manifest4)
  end
end

RSpec.configure do |config|
  config.include IiifResponses
  config.include StubIiifResponse
end
