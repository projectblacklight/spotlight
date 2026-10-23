# frozen_string_literal: true

RSpec.describe 'Uploading a non-repository item', type: :feature do
  include ActiveJob::TestHelper

  let!(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let(:user) { exhibit_curator }

  before { login_as user }

  describe 'forms' do
    it 'creates a new item' do
      visit spotlight.new_exhibit_resource_path(exhibit)

      click_link 'Upload item'

      attach_file('resources_upload_url', File.join(FIXTURES_PATH, '800x600.png'))
      fill_in 'Title', with: '800x600'

      within '#new_resources_upload' do
        click_button 'Add item'
      end
      expect(page).to have_text 'Object uploaded successfully.'

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
      expect(page).to have_text 'Object uploaded successfully.'
      expect(Spotlight::Resource.last.data['full_title_tesim']).to eq 'no-image'
    ensure
      Blacklight.default_index.connection.delete_by_query 'spotlight_resource_type_ssim:spotlight/resources/uploads'
      Blacklight.default_index.connection.commit
    end

    context 'with multivalued upload field' do
      let(:upload_fields) do
        [
          Spotlight::UploadFieldConfig.new(
            field_name: :spotlight_upload_test_multivalued_ssim,
            label: -> { 'Multivalued Test Field' },
            is_multiple: true
          )
        ]
      end

      before do
        allow(Spotlight::Resources::Upload).to receive(:fields).with(exhibit).and_return(upload_fields)
      end

      it 'creates an item with a multivalued upload field', :js do
        visit spotlight.new_exhibit_resource_path(exhibit)

        click_link 'Upload item'

        fill_in 'Multivalued Test Field', with: 'value 1'
        click_on 'Add another'
        fill_in 'resources_upload_data_spotlight_upload_test_multivalued_ssim_2', with: 'value 2'

        within '#new_resources_upload' do
          click_button 'Add item'
        end
        expect(page).to have_text 'Object uploaded successfully.'
        expect(Spotlight::Resource.last.data['spotlight_upload_test_multivalued_ssim']).to eq ['value 1', 'value 2']
      ensure
        Blacklight.default_index.connection.delete_by_query 'spotlight_resource_type_ssim:spotlight/resources/uploads'
        Blacklight.default_index.connection.commit
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

      expect(page).to have_text 'This is a now an avatar'
      expect(Spotlight::Resource.last.upload.image.path).to end_with 'avatar.png'
    ensure
      Blacklight.default_index.connection.delete_by_query 'spotlight_resource_type_ssim:spotlight/resources/uploads'
      Blacklight.default_index.connection.commit
    end
  end
end
