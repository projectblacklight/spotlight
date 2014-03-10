require 'spec_helper'

describe Spotlight::DashboardsController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }

  describe "when logged in" do
    let(:curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
    before { sign_in curator }
    describe "GET show" do
      it "should load the exhibit" do
        exhibit.blacklight_configuration.index[:timestamp_field] =  "timestamp_field"
        exhibit.save!
        expect(controller).to receive(:query_solr).with({}, hash_including(sort: "timestamp_field desc")).and_return(double(docs: [{id: 1}]))
        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit)
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
