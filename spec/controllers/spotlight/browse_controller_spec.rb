require 'spec_helper'

describe Spotlight::BrowseController do
  routes { Spotlight::Engine.routes }
  let(:search) { FactoryGirl.create(:search) }

  describe "#index" do
    it "should show the list of browse categories" do
      get :index, exhibit_id: Spotlight::Exhibit.default
      expect(response).to be_successful
      expect(assigns[:searches]).to be_a Array
      expect(assigns[:exhibit]).to eq Spotlight::Exhibit.default
      expect(response).to render_template "spotlight/browse/index"
    end
  end

  describe "#show" do
    it "should show the items in the category" do
      get :index, id: search, exhibit_id: Spotlight::Exhibit.default
      expect(response).to be_successful
      expect(assigns[:browse]).to be_a Spotlight::Search
      expect(assigns[:document_list]).to be_a Array
      expect(assigns[:response]).to be_a Blacklight::SolrResponse
      expect(assigns[:exhibit]).to eq Spotlight::Exhibit.default
      expect(response).to render_template "spotlight/browse/show"
    end

  end

end
