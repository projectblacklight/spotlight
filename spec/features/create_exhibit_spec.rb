require 'spec_helper'

describe 'Create a new exhibit', type: :feature do
  let(:user) { FactoryGirl.create(:site_admin) }
  before do
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    login_as user
  end

  it 'has a link in the user dropdown' do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Create Exhibit'
    end
    expect(page).to have_selector 'h1', text: 'Configuration'
    expect(page).to have_selector 'h1 small', text: 'Create a new exhibit'
  end

  it 'allows admins to create a new exhibit' do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Create Exhibit'
    end

    fill_in 'Title', with: 'My exhibit title'

    click_button 'Save'

    expect(page).to have_content 'The exhibit was created.'
    expect(Spotlight::Exhibit.last.slug).to eq 'my-exhibit-title'
  end

  it 'allows admins to create a new exhibit with a slug' do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Create Exhibit'
    end

    fill_in 'Title', with: 'My exhibit title'
    fill_in 'URL slug', with: 'custom-slug'

    click_button 'Save'

    expect(page).to have_content 'The exhibit was created.'
    expect(Spotlight::Exhibit.last.slug).to eq 'custom-slug'
  end
end
