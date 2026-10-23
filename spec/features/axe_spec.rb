# frozen_string_literal: true

# Most pages are checked with be_axe_clean in their existing JS feature specs;
# this covers the pages that don't otherwise get a JS visit.
RSpec.describe 'Accessibility testing', :js do
  let(:exhibit) { FactoryBot.create(:exhibit, title: 'Test Exhibit', published: true) }
  let!(:other_exhibit) { FactoryBot.create(:exhibit, title: 'Other Test Exhibit', published: true) }
  let(:about_page) { FactoryBot.create(:about_page, exhibit:, title: 'About', published: true) }
  let(:feature_page) { FactoryBot.create(:feature_page, exhibit:, title: 'Feature Page', published: true) }
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit:) }

  before { login_as user }

  it 'validates the site home page, an about page, and an empty feature page' do
    visit root_path
    expect(page).to have_css('h2', text: exhibit.title)
    expect(page).to have_css('h2', text: other_exhibit.title)
    expect(page).to be_axe_clean

    visit spotlight.exhibit_about_page_path(exhibit, about_page)
    expect(page).to have_css('h2', text: about_page.title)
    expect(page).to be_axe_clean

    visit spotlight.exhibit_feature_page_path(exhibit, feature_page)
    expect(page).to have_css('.empty-page-block')
    expect(page).to be_axe_clean
  end
end
