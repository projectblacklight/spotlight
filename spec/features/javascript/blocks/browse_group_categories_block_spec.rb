# frozen_string_literal: true

describe 'Browse Group Categories', type: :feature, js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }

  let(:feature_page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
  let(:search1) { FactoryBot.create(:search, exhibit: exhibit, title: 'All of the good dogs') }
  let(:search2) { FactoryBot.create(:search, exhibit: exhibit, title: 'All of the good cats') }
  let(:search3) { FactoryBot.create(:search, exhibit: exhibit, title: 'All of the good birds') }
  let(:search4) { FactoryBot.create(:search, exhibit: exhibit, title: 'All of the good pigs') }
  let(:search5) { FactoryBot.create(:search, exhibit: exhibit, title: 'All of the good tigers') }
  let(:search6) { FactoryBot.create(:search, exhibit: exhibit, title: 'All of the good ferrets') }
  let!(:group) { FactoryBot.create(:group, exhibit: exhibit, searches: [search1, search2, search3, search4, search5, search6], title: 'Pets', published: true) }
  let!(:group2) { FactoryBot.create(:group, exhibit: exhibit, searches: [search1, search2], title: 'Good animals', published: true) }

  before do
    login_as exhibit_curator

    visit spotlight.edit_exhibit_feature_page_path(exhibit, feature_page)
    add_widget 'browse_group_categories'
  end

  it 'allows a curator to select a caption to display' do
    fill_in_prefetched_typeahead_field with: 'Pets', wait_for: '[data-type="browse_group_categories"] [data-browse-groups-fetched]'
    within '.dd-list' do
      expect(page).to have_css '.title', text: 'Pets'
    end

    save_page

    expect(page).to have_css 'h2', text: 'Pets'
  end

  it 'can navigate using arrows' do
    fill_in_prefetched_typeahead_field with: 'Pets', wait_for: '[data-type="browse_group_categories"] [data-browse-groups-fetched]'
    within '.dd-list' do
      expect(page).to have_css '.title', text: 'Pets'
    end

    save_page

    expect(page).to have_css 'h2', text: 'Pets'

    expect(page).to have_css '.category-title', text: 'All of the good dogs'
    expect(page).not_to have_css '.category-title', text: 'All of the good tigers'
    find('[data-controls="next"]').click
    expect(page).not_to have_css '.category-title', text: 'All of the good dogs'
    expect(page).to have_css '.category-title', text: 'All of the good tigers'
  end
end
