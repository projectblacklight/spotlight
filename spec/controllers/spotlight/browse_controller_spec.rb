require 'spec_helper'

describe Spotlight::BrowseController do
  before do
    Spotlight::Search.any_instance.stub(:default_featured_image)
  end
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:search) { FactoryGirl.create(:published_search, exhibit: exhibit) }
  let!(:unpublished) { FactoryGirl.create(:search, exhibit: exhibit) }

  describe "#index" do
    it "should show the list of browse categories" do
      expect(controller).to receive(:add_breadcrumb).with("Home", exhibit)
      expect(controller).to receive(:add_breadcrumb).with("Browse", exhibit_browse_index_path(exhibit))
      get :index, exhibit_id: exhibit
      expect(response).to be_successful
      expect(assigns[:searches]).to eq [search]
      expect(assigns[:searches]).to_not include unpublished
      expect(assigns[:exhibit]).to eq exhibit
      expect(response).to render_template "spotlight/browse/index"
    end
  end

  describe "#show" do
    let(:mock_response) { double }
    let(:document_list) { double }
    before do
      controller.stub(get_search_results: [mock_response, document_list])
    end
    it "should show the items in the category" do
      expect(controller).to receive(:add_breadcrumb).with("Home", exhibit)
      expect(controller).to receive(:add_breadcrumb).with("Browse", exhibit_browse_index_path(exhibit))
      expect(controller).to receive(:add_breadcrumb).with(search.title, exhibit_browse_path(exhibit, search))
      get :show, id: search, exhibit_id: exhibit
      expect(response).to be_successful
      expect(assigns[:search]).to be_a Spotlight::Search
      expect(assigns[:response]).to eq mock_response
      expect(assigns[:document_list]).to eq document_list
      expect(response).to render_template "spotlight/browse/show"
    end

  end

end
