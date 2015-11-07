require 'spec_helper'

describe Spotlight::Resources::UploadController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe 'when not logged in' do
    describe 'POST create' do
      it 'does not be allowed' do
        post :create, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a curator' do
    let(:user) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    before { sign_in user }

    describe 'GET new' do
      it 'is successful' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Curation', exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Items', admin_exhibit_catalog_index_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Add non-repository items', new_exhibit_resources_upload_path(exhibit))
        get :new, exhibit_id: exhibit
        expect(response).to be_successful
      end
    end

    describe 'POST csv_upload' do
      let(:csv) { fixture_file_upload(File.expand_path(File.join('..', 'spec', 'fixtures', 'csv-upload-fixture.csv'), Rails.root), 'text/csv') }
      let(:serialized_csv) do
        [
          {
            'url' => 'http://lorempixel.com/800/500/',
            'full_title_tesim' => 'A random image',
            'spotlight_upload_description_tesim' => 'A random 800 by 500 image from lorempixel',
            'spotlight_upload_attribution_tesim' => 'lorempixel.com',
            'spotlight_upload_date_tesim' => '2015'
          },
          {
            'url' => 'http://lorempixel.com/900/600/',
            'full_title_tesim' => 'Another random image',
            'spotlight_upload_description_tesim' => 'A random 900 by 600 image from lorempixel',
            'spotlight_upload_attribution_tesim' => 'lorempixel.com',
            'spotlight_upload_date_tesim' => '2014'
          }
        ]
      end
      before do
        request.env['HTTP_REFERER'] = 'http://test.host/'
      end
      it 'starts an AddUploadsFromCSV job with the serialized CSV' do
        expect(Spotlight::AddUploadsFromCSV).to receive(:perform_later).with(serialized_csv, exhibit, user).and_return(nil)
        post :csv_upload, exhibit_id: exhibit, resources_csv_upload: { url: csv }
      end
      it 'sets the flash message' do
        expect(Spotlight::AddUploadsFromCSV).to receive(:perform_later).and_return(nil)
        post :csv_upload, exhibit_id: exhibit, resources_csv_upload: { url: csv }
        expect(flash[:notice]).to eq "'csv-upload-fixture.csv' has been uploaded.  An email will be sent to you once indexing is complete."
      end
      it 'redirects back' do
        expect(Spotlight::AddUploadsFromCSV).to receive(:perform_later).and_return(nil)
        post :csv_upload, exhibit_id: exhibit, resources_csv_upload: { url: csv }
        expect(response).to redirect_to :back
      end
    end

    describe 'POST create' do
      let(:blacklight_solr) { double }

      before do
        allow(blacklight_solr).to receive(:commit)
        allow_any_instance_of(Spotlight::Resource).to receive(:reindex)
        allow_any_instance_of(Spotlight::Resource).to receive(:blacklight_solr).and_return blacklight_solr
      end
      it 'create a Spotlight::Resources::Upload resource' do
        expect(blacklight_solr).to receive(:commit)
        post :create, exhibit_id: exhibit, resources_upload: { url: 'url-data' }
        expect(assigns[:resource]).to be_persisted
        expect(assigns[:resource]).to be_a(Spotlight::Resources::Upload)
      end
      it 'redirects to the item admin page' do
        post :create, exhibit_id: exhibit, resources_upload: { url: 'url-data' }
        expect(flash[:notice]).to eq 'Object uploaded successfully.'
        expect(response).to redirect_to admin_exhibit_catalog_index_path(exhibit, sort: :timestamp)
      end
      it 'redirects to the upload form when the add-and-continue parameter is present' do
        post :create, exhibit_id: exhibit, 'add-and-continue' => 'true', resources_upload: { url: 'url-data' }
        expect(flash[:notice]).to eq 'Object uploaded successfully.'
        expect(response).to redirect_to new_exhibit_resources_upload_path(exhibit)
      end
    end
  end
end
