require 'spec_helper'
describe Spotlight::BlacklightConfigurationsController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { Spotlight::Exhibit.default }


  describe "when the user is not authorized" do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    it "should deny access" do
      get :edit_metadata_fields, exhibit_id: exhibit 
      expect(response).to redirect_to main_app.root_path
      expect(flash[:alert]).to be_present
    end
    
    it "should deny access" do
      get :edit_facet_fields, exhibit_id: exhibit 
      expect(response).to redirect_to main_app.root_path
      expect(flash[:alert]).to be_present
    end
  end

  describe "when not logged in" do
    describe "#update" do
      it "should not be allowed" do
        patch :update, exhibit_id: exhibit 
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe "#edit_metadata_fields" do
      it "should not be allowed" do
        get :edit_metadata_fields, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe "#edit_facet_fields" do
      it "should not be allowed" do
        get :edit_facet_fields, exhibit_id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe "when signed in" do
    let(:user) { FactoryGirl.create(:exhibit_admin) }
    before {sign_in user }

    describe "#edit_metadata_fields" do
      it "should be successful" do
        get :edit_metadata_fields, exhibit_id: exhibit
        expect(response).to be_successful
      end
    end

    describe "#edit_facet_fields" do
      it "should be successful" do
        controller.stub_chain(:blacklight_solr, :get).and_return({})
        get :edit_facet_fields, exhibit_id: exhibit
        expect(response).to be_successful
      end
    end

    describe "#update" do

      it "should update metadata fields" do
        ::CatalogController.stub(blacklight_config: Blacklight::Configuration.new(index_fields: { 'a' => {},  'b' => {},  'c' => {}, 'd' => {},  'e' => {}, 'f' => {} }))
        patch :update, exhibit_id: exhibit, blacklight_configuration: {
          index_fields: {
            c: { enabled: true, show: true},
            d: { enabled: true, show: true},
            e: { enabled: true, list: true},
            f: { enabled: true, list: true}
          }
        }

        expect(flash[:notice]).to eq "The exhibit was saved."
        expect(response).to redirect_to main_app.root_path
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.index_fields).to include 'c', 'd', 'e', 'f'
        end
      end

      it "should update facet fields" do
        patch :update, exhibit_id: exhibit, blacklight_configuration: { 
          facet_fields: { 'genre_ssim' => { enabled: '1', label: "Label"} }  
        }
        expect(flash[:notice]).to eq "The exhibit was saved."
        expect(response).to redirect_to main_app.root_path
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.facet_fields.keys).to eq ['genre_ssim']
        end
      end
    end
  end
end
