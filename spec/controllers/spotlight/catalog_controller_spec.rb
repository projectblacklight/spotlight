require 'spec_helper'

describe Spotlight::CatalogController do
  routes { Spotlight::Engine.routes }

  describe "when the user is not authenticated" do

    it "should redirect to the login page" do
      get :index, exhibit_id: Spotlight::Exhibit.default
      expect(response).to redirect_to main_app.new_user_session_path
    end
  end

  describe "when the user is not authorized" do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    it "should deny access" do
      get :index, exhibit_id: Spotlight::Exhibit.default
      expect(response).to redirect_to main_app.root_path
      expect(flash[:alert]).to be_present
    end
  end

  describe "when the user is a curator" do
    before do
      sign_in FactoryGirl.create(:exhibit_curator)
    end

    it "should show all the items" do
      get :index, exhibit_id: Spotlight::Exhibit.default
      expect(response).to be_successful
      expect(assigns[:document_list]).to be_a Array
      expect(assigns[:exhibit]).to eq Spotlight::Exhibit.default
      expect(response).to render_template "spotlight/catalog/index"
    end
  end
end
