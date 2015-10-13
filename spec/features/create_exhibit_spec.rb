require 'spec_helper'

describe 'Create a new exhibit', type: :feature do
  let(:user) { FactoryGirl.create(:site_admin) }
  before do
    allow_any_instance_of(Spotlight::Search).to receive(:set_default_featured_image)
    login_as user
  end

  it 'has a link in the user dropdown' do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Create Exhibit'
    end
    expect(page).to have_selector 'h1', text: 'Administration'
    expect(page).to have_selector 'h1 small', text: 'Create a new exhibit'
  end

  it 'has a contact emails field' do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Create Exhibit'
    end
    expect(page).to have_css('#exhibit_contact_emails_attributes_0_email')
  end

  it 'allows admins to create a new exhibit' do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Create Exhibit'
    end

    fill_in 'Title', with: 'My exhibit title'
    fill_in 'Subtitle', with: 'Some subtitle'
    fill_in 'Description', with: 'A short description of the exhibit'

    click_button 'Save'

    expect(page).to have_content 'The exhibit was created.'
  end
end
