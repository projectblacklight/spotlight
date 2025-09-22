# frozen_string_literal: true

RSpec.describe 'Horizontal rule block', js: true, type: :feature, versioning: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let!(:feature_page) { FactoryBot.create(:feature_page, exhibit:) }

  before { login_as exhibit_curator }

  it 'allows the user to select which image in a multi image object to display' do
    exhibit.home_page.content = '[]'
    exhibit.home_page.save

    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link 'Edit'

    add_widget 'rule'

    save_page_changes

    expect(page).to have_css('hr')

    expect(page).to be_axe_clean.within '#content'
  end
end
