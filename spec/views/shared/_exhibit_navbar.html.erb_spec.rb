require 'spec_helper'

describe 'shared/_exhibit_navbar', type: :view do
  let(:current_exhibit) { FactoryGirl.create(:exhibit) }
  let(:feature_page) { FactoryGirl.create(:feature_page, exhibit: current_exhibit) }
  let(:unpublished_feature_page) { FactoryGirl.create(:feature_page, published: false, exhibit: current_exhibit) }
  let(:about_page) { FactoryGirl.create(:about_page, exhibit: current_exhibit) }
  let(:unpublished_about_page) { FactoryGirl.create(:about_page, published: false, exhibit: current_exhibit) }

  before :each do
    allow(view).to receive_messages(resource_masthead?: false)
    allow(view).to receive_messages(current_exhibit: current_exhibit)
    allow(view).to receive_messages(on_browse_page?: false, on_about_page?: false)
    allow(view).to receive_messages(render_search_bar: 'Search Bar')
    allow(view).to receive_messages(exhibit_path: spotlight.exhibit_path(current_exhibit))
  end

  it 'links to the exhibit home page (as branding) when there is a current search masthead' do
    allow(view).to receive_messages(resource_masthead?: true)
    render
    expect(response).to have_selector('a.navbar-brand', text: current_exhibit.title)
  end

  it 'links to the search page if no home page is defined' do
    render
    expect(response).to have_link 'Home', href: spotlight.exhibit_path(current_exhibit)
  end

  it 'links to the home page' do
    allow(current_exhibit).to receive_messages home_page: feature_page
    render
    expect(response).to have_link 'Home', href: spotlight.exhibit_path(current_exhibit)
  end

  it 'links directly to a single feature page' do
    feature_page
    render
    expect(response).to have_link feature_page.title, href: spotlight.exhibit_feature_page_path(current_exhibit, feature_page)
  end

  it 'provides a dropdown of multiple feature pages' do
    feature_page
    another_page = FactoryGirl.create(:feature_page, exhibit: current_exhibit)
    render
    expect(response).to have_selector '.dropdown .dropdown-toggle', text: 'Curated Features'
    expect(response).to have_link feature_page.title, visible: false, href: spotlight.exhibit_feature_page_path(current_exhibit, feature_page)
    expect(response).to have_link another_page.title, visible: false, href: spotlight.exhibit_feature_page_path(current_exhibit, another_page)
  end

  it 'does not display links to feature pages if none are defined' do
    render
    expect(response).to_not have_link 'Curated Features'
  end

  it 'does not display links to feature pages that are not published' do
    unpublished_feature_page
    render
    expect(response).to_not have_link 'Curated Features'
  end

  it "links to the browse index if there's a published search" do
    FactoryGirl.create :published_search, exhibit: current_exhibit
    render
    expect(response).to have_link 'Browse', href: spotlight.exhibit_browse_index_path(current_exhibit)
  end

  it "marks the browse button as active if we're on a browse page" do
    FactoryGirl.create :published_search, exhibit: current_exhibit
    allow(view).to receive_messages(on_browse_page?: true)
    render
    expect(response).to have_selector 'li.active', text: 'Browse'
  end

  it 'does not link to the browse index if no categories are defined' do
    render
    expect(response).not_to have_link 'Browse'
  end

  it 'does not link to the browse index if only private categories are defined' do
    FactoryGirl.create :search, exhibit: current_exhibit
    render
    expect(response).not_to have_link 'Browse'
  end

  it 'links to the about page' do
    allow(current_exhibit).to receive_messages main_about_page: about_page
    render
    expect(response).to have_link 'About', href: spotlight.exhibit_about_page_path(current_exhibit, about_page)
  end

  it 'does not link to the about page if no about page exists' do
    render
    expect(response).to_not have_link 'About'
  end

  it 'does not to the about page if none are published' do
    unpublished_about_page
    render
    expect(response).to_not have_link 'About'
  end

  it "marks the about button as active if we're on an about page" do
    allow(current_exhibit).to receive_messages main_about_page: about_page
    allow(view).to receive_messages(on_about_page?: true)
    render
    expect(response).to have_selector 'li.active', text: 'About'
  end

  it 'includes the search bar when the exhibit is searchable' do
    expect(current_exhibit).to receive(:searchable?).and_return(true)
    render
    expect(response).to have_content 'Search Bar'
  end

  it 'does not include the search bar when the exhibit is not searchable' do
    expect(current_exhibit).to receive(:searchable?).and_return(false)
    render
    expect(response).to_not have_content 'Search Bar'
  end

  it 'does not include any navigation menu items that are not configured' do
    expect(current_exhibit.main_navigations).to receive_messages(displayable: [])
    render
    expect(response).to have_css('.navbar-nav li', count: 1)
    expect(response).to have_css('.navbar-nav li', text: 'Home')
  end
end
