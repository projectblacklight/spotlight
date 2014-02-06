require 'spec_helper'

describe Spotlight::BrowseController do
  routes { Spotlight::Engine.routes }
  let(:search) { FactoryGirl.create(:published_search) }
  let(:exhibit) { Spotlight::Exhibit.default }

  describe "#index" do
    it "should show the list of browse categories" do
      get :index, exhibit_id: exhibit
      expect(response).to be_successful
      expect(assigns[:searches]).to eq exhibit.searches.published
      expect(assigns[:exhibit]).to eq exhibit
      expect(response).to render_template "spotlight/browse/index"
    end
  end

  describe "#show" do
    it "should show the items in the category" do
      mock_response = double
      document_list = double
      controller.stub(get_search_results: [mock_response, document_list])
      get :show, id: search, exhibit_id: exhibit
      expect(response).to be_successful
      expect(assigns[:search]).to be_a Spotlight::Search
      expect(assigns[:response]).to eq mock_response
      expect(assigns[:document_list]).to eq document_list
      expect(response).to render_template "spotlight/browse/show"
    end

  end

end
