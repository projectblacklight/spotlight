require 'spec_helper'

feature 'About Pages Adminstration', js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  it 'is able to create new pages' do
    login_as exhibit_curator
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'About pages'

    add_new_page_via_button('My New Page')

    expect(page).to have_content 'The about page was created.'
    expect(page).to have_css('li.dd-item')
    expect(page).to have_css('h3', text: 'My New Page')
  end
end
