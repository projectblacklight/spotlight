require 'spec_helper'

module Spotlight
  describe 'spotlight/search_configurations/_facet_metadata', type: :view do
    before do
      render partial: 'spotlight/search_configurations/facet_metadata', locals: { metadata: metadata }
    end

    context 'with a facet without any documents' do
      let(:metadata) { { document_count: 0 } }

      it 'shows there are no documents' do
        expect(rendered).to have_content '0 items'
      end
    end

    context 'with a facet with a small number of values' do
      let(:metadata) { { document_count: 1, value_count: 3, terms: %w(a b c) } }

      it 'shows the number of unique values' do
        expect(rendered).to have_content '1 item'
        expect(rendered).to have_content '3 unique values'
        expect(rendered).to have_selector '.btn-with-tooltip'
      end
    end

    context 'with a facet with a large number of values' do
      let(:metadata) { { document_count: 1, value_count: 21, terms: %w() } }

      it 'shows there are many unique values' do
        expect(rendered).to have_content '20+ unique values'
      end
    end
  end
end
