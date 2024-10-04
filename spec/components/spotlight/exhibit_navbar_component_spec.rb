# frozen_string_literal: true

RSpec.describe Spotlight::ExhibitNavbarComponent, type: :component do
  subject(:rendered) do
    Capybara::Node::Simple.new(render_inline(component).to_s)
  end

  before do
    allow(vc_test_controller).to receive_messages(enabled_in_spotlight_view_type_configuration?: true, current_exhibit: current_exhibit, field_enabled?: true)
    allow(vc_test_controller).to receive(:search_action_url).and_return('/catalog')
    allow(vc_test_controller).to receive(:blacklight_config).and_return(CatalogController.blacklight_config)
    allow(vc_test_controller).to receive_messages(resource_masthead?: false)
    allow(vc_test_controller).to receive(:render).and_call_original
    allow(vc_test_controller).to receive(:render).with(Blacklight::SearchBarComponent).and_return('Search Bar')
    allow(vc_test_controller).to receive_messages(exhibit_path: spotlight.exhibit_path(current_exhibit))
    allow(vc_test_controller).to receive_messages(on_browse_page?: false, on_about_page?: false)
  end

  let(:view_context) { vc_test_controller.view_context }
  let(:current_exhibit) { FactoryBot.create(:exhibit) }
  let(:component) { described_class.new }
  let(:feature_page) { FactoryBot.create(:feature_page, exhibit: current_exhibit) }
  let(:unpublished_feature_page) { FactoryBot.create(:feature_page, published: false, exhibit: current_exhibit) }
  let(:about_page) { FactoryBot.create(:about_page, exhibit: current_exhibit) }
  let(:unpublished_about_page) { FactoryBot.create(:about_page, published: false, exhibit: current_exhibit) }

  it 'links to the exhibit home page (as branding) when there is a current search masthead' do
    allow(vc_test_controller).to receive_messages(resource_masthead?: true)
    expect(rendered).to have_selector('a.navbar-brand', text: current_exhibit.title)
  end

  it 'links to the search page if no home page is defined' do
    expect(rendered).to have_link 'Home', href: spotlight.exhibit_path(current_exhibit)
  end

  it 'links to the home page' do
    allow(current_exhibit).to receive_messages home_page: feature_page
    expect(rendered).to have_link 'Home', href: spotlight.exhibit_path(current_exhibit)
  end

  it 'links directly to a single feature page' do
    feature_page
    expect(rendered).to have_link feature_page.title, href: spotlight.exhibit_feature_page_path(current_exhibit, feature_page)
  end

  it 'provides a dropdown of multiple feature pages' do
    feature_page
    another_page = FactoryBot.create(:feature_page, exhibit: current_exhibit)
    expect(rendered).to have_selector '.dropdown .dropdown-toggle', text: 'Curated features'
    expect(rendered).to have_link feature_page.title, visible: false, href: spotlight.exhibit_feature_page_path(current_exhibit, feature_page)
    expect(rendered).to have_link another_page.title, visible: false, href: spotlight.exhibit_feature_page_path(current_exhibit, another_page)
  end

  it 'does not display links to feature pages if none are defined' do
    expect(rendered).to have_no_link 'Curated Features'
  end

  it 'does not display links to feature pages that are not published' do
    unpublished_feature_page
    expect(rendered).to have_no_link 'Curated Features'
  end

  it "links to the browse index if there's a published search" do
    FactoryBot.create(:published_search, exhibit: current_exhibit)
    expect(rendered).to have_link 'Browse', href: spotlight.exhibit_browse_index_path(current_exhibit)
  end

  it 'does not link to the browse index if no categories are defined' do
    expect(rendered).to have_no_link 'Browse'
  end

  it 'does not link to the browse index if only private categories are defined' do
    FactoryBot.create(:search, exhibit: current_exhibit)
    expect(rendered).to have_no_link 'Browse'
  end

  it 'links to the about page' do
    allow(current_exhibit).to receive_messages main_about_page: about_page
    expect(rendered).to have_link 'About', href: spotlight.exhibit_about_page_path(current_exhibit, about_page)
  end

  it 'does not link to the about page if no about page exists' do
    expect(rendered).to have_no_link 'About'
  end

  it 'does not to the about page if none are published' do
    unpublished_about_page
    expect(rendered).to have_no_link 'About'
  end

  it 'does not include the search bar when the exhibit is not searchable' do
    expect(current_exhibit).to receive(:searchable?).and_return(false)
    expect(rendered).to have_no_content 'Search Bar'
  end

  it 'does not include any navigation menu items that are not configured' do
    expect(current_exhibit.main_navigations).to receive_messages(displayable: [])
    expect(rendered).to have_css('.navbar-nav li', count: 1)
    expect(rendered).to have_css('.navbar-nav li', text: 'Home')
  end

  ## Tests to check
  it "marks the browse button as active if we're on a browse page" do
    FactoryBot.create(:published_search, exhibit: current_exhibit)
    allow(vc_test_controller).to receive_messages(on_browse_page?: true)
    expect(rendered).to have_selector 'li.active', text: 'Browse'
  end

  it "marks the about button as active if we're on an about page" do
    allow(current_exhibit).to receive_messages main_about_page: about_page
    allow(vc_test_controller).to receive_messages(on_about_page?: true)
    expect(rendered).to have_selector 'li.active', text: 'About'
  end

  it 'includes the search bar when the exhibit is searchable' do
    expect(current_exhibit).to receive(:searchable?).and_return(true)
    expect(rendered).to have_content 'Search Bar'
  end
end
