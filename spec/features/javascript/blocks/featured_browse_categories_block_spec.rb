# frozen_string_literal: true

RSpec.describe 'Featured Browse Category Block', js: true, type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  let!(:feature_page) { FactoryBot.create(:feature_page, exhibit:) }
  let!(:search1) { FactoryBot.create(:published_search, exhibit:, title: 'Title1', published: true) }
  let!(:search2) { FactoryBot.create(:published_search, exhibit:, title: 'Title2', published: true) }

  before do
    login_as exhibit_curator

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'browse'
  end

  it 'allows a curator to select from existing browse categories' do
    check 'Include item counts?'

    fill_in_typeahead_field with: 'Title2'

    save_page_changes

    expect(page).to have_css('.category-title', text: search2.title)
    expect(page).to have_css('.item-count', text: /\d+ items/i)

    expect(page).to be_axe_clean.within '#content'
  end

  it 'toggles visibility of individual categories' do
    fill_in_typeahead_field with: 'Title1'

    within(:css, '.card') do
      uncheck 'Display?'
    end
    save_page_changes

    expect(page).to have_no_css('.category-title', text: search1.title)
  end

  it 'allows the curator to omit document counts' do
    uncheck 'Include item counts?'
    fill_in_typeahead_field with: 'Title1'
    save_page_changes

    expect(page).to have_no_css('.item-count', text: /\d+ items/i)
  end
end
