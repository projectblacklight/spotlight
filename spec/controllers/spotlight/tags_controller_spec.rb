require 'spec_helper'

describe Spotlight::TagsController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { Spotlight::Exhibit.default }

  describe "when not signed in" do
    describe "GET index" do
      it "should be successful" do
        get :index, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end
  describe "when signed in as a curator" do
    before {sign_in FactoryGirl.create(:exhibit_curator)} 
    describe "GET index" do
      it "should be successful" do
        get :index, exhibit_id: exhibit
        expect(response).to be_successful
        expect(assigns[:tags]).to eq []
        expect(assigns[:exhibit]).to eq exhibit
      end
    end

    describe "DELETE destroy" do
      let!(:tag) { FactoryGirl.create(:tag) }
      it "should be successful" do
        expect {
          delete :destroy, exhibit_id: exhibit, id: tag
        }.to change { ActsAsTaggableOn::Tag.count }.by(-1)
        expect(response).to redirect_to exhibit_tags_path(exhibit)
      end
    end
  end
end
