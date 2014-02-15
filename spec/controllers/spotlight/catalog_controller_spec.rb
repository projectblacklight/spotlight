require 'spec_helper'

describe Spotlight::CatalogController do
  routes { Spotlight::Engine.routes }

  describe "when the user is not authenticated" do

    describe "GET admin" do
      it "should redirect to the login page" do
        get :admin, exhibit_id: Spotlight::Exhibit.default
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
    
    describe "GET edit" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should not be allowed" do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe "GET show" do
      let (:exhibit) {Spotlight::Exhibit.default}
      let (:document) { SolrDocument.find('dq287tq6352') }
      it "should show the item" do
        expect(controller).to receive(:add_breadcrumb).with(exhibit.title, exhibit)
        expect(controller).to receive(:add_breadcrumb).with("L'AMERIQUE", document)
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
      end
    end

    describe "GET index" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should show the item" do
        expect(controller).to receive(:add_breadcrumb).with(exhibit.title, exhibit)
        expect(controller).to receive(:add_breadcrumb).with("Search Results", exhibit_catalog_index_path(exhibit))
        get :index, exhibit_id: exhibit, q: 'map'
        expect(response).to be_successful
      end
    end
  end

  describe "when the user is not authorized" do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    describe "GET admin" do
      it "should deny access" do
        get :admin, exhibit_id: Spotlight::Exhibit.default
        expect(response).to redirect_to main_app.root_path
        expect(flash[:alert]).to be_present
      end
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
