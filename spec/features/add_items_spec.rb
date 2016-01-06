require 'spec_helper'

describe 'Uploading a non-repository item', type: :feature do
  let!(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:custom_field) { FactoryGirl.create(:custom_field, exhibit: exhibit) }
  let!(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  describe 'forms' do
    it 'displays the single item upload form' do
      visit spotlight.new_exhibit_resource_path(exhibit)
      expect(page).to have_css('h1', text: /Curation/)
      expect(page).to have_css 'h1 small', text: 'Add items'

      click_link 'Upload item'

      within('form#new_resources_upload') do
        expect(page).to have_css('#resources_upload_url[type="file"]')
        expect(page).to have_css('.help-block', text: 'Valid file types: jpg jpeg png')
        expect(page).to have_css('#resources_upload_data_full_title_tesim[type="text"]')
        expect(page).to have_css('textarea#resources_upload_data_spotlight_upload_description_tesim')
        expect(page).to have_css('#resources_upload_data_spotlight_upload_attribution_tesim[type="text"]')
        expect(page).to have_css('#resources_upload_data_spotlight_upload_date_tesim[type="text"]')
        expect(page).to have_css("#resources_upload_data_#{custom_field.field}[type='text']")
      end
    end

    it 'creates a new item' do
      visit spotlight.new_exhibit_resource_path(exhibit)

      click_link 'Upload item'

      attach_file('resources_upload_url', File.join(FIXTURES_PATH, '800x600.png'))
      fill_in 'Title', with: '800x600'

      within '#new_resources_upload' do
        click_button 'Add item'
      end
      expect(page).to have_content 'Object uploaded successfully.'

      expect(Spotlight::Resource.last.url.file.path).to end_with '800x600.png'
      Blacklight.default_index.connection.delete_by_id Spotlight::Resource.last.send(:compound_id)
      Blacklight.default_index.connection.commit
    end

    it 'displays the multi-item CSV upload form' do
      visit spotlight.new_exhibit_resource_path(exhibit)
      expect(page).to have_css('h1', text: /Curation/)
      expect(page).to have_css 'h1 small', text: 'Add items'

      click_link 'Upload multiple items'

      within('form#new_resources_csv_upload') do
        expect(page).to have_css('#resources_csv_upload_url[type="file"]')
        expect(page).to have_css('.help-block a', text: 'Download template')
      end
    end
  end

  describe 'upload' do
    it 'is editable' do
      visit spotlight.new_exhibit_resource_path(exhibit)

      click_link 'Upload item'

      attach_file('resources_upload_url', File.join(FIXTURES_PATH, '800x600.png'))
      fill_in 'Title', with: '800x600'

      within '#new_resources_upload' do
        click_button 'Add item'
      end

      click_link '800x600'
      click_link 'Edit'
      fill_in 'Title', with: 'This is a now an avatar'

      attach_file('File', File.join(FIXTURES_PATH, 'avatar.png'))

      click_button 'Save'

      expect(page).to have_content 'This is a now an avatar'
      expect(Spotlight::Resource.last.url.file.path).to end_with 'avatar.png'
      Blacklight.default_index.connection.delete_by_id Spotlight::Resource.last.send(:compound_id)
      Blacklight.default_index.connection.commit
    end
  end
end
