# frozen_string_literal: true

describe Spotlight::BrowseCategorySearchBuilder do
  class BrowseCategoryMockSearchBuilder < Blacklight::SearchBuilder
    include Blacklight::Solr::SearchBuilderBehavior
    include Spotlight::BrowseCategorySearchBuilder
  end

  subject { BrowseCategoryMockSearchBuilder.new(scope).with(blacklight_params) }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:scope) do
    double(blacklight_config: exhibit.blacklight_config, current_exhibit: exhibit, search_state_class: nil)
  end
  let(:solr_request) { Blacklight::Solr::Request.new }
  let(:blacklight_params) { { browse_category_id: search.id } }
  let(:search) { FactoryBot.create(:search, exhibit: exhibit, query_params: { sort: 'type', f: { genre_ssim: ['term'] }, q: 'search query' }) }

  describe '#restrict_to_browse_category' do
    it 'adds the search query parameters from the browse category' do
      params = subject.to_hash.with_indifferent_access

      expect(params).to include(
        q: 'search query',
        fq: ['{!term f=genre_ssim}term'],
        sort: 'sort_type_ssi asc'
      )
    end

    context 'with a user-provided query' do
      let(:blacklight_params) { { browse_category_id: search.id, q: 'cats' } }

      it 'uses the user-provided query to further restrict the search' do
        params = subject.to_hash.with_indifferent_access
        expect(params).not_to include(:q)
        expect(params).to include(
          json: {
            query: {
              bool: {
                must: [
                  { edismax: { query: 'search query' } },
                  { edismax: { query: 'cats' } }
                ]
              }
            }
          }
        )
      end
    end
  end
end
