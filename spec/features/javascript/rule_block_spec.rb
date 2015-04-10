require 'spec_helper'

describe 'Horizontal rule block', type: :feature, js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let!(:feature_page) { FactoryGirl.create(:feature_page, exhibit: exhibit) }
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
