require 'spec_helper'

feature 'Editing the Home Page', js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:admin) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as admin }

  it 'does not have a search results widget' do
    visit spotlight.edit_exhibit_home_page_path(exhibit)
    click_add_widget
    within("[data-icon='add']") do
      expect(page).not_to have_css("[data-type='search_results']", visible: true)
    end
  end
end
