require 'spec_helper'

describe Spotlight::Resources::CsvUploadController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe 'when not logged in' do
    describe 'POST create' do
      it 'is not allowed' do
        post :create, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe 'when signed in as a curator' do
    let(:user) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    before { sign_in user }

    describe 'POST create' do
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
        post :create, exhibit_id: exhibit, resources_csv_upload: { url: csv }
      end
      it 'sets the flash message' do
        expect(Spotlight::AddUploadsFromCSV).to receive(:perform_later).and_return(nil)
        post :create, exhibit_id: exhibit, resources_csv_upload: { url: csv }
        expect(flash[:notice]).to eq "'csv-upload-fixture.csv' has been uploaded.  An email will be sent to you once indexing is complete."
      end
      it 'redirects back' do
        expect(Spotlight::AddUploadsFromCSV).to receive(:perform_later).and_return(nil)
        post :create, exhibit_id: exhibit, resources_csv_upload: { url: csv }
        expect(response).to redirect_to :back
      end
    end
  end
end
