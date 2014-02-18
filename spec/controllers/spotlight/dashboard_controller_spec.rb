require 'spec_helper'

describe Spotlight::DashboardController do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { Spotlight::Exhibit.default }
  describe "when logged in" do
    let(:curator) { FactoryGirl.create(:exhibit_curator) }
    before { sign_in curator }
    describe "GET index" do
      it "should render the index view" do
        get :index, exhibit_id: exhibit.id
        expect(response).to render_template "spotlight/dashboard/index"
      end
      it "should load the exhibit" do
        get :index, exhibit_id: exhibit.id
        expect(assigns[:exhibit]).to eq exhibit
      end
    end
  end
  describe "when not logged in" do
    describe "GET index" do
      it "should redirect to the sign in form" do
        get :index, exhibit_id: exhibit.id
        expect(response).to redirect_to(main_app.new_user_session_path)
      end
      it "should set a flash alert" do
        get :index, exhibit_id: exhibit.id
        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to match(/You need to sign in/)
      end
    end
  end
end

