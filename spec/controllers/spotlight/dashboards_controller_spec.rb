require 'spec_helper'

describe Spotlight::DashboardsController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { Spotlight::Exhibit.default }

  describe "when logged in" do
    let(:curator) { FactoryGirl.create(:exhibit_curator) }
    before do 
      controller.stub(find: double(docs: [{id: 1}]))
    end
    before { sign_in curator }
    describe "GET show" do
      it "should load the exhibit" do
        expect(controller).to receive(:add_breadcrumb).with(exhibit.title, exhibit)
        expect(controller).to receive(:add_breadcrumb).with("Dashboard", exhibit_dashboard_path(exhibit))
        get :show, exhibit_id: exhibit.id
        expect(response).to render_template "spotlight/dashboards/show"
        expect(assigns[:exhibit]).to eq exhibit
        expect(assigns[:pages].length).to eq exhibit.pages.length
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
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to match(/You need to sign in/)
      end
    end
  end
end

