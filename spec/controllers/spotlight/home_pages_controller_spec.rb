require 'spec_helper'

describe Spotlight::HomePagesController do
  before do
    Spotlight::Search.any_instance.stub(:default_featured_image)
  end
  routes { Spotlight::Engine.routes }
  let(:valid_attributes) { { "title" => "MyString" } }
  let(:exhibit) {FactoryGirl.create(:exhibit) }
  let(:page) { exhibit.home_page }

  describe "when signed in as a curator" do
    let(:user) { FactoryGirl.create(:exhibit_curator) }
    before do
      FactoryGirl.create(:role, exhibit: exhibit, user: user)
      sign_in user
    end

    describe "GET index" do
      it "should redirect to the feature pages" do
        get :index, exhibit_id: Spotlight::ExhibitFactory.default
        expect(response).to redirect_to exhibit_feature_pages_path(Spotlight::ExhibitFactory.default)
      end
    end

    describe "GET edit" do
      describe "when the page title isn't set" do
        before do
          page.title = nil
        end

        it "should show breadcrumbs" do
          expect(controller).to receive(:add_breadcrumb).with("Home", exhibit_root_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with("Feature pages", exhibit_feature_pages_path(exhibit))
          expect(controller).to receive(:add_breadcrumb).with("Exhibit Home", [:edit, exhibit, page])
          get :edit, id: page, exhibit_id: page.exhibit 
          expect(response).to be_successful 
        end
      end
      it "should show breadcrumbs" do
        expect(controller).to receive(:add_breadcrumb).with("Home", exhibit_root_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with("Feature pages", exhibit_feature_pages_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(page.title, [:edit, exhibit, page])
        get :edit, id: page, exhibit_id: page.exhibit
        expect(response).to be_successful 
      end
    end
    describe "PUT update" do
      it "redirects to the feature page index action" do
        put :update, id: page, exhibit_id: page.exhibit.id, home_page: valid_attributes
        page.reload
        response.should redirect_to(exhibit_home_page_path(page.exhibit, page))
      end
    end
  end

  describe "Rendering home page" do
    it "should get search results for display facets" do
      expect(controller).to receive(:add_breadcrumb).with("Home", exhibit_root_path(exhibit))
      controller.stub(get_search_results: [double, double])
      get :show, exhibit_id: exhibit
      expect(assigns[:response]).to_not be_blank
      expect(assigns[:document_list]).to_not be_blank
      expect(assigns[:page]).to eq exhibit.home_page
    end
  end
end
