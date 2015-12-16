require 'spec_helper'

describe 'Add a contact to an exhibit', type: :feature do
  let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:about_page) { FactoryGirl.create(:about_page, exhibit: exhibit) }
  before { login_as curator }
  it 'displays a newly added contact in the sidebar' do
    visit spotlight.exhibit_about_pages_path(exhibit)
    click_link 'Add contact'
    within '#new_contact' do
      fill_in 'Name', with: 'Marcus Aurelius'
      fill_in 'Email', with: 'marcus@rome.gov'
      fill_in 'Title', with: 'Emperor'
      fill_in 'Location', with: 'Rome'
      fill_in 'Telephone', with: '(555) 555-5555 ext. 12345 (mobile)'

      click_button 'Save'
    end
    expect(page).to have_content 'The contact was created.'

    within '.contacts_admin' do
      check 'exhibit_contacts_attributes_0_show_in_sidebar'
    end
    within '.exhibit-contacts' do
      click_button 'Save changes'
    end

    expect(page).to have_content 'Contacts were successfully updated.'

    within '#nested-pages' do
      click_link 'View'
    end

    within '#sidebar .contacts' do
      expect(page).to have_selector '.name', text: 'Marcus Aurelius'
      expect(page).to have_selector 'div', text: 'marcus@rome.gov'
      expect(page).to have_selector 'div', text: 'Emperor'
      expect(page).to have_selector 'div', text: 'Rome'
      expect(page).to have_selector 'div', text: '(555) 555-5555 ext. 12345 (mobile)'
      expect(page).to_not have_selector 'img.contact-photo'
    end
  end

  it "allows the curator to crop the contact's avatar", js: true do
    skip "Capyabara and jcrop don't play well together.."

    visit spotlight.exhibit_about_pages_path(exhibit)
    click_link 'Add contact'
    page.document.synchronize do
      find('.jcrop-holder')
    end
    within '#new_contact' do
      fill_in 'Name', with: 'Pictured User'
      fill_in 'Email', with: 'marcus@rome.gov'
      attach_file('contact_avatar', File.absolute_path(File.join(FIXTURES_PATH, 'avatar.png')))
    end
    expect(page).to have_content 'The contact was created.'
    expect(page).to have_selector 'img.contact-photo'
  end
end
