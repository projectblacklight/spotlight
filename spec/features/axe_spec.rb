# frozen_string_literal: true

RSpec.describe 'Accessibility testing', :js do
  let(:exhibit) { FactoryBot.create(:exhibit, title: 'Test Exhibit', published: true) }
  let!(:other_exhibit) { FactoryBot.create(:exhibit, title: 'Other Test Exhibit', published: true) }
  let(:about_page) { FactoryBot.create(:about_page, exhibit:, title: 'About', published: true) }
  let(:feature_page) { FactoryBot.create(:feature_page, exhibit:, title: 'Feature Page', published: true) }
  let(:search) { FactoryBot.create(:search, title: 'Browse Search', exhibit:, published: true) }
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit:) }

  before do
    login_as user
  end

  it 'validates site home page' do
    visit root_path
    expect(page).to have_css('h2', text: exhibit.title)
    expect(page).to have_css('h2', text: other_exhibit.title)
    expect(page).to be_axe_clean
  end

  it 'validates exhibit home page' do
    visit spotlight.exhibit_path(exhibit)
    expect(page).to have_css('h1', text: exhibit.title)
    expect(page).to be_axe_clean
  end

  it 'validates feature page' do
    visit spotlight.exhibit_feature_page_path(exhibit, feature_page)
    expect(page).to have_css('h2', text: feature_page.title)
    expect(page).to be_axe_clean
  end

  it 'validates about page' do
    visit spotlight.exhibit_about_page_path(exhibit, about_page)
    expect(page).to have_css('h2', text: about_page.title)
    expect(page).to be_axe_clean
  end

  it 'validates search results page' do
    visit spotlight.search_exhibit_catalog_path(exhibit, q: 'america')
    expect(page).to be_axe_clean
  end

  it 'validates item page' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')
    expect(page).to have_css('h1', text: "L'AMERIQUE")
    expect(page).to be_axe_clean
  end

  it 'validates browse landing page' do
    visit spotlight.exhibit_browse_index_path(exhibit)
    expect(page).to have_css('h2', text: 'Browse')
    expect(page).to be_axe_clean
  end

  it 'validates browse category page' do
    visit spotlight.exhibit_browse_path(exhibit, search)
    expect(page).to have_css('h2', text: search.title)
    expect(page).to be_axe_clean
  end

  it 'validates admin dashboard' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to be_axe_clean
  end
end
