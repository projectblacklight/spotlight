require 'spec_helper'

describe Spotlight::CatalogController do
  routes { Spotlight::Engine.routes }

  describe "when the user is not authenticated" do

    it "should redirect to the login page" do
      get :index, exhibit_id: Spotlight::Exhibit.default
      expect(response).to redirect_to main_app.new_user_session_path
    end
    
    describe "GET edit" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should not be allowed" do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to redirect_to main_app.new_user_session_path
      end
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

    describe "GET edit" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should not be allowed" do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end
  end

  describe "when the user is a curator" do
    before do
      sign_in FactoryGirl.create(:exhibit_curator)
    end

    it "should show all the items" do
      get :admin, exhibit_id: Spotlight::Exhibit.default
      expect(response).to be_successful
      expect(assigns[:document_list]).to be_a Array
      expect(assigns[:exhibit]).to eq Spotlight::Exhibit.default
      expect(response).to render_template "spotlight/catalog/admin"
    end

    before {sign_in FactoryGirl.create(:exhibit_curator)}

    describe "GET edit" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should be successful" do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:document]).to be_kind_of SolrDocument
      end
    end
    describe "PATCH update" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should be successful" do
        patch :update, exhibit_id: exhibit, id: 'dq287tq6352', solr_document: {tag_list: 'one, two'}
        expect(response).to be_redirect
      end
    end
  end
end
