# frozen_string_literal: true

describe 'Solr Documents Carousel Block', js: true, type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  let!(:feature_page) { FactoryBot.create(:feature_page, exhibit: exhibit) }

  before do
    login_as exhibit_curator

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'solr_documents_carousel'
  end

  it 'allows a curator to select a caption to display' do
    fill_in_typeahead_field with: 'dq287tq6352'

    check 'Primary caption'
    select 'Title', from: 'primary-caption-field'

    save_page_changes

    within '.carousel-block' do
      expect(page).to have_css('.carousel-item', count: 1)
      expect(page).to have_css('.carousel-caption .primary', text: "L'AMERIQUE")
    end
  end
end
