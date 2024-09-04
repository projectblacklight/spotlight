# frozen_string_literal: true

describe 'Create a new exhibit', type: :feature do
  let(:user) { FactoryBot.create(:site_admin) }

  before do
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    login_as user
  end

  it 'has a link in the user dropdown' do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Create new exhibit'
    end
    expect(page).to have_selector 'h1', text: 'Create a new exhibit'
  end

  it 'allows admins to create a new exhibit' do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Create new exhibit'
    end

    fill_in 'Title', with: 'My exhibit title'

    find('input[name="commit"]').click

    expect(page).to have_content 'The exhibit was created.'
    expect(Spotlight::Exhibit.last.slug).to eq 'my-exhibit-title'
  end

  it 'allows admins to create a new exhibit with a slug' do
    visit '/'
    within '.dropdown-menu' do
      click_link 'Create new exhibit'
    end

    fill_in 'Title', with: 'My exhibit title'
    fill_in 'URL slug', with: 'custom-slug'

    find('input[name="commit"]').click

    expect(page).to have_content 'The exhibit was created.'
    expect(Spotlight::Exhibit.last.slug).to eq 'custom-slug'
  end

  it 'fails validation if the slug is already used' do
    visit spotlight.new_exhibit_path

    fill_in 'Title', with: 'My exhibit title'
    fill_in 'URL slug', with: 'custom-slug'

    find('input[name="commit"]').click

    visit spotlight.new_exhibit_path

    fill_in 'Title', with: 'My exhibit title'
    fill_in 'URL slug', with: 'custom-slug'

    find('input[name="commit"]').click

    expect(page).to have_content 'has already been taken'
  end

  it 'suggests a slug based on the title', js: true do
    visit spotlight.new_exhibit_path

    fill_in 'Title', with: 'My exhibit title'
    expect(find_field('URL slug')[:placeholder]).to eq 'my-exhibit-title'
  end
end
