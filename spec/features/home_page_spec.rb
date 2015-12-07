require 'spec_helper'
describe 'Home page', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }
  it 'exists by default on exhibits' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    click_link 'Feature pages'
    expect(page).to have_selector 'h3', text: 'Homepage'
    expect(page).to have_selector 'h3.panel-title', text: 'Exhibit Home'
  end

  it 'allows users to edit the home page title' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    click_link 'Feature pages'
    within('.home_page') do
      click_link 'Edit'
    end
    fill_in 'home_page_title', with: 'New Home Page Title'
    click_button 'Save changes'
    expect(page).to have_content('The home page was successfully updated.')

    within '.dropdown-menu' do
      click_link 'Dashboard'
    end
    click_link 'Feature pages'
    expect(page).to have_content 'New Home Page Title'
    expect(page).to have_selector '.panel-title a', text: 'New Home Page Title'
  end

  it 'has working facet links' do
    visit spotlight.exhibit_home_page_path(exhibit.home_page)
    click_link 'Genre'
    click_link 'map'
    expect(page).to have_content exhibit.title
    expect(page).to have_content 'You searched for: Genre map'
  end

  it 'has a search box' do
    visit spotlight.exhibit_home_page_path(exhibit.home_page)
    fill_in 'q', with: 'query'
    click_button 'Search'

    expect(page).to have_content exhibit.title
    expect(page).to have_content 'You searched for: query'
  end

  it 'has <meta> tags' do
    TopHat.current['twitter_card'] = nil
    visit spotlight.exhibit_home_page_path(exhibit.home_page)

    expect(page).to have_css "meta[name='twitter:card'][value='summary']", visible: false
    expect(page).to have_css "meta[name='twitter:url'][value='#{spotlight.exhibit_root_url(exhibit)}']", visible: false
  end

  describe 'page options on edit form' do
    describe 'show title' do
      let(:home_page) { FactoryGirl.create(:home_page, display_title: false, exhibit: exhibit) }
      it 'is updatable from the edit page' do
        expect(home_page.display_title).to be_falsey

        visit spotlight.edit_exhibit_home_page_path(home_page.exhibit, home_page)
        expect(find('#home_page_display_title')).not_to be_checked

        check 'Show title'
        click_button 'Save changes'

        visit spotlight.edit_exhibit_home_page_path(home_page.exhibit, home_page)
        expect(find('#home_page_display_title')).to be_checked
      end
    end
  end

  describe 'when configured to not display sidebar' do
    before do
      exhibit.home_page.display_sidebar = false
      exhibit.home_page.save
    end
    it 'does not display the facet sidebar' do
      visit spotlight.exhibit_home_page_path(exhibit)
      expect(page).not_to have_css('#sidebar')
    end
  end
end
