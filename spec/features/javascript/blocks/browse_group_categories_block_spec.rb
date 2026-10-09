# frozen_string_literal: true

RSpec.describe 'Browse Group Categories', :js, type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  let(:feature_page) { FactoryBot.create(:feature_page, exhibit:) }
  let(:search1) { FactoryBot.create(:published_search, exhibit:, title: 'All of the good dogs') }
  let(:search2) { FactoryBot.create(:published_search, exhibit:, title: 'All of the good cats') }
  let(:search3) { FactoryBot.create(:search, exhibit:, title: 'All of the good turtles') }
  let!(:group) { FactoryBot.create(:group, exhibit:, searches: [search1, search2, search3], title: 'Pets', published: true) }

  before do
    login_as exhibit_curator

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'browse_group_categories'
  end

  it 'allows a curator to select a browse group to display' do
    fill_in_typeahead_field with: 'Pets'
    within '.dd-list' do
      expect(page).to have_css '.title', text: 'Pets'
    end
    check 'display-item-counts'

    save_page_changes

    expect(page).to have_css 'h2', text: 'Pets'
    expect(page).to have_css '.category-title', text: 'All of the good dogs', visible: true
    expect(page).to have_css '.category-title', text: 'All of the good cats', visible: true
    expect(page).to have_no_css '.category-title', text: 'All of the good turtles', visible: false
    expect(page).to have_css '.item-count', count: 2

    expect(page).to be_axe_clean.within '#content'
  end
end
