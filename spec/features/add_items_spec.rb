# frozen_string_literal: true

RSpec.describe 'Uploading a non-repository item', type: :feature do
  include ActiveJob::TestHelper

  let!(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:custom_field) { FactoryBot.create(:custom_field, exhibit:, field_type: :vocab) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let(:user) { exhibit_curator }

  before { login_as user }

  describe 'forms' do
    it 'displays the single item upload form' do
      visit spotlight.new_exhibit_resource_path(exhibit)
      expect(page).to have_css('h1', text: /Curation/)
      expect(page).to have_css 'h1 small', text: 'Add items'

      click_link 'Upload item'

      within('form#new_resources_upload') do
        expect(page).to have_css('#resources_upload_url[type="file"]')
        expect(page).to have_css('.form-text', text: 'Valid file types: jpg jpeg png')
        expect(page).to have_css('#resources_upload_data_full_title_tesim[type="text"]')
        expect(page).to have_css('textarea#resources_upload_data_spotlight_upload_description_tesim')
        expect(page).to have_css('#resources_upload_data_spotlight_upload_attribution_tesim[type="text"]')
        expect(page).to have_css('#resources_upload_data_spotlight_upload_date_tesim[type="text"]')
        expect(page).to have_css("#f0_resources_upload_data_#{custom_field.slug}[type='text']")
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

      expect(Spotlight::Resource.last.upload.image.file.path).to end_with '800x600.png'
    ensure
      Blacklight.default_index.connection.delete_by_query 'spotlight_resource_type_ssim:spotlight/resources/uploads'
      Blacklight.default_index.connection.commit
    end

    it 'creates a new item event without an attached file' do
      visit spotlight.new_exhibit_resource_path(exhibit)

      click_link 'Upload item'

      fill_in 'Title', with: 'no-image'

      within '#new_resources_upload' do
        click_button 'Add item'
      end
      expect(page).to have_content 'Object uploaded successfully.'
      expect(Spotlight::Resource.last.data['full_title_tesim']).to eq 'no-image'
    ensure
      Blacklight.default_index.connection.delete_by_query 'spotlight_resource_type_ssim:spotlight/resources/uploads'
      Blacklight.default_index.connection.commit
    end

    it 'displays the multi-item CSV upload form' do
      visit spotlight.new_exhibit_resource_path(exhibit)
      expect(page).to have_css('h1', text: /Curation/)
      expect(page).to have_css 'h1 small', text: 'Add items'

      click_link 'Upload multiple items'

      within('form#new_resources_csv_upload') do
        expect(page).to have_css('#resources_csv_upload_url[type="file"]')
        expect(page).to have_css('.form-text a', text: 'Download template')
      end
    end

    it 'does not display the raw documents upload form' do
      visit spotlight.new_exhibit_resource_path(exhibit)
      click_link 'Upload raw documents'
      expect(page).to have_no_css('form#new_resources_json_upload')
    end

    context 'as an site administrator' do
      let(:user) { FactoryBot.create(:site_admin) }

      it 'displays the JSON upload form' do
        visit spotlight.new_exhibit_resource_path(exhibit)

        click_link 'Upload raw documents'

        within('form#new_resources_json_upload') do
          expect(page).to have_css('#resources_json_upload_json[type="file"]')
        end
      end
    end
  end

  describe 'upload' do
    it 'is editable' do
      visit spotlight.new_exhibit_resource_path(exhibit)

      click_link 'Upload item'

      attach_file('resources_upload_url', File.join(FIXTURES_PATH, '800x600.png'))
      fill_in 'Title', with: '800x600'

      perform_enqueued_jobs do
        within '#new_resources_upload' do
          click_button 'Add item'
        end
      end

      Blacklight.default_index.connection.commit
      visit current_path

      click_link '800x600'
      click_link 'Edit'
      fill_in 'Title', with: 'This is a now an avatar'

      attach_file('File', File.join(FIXTURES_PATH, 'avatar.png'))

      click_button 'Save'

      expect(page).to have_content 'This is a now an avatar'
      expect(Spotlight::Resource.last.upload.image.path).to end_with 'avatar.png'
    ensure
      Blacklight.default_index.connection.delete_by_query 'spotlight_resource_type_ssim:spotlight/resources/uploads'
      Blacklight.default_index.connection.commit
    end
  end
end
