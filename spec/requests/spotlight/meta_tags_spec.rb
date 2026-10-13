# frozen_string_literal: true

RSpec.describe 'Social media <meta> tags', type: :request do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:page) { Capybara.string(response.body) }

  before { Spotlight::Site.instance.update(title: 'some title') }

  it 'are on the exhibit home page' do
    get spotlight.exhibit_home_page_path(exhibit)

    expect(page).to have_css "meta[name='twitter:card'][content='summary']", visible: false
    expect(page).to have_css "meta[name='twitter:url'][content='#{spotlight.exhibit_root_url(exhibit)}']", visible: false
    expect(page).to have_css "meta[property='og:site_name'][content='some title']", visible: false
  end

  it 'are on feature pages' do
    feature_page = FactoryBot.create(:feature_page, title: 'Parent Page', exhibit:)

    get spotlight.exhibit_feature_page_path(exhibit, feature_page)

    expect(page).to have_css "meta[name='twitter:title'][content='Parent Page']", visible: false
    expect(page).to have_css "meta[property='og:site_name']", visible: false
    expect(page).to have_css "meta[property='og:type'][content='article']", visible: false
    expect(page).to have_css "meta[property='og:title'][content='Parent Page']", visible: false
  end

  it 'are on browse category pages' do
    search = FactoryBot.create(:search, title: 'Some Saved Search', exhibit:, published: true)

    get spotlight.exhibit_browse_path(exhibit, search)

    expect(page).to have_css "meta[name='twitter:title'][content='Some Saved Search']", visible: false
    expect(page).to have_css "meta[property='og:site_name']", visible: false
    expect(page).to have_css "meta[property='og:title'][content='Some Saved Search']", visible: false
  end

  it 'are on item pages' do
    get spotlight.exhibit_solr_document_path(exhibit, 'dq287tq6352')

    expect(page).to have_css "meta[name='twitter:title']", visible: false
    expect(page).to have_css "meta[property='og:site_name']", visible: false
    expect(page).to have_css "meta[property='og:title']", visible: false
  end
end
