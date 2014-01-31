require 'spec_helper'

describe Spotlight::CatalogController do
  routes { Spotlight::Engine.routes }

  describe "when the user is not authorized" do
    it "should show all the items" do
      expect { get :index, exhibit_id: Spotlight::Exhibit.default }.to raise_error CanCan::AccessDenied
    end
  end

  describe "when the user is a curator" do
    before do
      sign_in FactoryGirl.create(:exhibit_curator)
    end

    it "should show all the items" do
      get :index, exhibit_id: Spotlight::Exhibit.default
      expect(response).to be_successful
      expect(assigns[:document_list]).to be_a Array
      expect(assigns[:exhibit]).to eq Spotlight::Exhibit.default
      expect(response).to render_template "spotlight/catalog/index"
    end
  end
end
