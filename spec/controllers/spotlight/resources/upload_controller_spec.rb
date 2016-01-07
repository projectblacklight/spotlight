require 'spec_helper'

describe Spotlight::Resources::UploadController, type: :controller do
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
      let(:blacklight_solr) { double }

      before do
        allow_any_instance_of(Spotlight::Resource).to receive(:reindex).and_return(true)
        allow_any_instance_of(Spotlight::Resource).to receive(:blacklight_solr).and_return blacklight_solr
      end
      it 'create a Spotlight::Resources::Upload resource' do
        expect_any_instance_of(Spotlight::Resource).to receive(:reindex_later)
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
        expect(response).to redirect_to new_exhibit_resource_path(exhibit, anchor: 'new_resources_upload')
      end
    end
  end
end
