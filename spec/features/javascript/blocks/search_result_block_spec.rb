# frozen_string_literal: true

describe 'Search Result Block', type: :feature, js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  let!(:feature_page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
  let!(:alt_search) { FactoryBot.create(:search, title: 'Alt. Search', exhibit: exhibit) }

  before do
    login_as exhibit_curator

    exhibit.searches.each { |x| x.update published: true }

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'search_results'
  end

  pending 'allows a curator to select from existing browse categories' do
    pending('Prefetched autocomplete does not work the same way as solr-backed autocompletes')
    fill_in_typeahead_field with: 'All Exhibit Items'

    check 'Gallery'
    check 'Slideshow'

    save_page

    expect(page).not_to have_content 'per page'
    expect(page).not_to have_content 'Sort by'

    # The two configured view types should be
    # present and the one not selected should not be
    within('.view-type-group') do
      expect(page).not_to have_css('.view-type-list')
      expect(page).to have_css('.view-type-gallery')
      expect(page).to have_css('.view-type-slideshow')
    end

    # Documents should exist
    expect(page).to have_css('.documents .document')
  end
end
