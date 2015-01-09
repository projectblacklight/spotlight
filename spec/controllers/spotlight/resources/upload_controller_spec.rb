require 'spec_helper'

describe Spotlight::Resources::UploadController, :type => :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe "when not logged in" do

    describe "POST create" do
      it "should not be allowed" do
        post :create, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end


  describe "when signed in as a curator" do
    let(:user) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    before {sign_in user }

    describe "POST create" do

      before do
        allow_any_instance_of(Spotlight::Resource).to receive(:reindex)
      end
      it "create a Spotlight::Resources::Upload resource" do
        post :create, exhibit_id: exhibit, resources_upload: { url: "url-data" }
        expect(assigns[:resource]).to be_persisted
        expect(assigns[:resource]).to be_a(Spotlight::Resources::Upload)
      end
      it 'should redirect to the item admin page' do
        post :create, exhibit_id: exhibit, resources_upload: { url: "url-data" }
        expect(flash[:notice]).to eq 'Object uploaded successfully.'
        expect(response).to redirect_to admin_exhibit_catalog_index_path(exhibit)
      end
      it 'should redirect to the upload form when the add-and-continue parameter is present' do
        post :create, exhibit_id: exhibit, "add-and-continue" => "true", resources_upload: { url: "url-data" }
        expect(flash[:notice]).to eq 'Object uploaded successfully.'
        expect(response).to redirect_to new_exhibit_resources_upload_path(exhibit)
      end
    end
  end

end
