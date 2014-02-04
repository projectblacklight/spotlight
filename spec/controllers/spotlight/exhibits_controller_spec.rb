require 'spec_helper'
describe Spotlight::ExhibitsController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { Spotlight::Exhibit.default }


  describe "when the user is not authorized" do
    before do
      sign_in FactoryGirl.create(:exhibit_visitor)
    end

    it "should deny access" do
      get :edit, id: exhibit 
      expect(response).to redirect_to main_app.root_path
      expect(flash[:alert]).to be_present
    end
  end

  describe "when not logged in" do
    describe "#edit" do
      it "should not be allowed" do
        get :edit, id: exhibit 
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe "#update" do
      it "should not be allowed" do
        patch :update, id: exhibit 
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe "#update_all_pages" do
      it "should not be allowed" do
        post :update_all_pages, id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe "#edit_metadata_fields" do
      it "should not be allowed" do
        get :edit_metadata_fields, id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end

    describe "#edit_facet_fields" do
      it "should not be allowed" do
        get :edit_facet_fields, id: exhibit
        expect(response).to redirect_to main_app.new_user_session_path
      end
    end
  end

  describe "when signed in" do
    let(:user) { FactoryGirl.create(:exhibit_admin) }
    before {sign_in user }
    describe "#edit" do
      it "should be successful" do
        get :edit, id: exhibit
        expect(response).to be_successful
      end
    end

    describe "#edit_metadata_fields" do
      it "should be successful" do
        get :edit_metadata_fields, id: exhibit
        expect(response).to be_successful
      end
    end

    describe "#edit_facet_fields" do
      it "should be successful" do
        controller.stub_chain(:blacklight_solr, :get).and_return({})
        get :edit_facet_fields, id: exhibit
        expect(response).to be_successful
      end
    end

    describe "#update" do
      it "should be successful" do
        patch :update, id: exhibit, exhibit: { title: "Foo", subtitle: "Bar",
                 description: "Baz", contact_emails_attributes: {'0'=>{email: 'bess@stanford.edu'}, '1'=>{email: 'naomi@stanford.edu'}}}
        expect(flash[:notice]).to eq "The exhibit was saved."
        expect(response).to redirect_to main_app.root_path 
        assigns[:exhibit].tap do |saved|
          expect(saved.title).to eq 'Foo'
          expect(saved.subtitle).to eq 'Bar'
          expect(saved.description).to eq 'Baz'
          expect(saved.contact_emails).to eq ['bess@stanford.edu', 'naomi@stanford.edu']
        end
      end

      it "should update metadata fields" do
        exhibit.blacklight_configuration.default_blacklight_config.stub(index_fields: { 'a' => {},  'b' => {},  'c' => {}, 'd' => {},  'e' => {}, 'f' => {} })
        patch :update, id: exhibit, exhibit: { blacklight_configuration_attributes: {
          index_fields: {
            c: { enabled: true, show: true},
            d: { enabled: true, show: true},
            e: { enabled: true, list: true},
            f: { enabled: true, list: true}
          }
          }
        }

        expect(flash[:notice]).to eq "The exhibit was saved."
        expect(response).to redirect_to main_app.root_path
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.index_fields).to include 'c', 'd', 'e', 'f'
        end
      end

      it "should update facet fields" do
        patch :update, id: exhibit, exhibit: { blacklight_configuration_attributes: { facet_fields: { 'genre_sim' => { enabled: '1', label: "Label"}}  }}
        expect(flash[:notice]).to eq "The exhibit was saved."
        expect(response).to redirect_to main_app.root_path
        assigns[:exhibit].tap do |saved|
          expect(saved.blacklight_configuration.facet_fields.keys).to eq ['genre_sim']
        end
      end
    end
    describe "POST #update_all" do
      before do
        request.env["HTTP_REFERER"] = "http://example.com"
      end
      let!(:page) {FactoryGirl.create(:feature_page, title: "Feature Page Title", exhibit: exhibit)}
      let(:update_params) { {page.id => {"title" => "This is a new title!"}} }
      it "receives the pages parameter" do
       Spotlight::FeaturePage.any_instance.should_receive(:update).with({"title" => "This is a new title!"})
       post :update_all_pages, id: exhibit, pages: {feature_page: update_params}
      end
      it "should update the pages that are passed in the pages hash" do
        expect(page.title).to eq "Feature Page Title"
        post :update_all_pages, id: exhibit, pages: {feature_page: update_params}
        expect(Spotlight::FeaturePage.find(page.id).title).to eq "This is a new title!"
      end
    end
    describe "POST #update_all" do
      before do
        request.env["HTTP_REFERER"] = "http://example.com"
      end
      let!(:page) {FactoryGirl.create(:feature_page, title: "Feature Page Title", exhibit: exhibit)}
      let(:update_params) { {page.id => {"title" => "This is a new title!"}} }
      it "receives the pages parameter" do
       Spotlight::FeaturePage.any_instance.should_receive(:update).with({"title" => "This is a new title!"})
       post :update_all_pages, id: exhibit, pages: {feature_page: update_params}
      end
      it "should update the pages that are passed in the pages hash" do
        expect(page.title).to eq "Feature Page Title"
        post :update_all_pages, id: exhibit, pages: {feature_page: update_params}
        expect(Spotlight::FeaturePage.find(page.id).title).to eq "This is a new title!"
      end
    end
  end
end
