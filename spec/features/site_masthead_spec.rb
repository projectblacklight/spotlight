require 'spec_helper'

describe 'Add and update the site masthead', type: :feature do
  let(:user) { FactoryGirl.create(:site_admin) }

  before { login_as user }

  it 'updates site masthead options' do
    visit spotlight.edit_site_path

    click_link 'Site masthead'

    within '#site-masthead' do
      check 'Show background image in masthead'
      attach_file('site_masthead_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
    end

    click_button 'Save changes'

    expect(page).to have_content('The site was successfully updated.')

    visit spotlight.edit_site_path
    click_link 'Site masthead'

    within '#site-masthead' do
      expect(field_labeled('Show background image in masthead')).to be_checked
    end
  end

  it 'idempotently updates the site masthead options' do
    visit spotlight.edit_site_path

    click_link 'Site masthead'

    within '#site-masthead' do
      check 'Show background image in masthead'
      attach_file('site_masthead_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
    end

    click_button 'Save changes'

    expect(page).to have_content('The site was successfully updated.')

    visit spotlight.edit_site_path
    click_link 'Site masthead'
    click_button 'Save changes'
    expect(page).to have_css('.image-masthead .background-container')
  end
  it 'displays a masthead image when one is uploaded and configured' do
    visit spotlight.edit_site_path

    expect(page).to_not have_css('.image-masthead')

    click_link 'Site masthead'

    within '#site-masthead' do
      check 'Show background image in masthead'

      attach_file('site_masthead_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
    end

    click_button 'Save changes'

    expect(page).to have_content('The site was successfully updated.')

    expect(page).to have_css('.image-masthead .background-container')
  end
  it 'does not display an uploaded masthead if configured to not display' do
    visit spotlight.edit_site_path

    expect(page).to_not have_css('.image-masthead')

    click_link 'Site masthead'

    within '#site-masthead' do
      attach_file('site_masthead_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
    end

    click_button 'Save changes'

    expect(page).to have_content('The site was successfully updated.')

    expect(page).to_not have_css('.image-masthead .background-container')
  end
end
