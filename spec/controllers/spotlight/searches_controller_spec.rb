require 'spec_helper'

describe Spotlight::SearchesController do
  routes { Spotlight::Engine.routes }

  describe "when the user is not authorized" do
    it "should show all the items" do
      expect { post :create }.to raise_error CanCan::AccessDenied
    end
  end

  describe "when the user is a curator" do
    before do
      sign_in FactoryGirl.create(:exhibit_curator)
    end

    it "should show all the items" do
      post :create, "search"=>{"title"=>"A bunch of maps"}, "f"=>{"genre_sim"=>["map"]}
      expect(response).to redirect_to main_app.catalog_index_path
      expect(flash[:notice]).to eq "Search has been saved"
      expect(assigns[:search].title).to eq "A bunch of maps"
      expect(assigns[:search].query_params).to eq("f"=>{"genre_sim"=>["map"]})
    end
  end
end

