# frozen_string_literal: true

RSpec.describe 'Search within an exhibit', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  context 'when signed in as an exhibit curator' do
    let(:curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

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
      expect(page).to have_css '.facet-field-heading', text: 'Item visibility'
    end
  end

  context 'when an item has an exhibit tag' do
    let(:document) { SolrDocument.new(id: 'dq287tq6352') }

    before do
      exhibit.tag(document.sidecar(exhibit), with: ['zzexhibittag'], on: :tags)
      document.reindex
      Blacklight.default_index.connection.commit
    end

    after do
      exhibit.tag(document.sidecar(exhibit), with: [], on: :tags)
      document.reindex
      Blacklight.default_index.connection.commit
    end

    it 'finds the item by its tag' do
      visit spotlight.search_exhibit_catalog_path(exhibit, q: 'zzexhibittag')
      expect(page).to have_text "L'AMERIQUE"
    end
  end
end
