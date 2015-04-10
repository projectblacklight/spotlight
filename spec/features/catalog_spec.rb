require 'spec_helper'

describe 'Catalog', type: :feature do
  describe 'admin' do
    let(:exhibit) { FactoryGirl.create(:exhibit) }
    let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

    before do
      login_as curator
      d = SolrDocument.new(id: 'dq287tq6352')
      d.make_private! exhibit
      d.reindex
      Blacklight.default_index.connection.commit
    end

    after do
      d = SolrDocument.new(id: 'dq287tq6352')
      d.make_public! exhibit
      d.reindex
      Blacklight.default_index.connection.commit
    end

    it "has a 'Item Visiblity' facet" do
      visit spotlight.exhibit_catalog_index_path(exhibit)
      expect(page).to have_selector '.panel-title', text: 'Item Visibility'
    end
  end
  describe 'Non-spotlight #show' do
    it 'is able to render without exhibit context' do
      visit catalog_path('dq287tq6352')
      expect(page).to have_css 'h1', text: "L'AMERIQUE"
    end
  end
end
