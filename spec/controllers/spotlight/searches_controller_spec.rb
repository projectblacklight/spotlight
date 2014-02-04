require 'spec_helper'

describe Spotlight::SearchesController do
  routes { Spotlight::Engine.routes }

  describe "when the user is not authorized" do

    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    it "should raise an error" do
      post :create, exhibit_id: Spotlight::Exhibit.default
      expect(response).to redirect_to main_app.root_path
      expect(flash[:alert]).to be_present
    end

    it "should raise an error" do
      get :index, exhibit_id: Spotlight::Exhibit.default
      expect(response).to redirect_to main_app.root_path
      expect(flash[:alert]).to be_present
    end
  end

  describe "when the user is a curator" do
    before do
      sign_in FactoryGirl.create(:exhibit_curator)
    end
    let(:search) { FactoryGirl.create(:search) }

    it "should create a saved search" do
      post :create, "search"=>{"title"=>"A bunch of maps"}, "f"=>{"genre_sim"=>["map"]}, exhibit_id: Spotlight::Exhibit.default
      expect(response).to redirect_to main_app.catalog_index_path
      expect(flash[:notice]).to eq "Search has been saved"
      expect(assigns[:search].title).to eq "A bunch of maps"
      expect(assigns[:search].query_params).to eq("f"=>{"genre_sim"=>["map"]})
    end

    describe "GET index" do
      it "should show all the items" do
        get :index, exhibit_id: search.exhibit_id 
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq search.exhibit
        expect(assigns[:searches]).to include search
      end
    end

    describe "GET edit" do
      it "should show edit page" do
        get :edit, id: search
        expect(response).to be_successful
        expect(assigns[:search]).to eq search
        expect(assigns[:exhibit]).to eq search.exhibit
      end
    end

    describe "PATCH update" do
      it "should show edit page" do
        patch :update, id: search, search: {title: 'Hey man', short_description: 'short', long_description: 'long', featured_image: 'http://lorempixel.com/64/64/'}
        expect(assigns[:search].title).to eq 'Hey man'
        expect(response).to redirect_to exhibit_searches_path(search.exhibit) 
      end
    end

    describe "DELETE destroy" do
      let!(:search) { FactoryGirl.create(:search) }
      it "should remove it" do
        expect {
          delete :destroy, id: search
        }.to change { Spotlight::Search.count }.by(-1)
        expect(response).to redirect_to exhibit_searches_path(search.exhibit) 
        expect(flash[:alert]).to eq "Search was deleted"
      end
    end
  end
end

