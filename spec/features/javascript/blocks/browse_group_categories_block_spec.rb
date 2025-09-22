# frozen_string_literal: true

RSpec.describe 'Browse Group Categories', :js, type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }

  let(:feature_page) { FactoryBot.create(:feature_page, exhibit:) }
  let(:search1) { FactoryBot.create(:published_search, exhibit:, title: 'All of the good dogs') }
  let(:search2) { FactoryBot.create(:published_search, exhibit:, title: 'All of the good cats') }
  let(:search3) { FactoryBot.create(:published_search, exhibit:, title: 'All of the good birds') }
  let(:search4) { FactoryBot.create(:published_search, exhibit:, title: 'All of the good pigs') }
  let(:search5) { FactoryBot.create(:published_search, exhibit:, title: 'All of the good tigers') }
  let(:search6) { FactoryBot.create(:published_search, exhibit:, title: 'All of the good ferrets') }
  let(:search7) { FactoryBot.create(:search, exhibit:, title: 'All of the good turtles') }
  let!(:group) { FactoryBot.create(:group, exhibit:, searches: [search1, search2, search3, search4, search5, search6], title: 'Pets', published: true) }
  let!(:group2) { FactoryBot.create(:group, exhibit:, searches: [search1, search2], title: 'Good animals', published: true) }

  before do
    login_as exhibit_curator

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'browse_group_categories'
  end

  it 'allows a curator to select a caption to display' do
    fill_in_typeahead_field with: 'Pets'
    within '.dd-list' do
      expect(page).to have_css '.title', text: 'Pets'
    end

    save_page_changes

    expect(page).to have_css 'h2', text: 'Pets'
  end

  it 'can navigate using arrows' do
    fill_in_typeahead_field with: 'Pets'
    within '.dd-list' do
      expect(page).to have_css '.title', text: 'Pets'
    end

    save_page_changes

    expect(page).to have_css 'h2', text: 'Pets'

    expect(page).to have_css '.category-title', text: 'All of the good dogs'
    expect(page).to have_no_css '.category-title', text: 'All of the good tigers'
    find('[data-controls="next"]').click
    expect(page).to have_no_css '.category-title', text: 'All of the good dogs'
    expect(page).to have_css '.category-title', text: 'All of the good tigers'
  end

  it 'only published searches are displayed' do
    fill_in_typeahead_field with: 'Pets'
    within '.dd-list' do
      expect(page).to have_css '.title', text: 'Pets'
    end

    save_page_changes

    expect(page).to have_css 'h2', text: 'Pets'
    expect(page).to have_css '.box.category-1', count: 6, visible: false
  end

  it 'is accessible' do
    pending 'focusable hidden content fix, see https://github.com/projectblacklight/spotlight/issues/3578'
    fill_in_typeahead_field with: 'Pets'
    save_page_changes
    expect(page).to have_css 'h2', text: 'Pets'
    expect(page).to be_axe_clean.within '#content'
  end
end
