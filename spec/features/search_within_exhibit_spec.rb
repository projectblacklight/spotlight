# frozen_string_literal: true

RSpec.describe 'Search within an exhibit', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  context 'when signed in as an exhibit curator' do
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
      expect(page).to have_selector '.card-header', text: 'Item visibility'
    end
  end

  it 'has breadcrumbs' do
    visit spotlight.search_exhibit_catalog_path(exhibit, q: 'xyz')
    expect(page).to have_breadcrumbs 'Home', 'Search results'
    expect(page).to have_selector '.breadcrumb-item.active', text: 'Search results'
  end
end
