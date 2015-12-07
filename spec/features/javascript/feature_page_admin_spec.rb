require 'spec_helper'

feature 'Feature Pages Adminstration', js: true do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let!(:page1) do
    FactoryGirl.create(
      :feature_page,
      title: 'FeaturePage1',
      exhibit: exhibit
    )
  end
  let!(:page2) do
    FactoryGirl.create(
      :feature_page,
      title: 'FeaturePage2',
      exhibit: exhibit,
      display_sidebar: true
    )
  end

  before { login_as exhibit_curator }

  it 'is able to create new pages' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'Feature pages'

    add_new_page_via_button('My New Page')

    expect(page).to have_content 'The feature page was created.'
    expect(page).to have_css('li.dd-item')
    expect(page).to have_css('h3', text: 'My New Page')
  end

  it 'updates the page titles' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'Feature pages'
    within("[data-id='#{page1.id}']") do
      within('h3') do
        expect(page).to have_content('FeaturePage1')
        expect(page).to have_css('input', visible: false)
        click_link('FeaturePage1')
        expect(page).to have_css('input', visible: true)
        find('input').set('NewFeaturePage1')
      end
    end
    click_button('Save changes')
    within("[data-id='#{page1.id}']") do
      within('h3') do
        expect(page).to have_content('NewFeaturePage1')
      end
    end
  end

  it 'stays in curation mode if a user has unsaved data' do
    visit spotlight.edit_exhibit_feature_page_path(page1.exhibit, page1)

    fill_in('Title', with: 'Some Fancy Title')
    click_link 'Cancel'
    expect(page).not_to have_selector 'a', text: 'Edit'
  end

  it 'stays in curation mode if a user has unsaved contenteditable data' do
    visit spotlight.edit_exhibit_feature_page_path(page1.exhibit, page1)

    add_widget 'solr_documents'
    content_editable = find('.st-text-block')
    content_editable.set('Some Fancy Text.')

    click_link 'Cancel'
    expect(page).not_to have_selector 'a', text: 'Edit'
  end

  it 'does not update the pages list when the user has unsaved changes' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'Feature pages'
    within("[data-id='#{page1.id}']") do
      within('h3') do
        expect(page).to have_content('FeaturePage1')
        expect(page).to have_css('input', visible: false)
        click_link('FeaturePage1')
        expect(page).to have_css('input', visible: true)
        find('input').set('NewFancyTitle')
      end
    end

    within '#exhibit-navbar' do
      click_link 'Home'
    end
    expect(page).not_to have_content('Feature pages were successfully updated.')
    # NOTE: get flash message about unsaved changes
    expect(page).to have_content('Welcome to your new exhibit')

    # ensure page title not changed
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
      click_link 'Dashboard'
    end
    click_link 'Feature pages'
    within("[data-id='#{page1.id}']") do
      within('h3') do
        expect(page).to have_content('FeaturePage1') # old title
      end
    end
  end

  it 'is able to update home page titles' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'Feature pages'

    within('.home_page') do
      within('h3.panel-title') do
        expect(page).to have_content(exhibit.home_page.title)
        expect(page).to have_css('input', visible: false)
        click_link(exhibit.home_page.title)
        expect(page).to have_css('input', visible: true)
        find('input').set('New Home Page Title')
      end
    end

    click_button('Save changes')

    within('.home_page') do
      within('h3.panel-title') do
        expect(page).to have_content('New Home Page Title')
      end
    end
  end
end
