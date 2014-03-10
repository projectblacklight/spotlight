require 'spec_helper'

describe Spotlight::SearchesController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe "when the user is not authorized" do

    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    it "should raise an error" do
      post :create, exhibit_id: exhibit 
      expect(response).to redirect_to main_app.root_path
      expect(flash[:alert]).to be_present
    end

    it "should raise an error" do
      get :index, exhibit_id: exhibit
      expect(response).to redirect_to main_app.root_path
      expect(flash[:alert]).to be_present
    end
  end

  describe "when the user is a curator" do
    before do
      sign_in FactoryGirl.create(:exhibit_curator, exhibit: exhibit)
    end
    let(:search) { FactoryGirl.create(:search, exhibit: exhibit) }

    it "should create a saved search" do
      post :create, "search"=>{"title"=>"A bunch of maps"}, "f"=>{"genre_ssim"=>["map"]}, exhibit_id: exhibit 
      expect(response).to redirect_to exhibit_catalog_index_path(exhibit)
      expect(flash[:notice]).to eq "Search has been saved"
      expect(assigns[:search].title).to eq "A bunch of maps"
      expect(assigns[:search].query_params).to eq("f"=>{"genre_ssim"=>["map"]})
    end

    describe "GET index" do
      it "should show all the items" do
        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit)
        expect(controller).to receive(:add_breadcrumb).with("Curation", exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with("Browse", exhibit_searches_path(exhibit))
        get :index, exhibit_id: search.exhibit_id 
        expect(response).to be_successful
        expect(assigns[:exhibit]).to eq search.exhibit
        expect(assigns[:searches]).to include search
      end
    end

    describe "GET edit" do
      it "should show edit page" do
        get :edit, id: search, exhibit_id: search.exhibit
        expect(response).to be_successful
        expect(assigns[:search]).to eq search
        expect(assigns[:exhibit]).to eq search.exhibit
      end
    end

    describe "PATCH update" do
      it "should show edit page" do
        patch :update, id: search, exhibit_id: search.exhibit, search: {title: 'Hey man', short_description: 'short', long_description: 'long', featured_image: 'http://lorempixel.com/64/64/'}
        expect(assigns[:search].title).to eq 'Hey man'
        expect(response).to redirect_to exhibit_searches_path(search.exhibit) 
      end

      it "should render edit if there's an error" do
        Spotlight::Search.any_instance.should_receive(:update).and_return(false)
        patch :update, id: search, exhibit_id: search.exhibit, search: {title: 'Hey man', short_description: 'short', long_description: 'long', featured_image: 'http://lorempixel.com/64/64/'}
        expect(response).to be_successful 
        expect(response).to render_template 'edit'
      end
    end

    describe "DELETE destroy" do
      let!(:search) { FactoryGirl.create(:search, exhibit: exhibit) }
      it "should remove it" do
        expect {
          delete :destroy, id: search, exhibit_id: search.exhibit
        }.to change { Spotlight::Search.count }.by(-1)
        expect(response).to redirect_to exhibit_searches_path(search.exhibit) 
        expect(flash[:alert]).to eq "Search was deleted"
      end
    end

    describe "POST update_all" do
      let!(:search2) { FactoryGirl.create(:search, exhibit: exhibit, on_landing_page: true ) }
      let!(:search3) { FactoryGirl.create(:search, exhibit: exhibit, on_landing_page: true ) }
      before { request.env["HTTP_REFERER"] = "http://example.com" }
      it "should update whether they are on the landing page" do
        post :update_all, exhibit_id: exhibit, exhibit: {searches_attributes: [{id: search.id, on_landing_page: true, weight: '1' }, {id: search2.id, on_landing_page: false, weight: '0'}]}
        expect(search.reload.on_landing_page).to be_true
        expect(search.weight).to eq 1
        expect(search2.reload.on_landing_page).to be_false
        expect(search3.reload.on_landing_page).to be_true # should remain untouched since it wasn't present
        expect(response).to redirect_to "http://example.com"
        expect(flash[:notice]).to eq "Searches were successfully updated."
      end
    end
  end
end
