# frozen_string_literal: true

require 'spotlight/search_state'

RSpec.describe Spotlight::SearchState do
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:document) { SolrDocument.new(id: '123') }

  it 'is a Blacklight::SearchState' do
    controller = instance_double(Spotlight::CatalogController, current_exhibit: nil)
    expect(described_class.new({}, blacklight_config, controller)).to be_a Blacklight::SearchState
  end

  context 'without a current exhibit' do
    let(:controller) { instance_double(Spotlight::CatalogController, current_exhibit: nil) }

    it 'falls back to the default document route' do
      search_state = described_class.new({}, blacklight_config, controller)
      base_search_state = Blacklight::SearchState.new({}, blacklight_config, controller)

      expect(search_state.url_for_document(document)).to eq base_search_state.url_for_document(document)
    end
  end

  context 'with a current exhibit' do
    let(:exhibit) { instance_double(Spotlight::Exhibit) }
    let(:spotlight_engine) { :spotlight_engine }
    let(:controller) { double(Spotlight::CatalogController, current_exhibit: exhibit, spotlight: spotlight_engine) } # rubocop:disable RSpec/VerifiedDoubles

    it 'routes to the exhibit-scoped document path' do
      search_state = described_class.new({}, blacklight_config, controller)

      expect(search_state.url_for_document(document)).to eq [spotlight_engine, exhibit, document]
    end
  end
end
