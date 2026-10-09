# frozen_string_literal: true

RSpec.describe 'Display an item within the exhibit', type: :feature do
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

    it 'has an edit link' do
      visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')
      expect(page).to have_link('Edit')
    end
  end

  it 'displays the title and image viewer' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')
    expect(page).to have_css('h1', text: "L'AMERIQUE")
    expect(page).to have_css('.openseadragon-container')
  end
end
