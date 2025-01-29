# frozen_string_literal: true

RSpec.describe Spotlight::BrowseCategorySearchBuilder do
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

  context 'with a facet as the basis of the browse category (no search query present)' do
    let(:search) { FactoryBot.create(:search, exhibit:, query_params: { sort: 'type', f: { genre_ssim: ['genre facet'] } }) }

    describe 'constructs params properly' do
      it 'adds facet to the solr params' do
        params = subject.to_hash.with_indifferent_access

        expect(params).to include(
          fq: ['{!term f=genre_ssim}genre facet'],
          sort: 'sort_type_ssi asc'
        )
      end

      it 'does not override the default query parser' do
        params = subject.to_hash.with_indifferent_access
        expect(params).not_to include(:defType)
      end
    end
  end

  context 'with a search query as part of the construction of the browse category' do
    let(:search) { FactoryBot.create(:search, exhibit:, query_params: { sort: 'type', f: { genre_ssim: ['term'] }, q: 'search query' }) }

    describe 'constructs params properly' do
      it 'includes the facet and the seach term information in the params' do
        params = subject.to_hash.with_indifferent_access

        expect(params).to include(
          q: 'search query',
          fq: ['{!term f=genre_ssim}term'],
          sort: 'sort_type_ssi asc'
        )
      end

      context 'with a search term present' do
        let(:blacklight_params) { { browse_category_id: search.id, q: 'cats' } }

        it 'manipulates the solr query as expected into json syntax' do
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

        it 'overrides the default query parser' do
          params = subject.to_hash.with_indifferent_access
          expect(params).to include(defType: 'lucene')
        end
      end
    end
  end
end
