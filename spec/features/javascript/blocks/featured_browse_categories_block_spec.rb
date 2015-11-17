require 'spec_helper'

describe 'Featured Browse Category Block', type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }

  let!(:feature_page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
  let!(:search1) { FactoryGirl.create(:published_search, exhibit: exhibit, title: 'Title1', published: true) }
  let!(:search2) { FactoryGirl.create(:published_search, exhibit: exhibit, title: 'Title2', published: true) }

  before do
    login_as exhibit_curator

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'browse'
  end

  it 'allows a curator to select from existing browse categories' do
    check 'Include item counts?'

    fill_in_typeahead_field with: 'Title1'

    within(:css, '.panel') do
      uncheck 'Display?'
    end

    fill_in_typeahead_field with: 'Title2'

    save_page

    # Documents should exist
    expect(page).not_to have_css('.category-title', text: search1.title)
    expect(page).to have_css('.category-title', text: search2.title)
    expect(page).to have_css('.item-count', text: /\d+ items/i)
  end
end
