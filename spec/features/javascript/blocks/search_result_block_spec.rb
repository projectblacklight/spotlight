# frozen_string_literal: true

RSpec.describe 'Search Result Block', js: true, type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  let!(:feature_page) { FactoryBot.create(:feature_page, exhibit:) }
  let!(:alt_search) { FactoryBot.create(:search, title: 'Alt. Search', exhibit:) }

  before do
    login_as exhibit_curator

    exhibit.searches.each { |x| x.update published: true }
    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'search_results'
  end

  it 'allows a curator to select from existing browse categories' do
    fill_in_typeahead_field(with: 'All exhibit items')
    check 'Gallery'
    check 'Slideshow'

    save_page_changes

    expect(page).to have_no_content 'per page'
    expect(page).to have_no_content 'Sort by'

    # The two configured view types should be
    # present and the one not selected should not be
    within('.view-type-group') do
      expect(page).to have_no_css('.view-type-list')
      expect(page).to have_css('.view-type-gallery')
      expect(page).to have_css('.view-type-slideshow')
    end

    # Documents should exist
    expect(page).to have_css('.documents-gallery .document')

    expect(page).to be_axe_clean.within '#content'
  end
end
