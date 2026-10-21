# frozen_string_literal: true

RSpec.describe 'Browse pages' do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:search) { FactoryBot.create(:search, title: 'Some Saved Search', exhibit:, published: true) }
  let!(:search_2) { FactoryBot.create(:search, title: 'Some Other Saved Search', exhibit:, published: true) }
  let!(:group) { FactoryBot.create(:group, title: 'Awesome group', exhibit:, published: true, searches: [search]) }

  describe 'landing page' do
    before do
      visit spotlight.exhibit_browse_index_path(exhibit)
    end

    it 'displays all categories and tabs for each group' do
      within '.browse-group-navigation' do
        expect(page).to have_css 'li.nav-item a.nav-link.active', text: 'All'
        expect(page).to have_css 'li.nav-item a.nav-link', count: exhibit.groups.count + 1
      end
      within '.browse-landing' do
        expect(page).to have_css '.category', count: 2
      end
    end

    it 'filters browse categories when navigated' do
      within '.browse-group-navigation' do
        click_link group.title
        expect(page).to have_css 'li.nav-item a.nav-link.active', text: group.title
      end
      within '.browse-landing' do
        expect(page).to have_css '.category', count: 1
      end
    end

    it 'clicking through from the context of a category provides the breadcrums' do
      within '.browse-group-navigation' do
        click_link group.title
        expect(page).to have_css 'li.nav-item a.nav-link.active', text: group.title
      end
      click_link 'Some Saved Search'
      expect(page).to have_css 'ol.breadcrumb li.breadcrumb-item', count: 4
      expect(page).to have_css 'li.breadcrumb-item', text: 'Awesome group'
    end
  end
end
