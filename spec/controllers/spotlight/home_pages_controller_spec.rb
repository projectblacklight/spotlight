require 'spec_helper'

describe Spotlight::HomePagesController do
  routes { Spotlight::Engine.routes }
  let(:valid_attributes) { { "title" => "MyString" } }

  describe "when signed in as a curator" do
    let(:user) { FactoryGirl.create(:exhibit_curator) }
    before {sign_in user }

    describe "GET index" do
      it "should redirect to the feature pages" do
        get :index, exhibit_id: Spotlight::Exhibit.default
        expect(response).to redirect_to exhibit_feature_pages_path(Spotlight::Exhibit.default)
      end
    end
    describe "POST create" do
      it "redirects to the feature page index" do
        post :create, home_page: {title: "MyString"}, exhibit_id: Spotlight::Exhibit.default
        response.should redirect_to(exhibit_home_pages_path(Spotlight::Exhibit.default))
      end
    end
    describe "PUT update" do
      let!(:page) { FactoryGirl.create(:home_page) }
      it "redirects to the feature page index action" do
        put :update, id: page, exhibit_id: page.exhibit.id, home_page: valid_attributes
        response.should redirect_to(exhibit_home_pages_path(page.exhibit.id))
      end
    end
  end
end
