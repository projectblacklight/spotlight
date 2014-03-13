require 'spec_helper'
describe Spotlight::AppearancesController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe "when the user is not authorized" do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    it "should deny access" do
      get :edit, exhibit_id: exhibit 
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
  end

  describe "when signed in" do
    let(:user) { FactoryGirl.create(:exhibit_admin, exhibit: exhibit) }
    before {sign_in user }

    describe "#edit" do
      it "should be successful" do
        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit)
        expect(controller).to receive(:add_breadcrumb).with("Administration", exhibit_dashboard_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with("Appearance", edit_exhibit_appearance_path(exhibit))
        get :edit, exhibit_id: exhibit
        expect(response).to be_successful
        expect(assigns[:appearance]).to be_kind_of Spotlight::Appearance
      end
    end

    describe "#update" do
      it "should update appearance fields" do
        patch :update, exhibit_id: exhibit, appearance: { 
          document_index_view_types: {"list"=>"1", "gallery"=>"1", "map"=>"0"},
          default_per_page: "50",
          thumbnail_size: "medium",
          sort_fields: {"relevance"=>"1", "title"=>"1", "type"=>"1", "date"=>"0", "source"=>"0", "identifier"=>"0"}
        }
        expect(flash[:notice]).to eq "The exhibit was saved."
        expect(response).to redirect_to edit_exhibit_appearance_path(exhibit)
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.document_index_view_types).to eq ['list', 'gallery']
          expect(saved.blacklight_configuration.default_per_page).to eq 50
          expect(saved.blacklight_configuration.thumbnail_size).to eq 'medium' 
          expect(saved.blacklight_configuration.sort_fields).to eq(
            {"score desc, sort_title_ssi asc" => {"show"=>true, "enabled"=>true},
             "sort_title_ssi asc" => {"show"=>true, "enabled"=>true},
             "sort_type_ssi asc" => {"show"=>true, "enabled"=>true}})
        end
      end
    end
  end
end
