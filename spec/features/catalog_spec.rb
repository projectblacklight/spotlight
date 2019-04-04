# frozen_string_literal: true

describe 'Catalog', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  describe 'admin' do
    let(:curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

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
      visit spotlight.search_exhibit_catalog_path(exhibit)
      expect(page).to have_selector '.panel-title', text: 'Item Visibility'
    end
  end

  it 'has breadcrumbs' do
    visit spotlight.search_exhibit_catalog_path(exhibit, q: 'xyz')
    expect(page).to have_breadcrumbs 'Home', 'Search Results'
  end

  describe 'Non-spotlight #show' do
    it 'is able to render without exhibit context' do
      visit solr_document_path('dq287tq6352')
      expect(page).to have_css 'h1', text: "L'AMERIQUE"
    end
  end

  describe 'viewing the page' do
    let(:exhibit) { FactoryBot.create(:exhibit) }
    it 'has <meta> tags' do
      TopHat.current['twitter_card'] = nil
      TopHat.current['opengraph'] = nil

      visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')

      expect(page).to have_css "meta[name='twitter:title']", visible: false
      expect(page).to have_css "meta[property='og:site_name']", visible: false
      expect(page).to have_css "meta[property='og:title']", visible: false
    end
  end
end
