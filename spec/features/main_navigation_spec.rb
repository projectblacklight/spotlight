require 'spec_helper'

describe 'Main navigation labels are settable', type: :feature do
  let!(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:about) { FactoryGirl.create(:about_page, exhibit: exhibit, published: true) }
  before do
    about_nav = exhibit.main_navigations.about
    about_nav.label = 'New About Label'
    about_nav.save
    browse_nav = exhibit.main_navigations.browse
    browse_nav.label = 'New Browse Label'
    browse_nav.save
    search = exhibit.searches.first
    search.published = true
    search.save
    exhibit.reload
  end

  it 'has the configured about and browse navigation labels' do
    visit spotlight.exhibit_path(exhibit)
    expect(page).to have_css('.navbar-nav li', text: 'New About Label')
    expect(page).to have_css('.navbar-nav li', text: 'New Browse Label')
  end
  it 'has the configured about page label in the sidebar' do
    visit spotlight.exhibit_about_page_path(exhibit, about)
    expect(page).to have_css('#sidebar h4', text: 'New About Label')
  end
  it 'has the configured about page label visible in the breadcrumb' do
    visit spotlight.exhibit_about_page_path(exhibit, about)
    expect(page).to have_css('.breadcrumb li', text: 'New About Label')
  end
  it 'has the configured browse page label visible in the breadcrumb of the browse index page' do
    visit spotlight.exhibit_browse_index_path(exhibit, exhibit.searches.first)
    expect(page).to have_content('New Browse Label')
    expect(page).to have_css('.breadcrumb li', text: 'New Browse Label')
  end
  it 'has the configured browse page label visible in the breadcrumb of the browse show page' do
    visit spotlight.exhibit_browse_path(exhibit, exhibit.searches.first)
    expect(page).to have_content('New Browse Label')
    expect(page).to have_css('.breadcrumb li', text: 'New Browse Label')
  end
  it 'does not display any main navigation menu items that are configured to not display' do
    about_nav = exhibit.main_navigations.about
    about_nav.display = false
    about_nav.save
    visit spotlight.exhibit_path(exhibit)
    expect(page).to_not have_css('.navbar-nav li', text: 'New About Label')
    about_nav = exhibit.main_navigations.about
    about_nav.display = true
    about_nav.save
  end
end
