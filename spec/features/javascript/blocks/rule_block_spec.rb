# frozen_string_literal: true

describe 'Horizontal rule block', type: :feature, js: true, versioning: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
  let!(:feature_page) { FactoryBot.create(:feature_page, exhibit: exhibit) }
  before { login_as exhibit_curator }

  it 'allows the user to select which image in a multi image object to display' do
    exhibit.home_page.content = '[]'
    exhibit.home_page.save

    visit spotlight.exhibit_home_page_path(exhibit, exhibit.home_page)
    click_link 'Edit'

    add_widget 'rule'

    save_page

    expect(page).to have_css('hr')
  end
end
