require 'spec_helper'

describe Spotlight::SearchesController do
  routes { Spotlight::Engine.routes }

  describe "when the user is not authorized" do
    it "should raise an error" do
      expect { post :create, exhibit_id: Spotlight::Exhibit.default }.to raise_error CanCan::AccessDenied
    end

    it "should raise an error" do
      expect { get :index, exhibit_id: Spotlight::Exhibit.default }.to raise_error CanCan::AccessDenied
    end
  end

  describe "when the user is a curator" do
    before do
      sign_in FactoryGirl.create(:exhibit_curator)
    end

    it "should create a saved search" do
      post :create, "search"=>{"title"=>"A bunch of maps"}, "f"=>{"genre_sim"=>["map"]}, exhibit_id: Spotlight::Exhibit.default
      expect(response).to redirect_to main_app.catalog_index_path
      expect(flash[:notice]).to eq "Search has been saved"
      expect(assigns[:search].title).to eq "A bunch of maps"
      expect(assigns[:search].query_params).to eq("f"=>{"genre_sim"=>["map"]})
    end

    describe "GET index" do
      it "should show all the items" do
      search = FactoryGirl.create(:search)
        get :index, exhibit_id: search.exhibit_id 
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq search.exhibit
        # puts "Sea: #{search.exhibit.searches.to_a}"
        # puts "assigned #{assigns[:searches].to_a}"
        expect(assigns[:searches]).to include search
      end
    end
  end
end

