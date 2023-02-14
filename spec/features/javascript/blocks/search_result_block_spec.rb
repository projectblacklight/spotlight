# frozen_string_literal: true

describe 'Search Result Block', js: true, type: :feature do
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

  it 'allows a curator to select from existing browse categories' do
    # Manually inject the inputs to the widget that the autocomplete would.
    # fill_in_typeahead_field does not work here for us for some reason.
    page.execute_script <<-JS
      $("[data-twitter-typeahead]:visible").after(
        "<input type='hidden' name='item[item_0][id]' value='all-exhibit-items' />" +
        "<input type='hidden' name='item[item_0][display]' value='true' />"
      );
    JS

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
    expect(page).to have_css('.documents-gallery .document')
  end
end
