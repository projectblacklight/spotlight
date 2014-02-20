require 'spec_helper'

describe Spotlight::DashboardsController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { Spotlight::Exhibit.default }

  let!(:parent_feature_page) { 
    FactoryGirl.create(:feature_page, title: "Parent Page")
  }
  describe "when logged in" do
    let(:curator) { FactoryGirl.create(:exhibit_curator) }
    before do 
      controller.stub(find: double(docs: [{id: 1}]))
    end
    before { sign_in curator }
    describe "GET show" do
      it "should render the show view" do
        get :show, exhibit_id: exhibit.id
        expect(response).to render_template "spotlight/dashboards/show"
      end
      it "should load the exhibit" do
        get :show, exhibit_id: exhibit.id
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:pages].length).to be >= 1
        expect(assigns[:solr_documents]).to have(1).item
      end
    end
  end

  describe "when user does not have access" do
    before { sign_in FactoryGirl.create(:exhibit_visitor) }
    it "should not allow show" do
      get :show, exhibit_id: exhibit.id
      expect(response).to redirect_to main_app.root_path
    end
  end

  describe "when not logged in" do
    describe "GET show" do
      it "should redirect to the sign in form" do
        get :show, exhibit_id: exhibit.id
        expect(response).to redirect_to(main_app.new_user_session_path)
      end
      it "should set a flash alert" do
        get :show, exhibit_id: exhibit.id
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to match(/You need to sign in/)
      end
    end
  end
end

