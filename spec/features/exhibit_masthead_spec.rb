# frozen_string_literal: true

describe 'Add and update the site masthead', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }

  before { login_as user }

  it 'updates exhibit masthead options' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    within '#sidebar' do
      click_link 'Appearance'
    end

    click_link 'Exhibit masthead'

    within '#site-masthead' do
      check 'Show background image in masthead'
      choose 'Upload an image'

      # The JS fills in these fields:
      find('#exhibit_masthead_attributes_iiif_tilesource', visible: false).set 'http://test.host/images/7'
      find('#exhibit_masthead_attributes_iiif_region', visible: false).set '0,0,100,200'
      # attach_file('exhibit_masthead_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
    end

    click_button 'Save changes'

    expect(page).to have_content('The exhibit was successfully updated.')

    within '#sidebar' do
      click_link 'Appearance'
    end

    click_link 'Exhibit masthead'

    within '#site-masthead' do
      expect(page).to have_checked_field 'Show background image in masthead'
      expect(page).to have_checked_field 'Upload an image'
    end
  end

  it 'displays a masthead image when one is uploaded and configured' do
    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to_not have_css('.image-masthead')
    within '#sidebar' do
      click_link 'Appearance'
    end

    click_link 'Exhibit masthead'

    within '#site-masthead' do
      check 'Show background image in masthead'

      # attach_file('exhibit_masthead_attributes_image', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
      # The JS fills in these fields:
      find('#exhibit_masthead_attributes_iiif_tilesource', visible: false).set 'http://test.host/images/7'
      find('#exhibit_masthead_attributes_iiif_region', visible: false).set '0,0,100,200'
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

    click_link 'Exhibit masthead'

    within '#site-masthead' do
      attach_file('exhibit_masthead_attributes_file', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
    end

    click_button 'Save changes'

    expect(page).to have_content('The exhibit was successfully updated.')

    expect(page).to_not have_css('.image-masthead .background-container')
  end

  it 'displays a masthead image when one is uploaded from an exhibit item', js: true do
    skip "Capyabara and the cropping tool don't play well together.."

    visit spotlight.exhibit_dashboard_path(exhibit)
    expect(page).to_not have_css('.image-masthead')
    within '#sidebar' do
      click_link 'Appearance'
    end

    click_link 'Exhibit masthead'

    within '#site-masthead' do
      check 'Show background image in masthead'

      fill_in_typeahead_field 'document_title', with: 'Armenia'
    end

    click_button 'Save changes'

    expect(page).to have_content('The appearance was successfully updated.')

    expect(page).to have_css('.image-masthead .background-container')
  end
end
