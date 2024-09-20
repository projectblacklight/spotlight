# frozen_string_literal: true

describe 'Solr Documents Embed Block', js: true, type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  let!(:feature_page) { FactoryBot.create(:feature_page, exhibit: exhibit) }

  before do
    login_as exhibit_curator

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'solr_documents_embed'
  end

  it 'allows you to add a solr documents embed block widget', js: true do
    fill_in_solr_document_block_typeahead_field with: 'dq287tq6352'

    save_page_changes

    expect(page).to have_css('.openseadragon-container')
    expect(page).to have_css('picture')
    within('picture') do
      expect(html).to have_css('source[media="openseadragon"][src="https://stacks.stanford.edu/image/iiif/dq287tq6352%2Fdq287tq6352_05_0001/info.json"]')
    end
  end
end