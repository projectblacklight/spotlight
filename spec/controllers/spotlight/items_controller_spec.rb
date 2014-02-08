require 'spec_helper'

describe Spotlight::ItemsController do
  routes { Spotlight::Engine.routes }
  describe "not signed in" do
    describe "GET edit" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should not be allowed" do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end
  describe "signed in as a visitor" do
    before {sign_in FactoryGirl.create(:exhibit_visitor)}
    describe "GET show" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should be successful" do
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:document]).to be_kind_of SolrDocument
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

  describe "signed in as a curator" do
    before {sign_in FactoryGirl.create(:exhibit_curator)}
    describe "GET show" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should be successful" do
        get :show, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:document]).to be_kind_of SolrDocument
      end
    end
    describe "GET edit" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should be successful" do
        get :edit, exhibit_id: exhibit, id: 'dq287tq6352'
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:item]).to be_kind_of SolrDocument
      end
    end
    describe "PATCH update" do
      let (:exhibit) {Spotlight::Exhibit.default}
      it "should be successful" do
        patch :update, exhibit_id: exhibit, id: 'dq287tq6352', solr_document: {tag_list: 'one, two'}
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:item]).to be_kind_of SolrDocument
        expect(assigns[:document]).to be_kind_of SolrDocument
        expect(assigns[:item].tag_list).to eq ['one', 'two']
      end
    end
  end
end
