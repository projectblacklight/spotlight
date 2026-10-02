# frozen_string_literal: true

RSpec.describe Spotlight::SearchHelper do
  # Spotlight::Search includes SearchHelper and provides a model-context includer with
  # its own search_state method, making it a convenient vehicle for testing the concern.
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:query_params) { { 'q' => 'cats' } }
  let(:search) { exhibit.searches.build(title: 'Test', query_params:) }
  let(:blacklight_config) { exhibit.blacklight_config }

  describe '#search_service' do
    let(:service) { search.search_service }

    it 'returns an instance of the search service' do
      expect(service).to be_a(Blacklight::SearchService)
    end

    it 'builds the service with a Blacklight::SearchState derived from context' do
      expect(service.send(:search_state)).to be_a(Blacklight::SearchState)
      expect(service.send(:search_state).to_h).to include('q' => 'cats')
    end

    context 'when given an explicit Blacklight::SearchState' do
      let(:explicit_state) { Blacklight::SearchState.new({ 'q' => 'dogs' }, blacklight_config) }
      let(:service) { search.search_service(explicit_state) }

      it 'passes it through to the service unchanged' do
        expect(service.send(:search_state)).to be explicit_state
      end
    end
  end
end
