# frozen_string_literal: true

RSpec.describe 'Adding items', type: :request do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:page) { Capybara.string(response.body) }

  before { sign_in user }

  describe 'GET new' do
    context 'when signed in as an exhibit curator' do
      let(:user) { FactoryBot.create(:exhibit_curator, exhibit:) }
      let!(:custom_field) { FactoryBot.create(:custom_field, exhibit:, field_type: :vocab) }

      before { get spotlight.new_exhibit_resource_path(exhibit) }

      it 'displays the form for adding IIIF items' do
        expect(page).to have_css('h1', text: /Curation/)
        expect(page).to have_css 'h1 small', text: 'Add items'

        expect(page).to have_link('IIIF URL')
        expect(page).to have_field('resource_url', type: 'text')
        expect(page).to have_text 'Add the URL of a IIIF manifest or collection'
        expect(page).to have_button 'Add IIIF items'
      end

      it 'displays the single item upload form' do
        upload_form = page.find('form#new_resources_upload')
        expect(upload_form).to have_field('resources_upload_url', type: 'file')
        expect(upload_form).to have_css('.form-text', text: 'Valid file types: jpg jpeg png')
        expect(upload_form).to have_field('resources_upload_data_full_title_tesim', type: 'text')
        expect(upload_form).to have_field('resources_upload_data_spotlight_upload_description_tesim', type: 'textarea')
        expect(upload_form).to have_field('resources_upload_data_spotlight_upload_attribution_tesim', type: 'text')
        expect(upload_form).to have_field('resources_upload_data_spotlight_upload_date_tesim', type: 'text')
        expect(upload_form).to have_field("f0_resources_upload_data_#{custom_field.slug}", type: 'text')
      end

      it 'displays the multi-item CSV upload form, but not the raw documents upload form' do
        csv_form = page.find('form#new_resources_csv_upload')
        expect(csv_form).to have_field('resources_csv_upload_url', type: 'file')
        expect(csv_form).to have_css('.form-text a', text: 'Download template')

        expect(page).to have_no_css('form#new_resources_json_upload')
      end
    end

    context 'when signed in as a site administrator' do
      let(:user) { FactoryBot.create(:site_admin) }

      it 'displays the raw documents upload form' do
        get spotlight.new_exhibit_resource_path(exhibit)

        expect(page.find('form#new_resources_json_upload')).to have_field('resources_json_upload_json', type: 'file')
      end
    end
  end
end
