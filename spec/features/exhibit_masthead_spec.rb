require 'spec_helper'

describe 'Add and update the site masthead', type: :feature do
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as user }
  it 'updates exhibit masthead options' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    within '#sidebar' do
      click_link 'Appearance'
    end

    click_link 'Site masthead'

    within '#site-masthead' do
      check 'Show background image in masthead'
      choose 'Upload an image'
      attach_file('exhibit_masthead_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
    end

    click_button 'Save changes'

    expect(page).to have_content('The exhibit was successfully updated.')

    within '#sidebar' do
      click_link 'Appearance'
    end

    click_link 'Site masthead'

    within '#site-masthead' do
      expect(field_labeled('Show background image in masthead')).to be_checked
      expect(field_labeled('Upload an image')).to be_checked
    end
  end
  it 'displays a masthead image when one is uploaded and configured' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to_not have_css('.image-masthead')
    within '#sidebar' do
      click_link 'Appearance'
    end

    click_link 'Site masthead'

    within '#site-masthead' do
      check 'Show background image in masthead'

      attach_file('exhibit_masthead_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
    end

    click_button 'Save changes'

    expect(page).to have_content('The exhibit was successfully updated.')

    expect(page).to have_css('.image-masthead .background-container')
  end
  it 'does not display an uploaded masthead if configured to not display' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to_not have_css('.image-masthead')
    within '#sidebar' do
      click_link 'Appearance'
    end

    click_link 'Site masthead'

    within '#site-masthead' do
      attach_file('exhibit_masthead_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
    end

    click_button 'Save changes'

    expect(page).to have_content('The exhibit was successfully updated.')

    expect(page).to_not have_css('.image-masthead .background-container')
  end
  it 'displays a masthead image when one is uploaded from an exhibit item', js: true do
    skip "Capyabara and jcrop don't play well together.."
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to_not have_css('.image-masthead')
    within '#sidebar' do
      click_link 'Appearance'
    end

    click_link 'Site masthead'

    within '#site-masthead' do
      check 'Show background image in masthead'

      fill_in_typeahead_field 'document_title', with: 'Armenia'
    end

    click_button 'Save changes'

    expect(page).to have_content('The appearance was successfully updated.')

    expect(page).to have_css('.image-masthead .background-container')
  end
end
