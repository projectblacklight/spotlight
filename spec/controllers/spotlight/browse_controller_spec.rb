require 'spec_helper'

describe Spotlight::BrowseController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryGirl.create(:exhibit) }
  let!(:search) { FactoryGirl.create(:published_search, exhibit: exhibit) }
  let!(:unpublished) { FactoryGirl.create(:search, exhibit: exhibit) }
  let(:admin) { FactoryGirl.create(:site_admin) }

  it { is_expected.to be_a Spotlight::Catalog::AccessControlsEnforcement }

  describe 'when authenticated as an admin' do
    before { sign_in admin }
    describe 'GET index' do
      it 'does not show unpublished categories' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_browse_index_path(exhibit))
        get :index, exhibit_id: exhibit
        expect(response).to be_successful
        expect(assigns[:searches]).to eq [search]
        expect(assigns[:searches]).to_not include unpublished
        expect(assigns[:exhibit]).to eq exhibit
        expect(response).to render_template 'spotlight/browse/index'
      end
    end
  end

  describe 'when unauthenticated' do
    describe 'GET index' do
      it 'shows the list of browse categories' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_browse_index_path(exhibit))
        get :index, exhibit_id: exhibit
        expect(response).to be_successful
        expect(assigns[:searches]).to eq [search]
        expect(assigns[:searches]).to_not include unpublished
        expect(assigns[:exhibit]).to eq exhibit
        expect(response).to render_template 'spotlight/browse/index'
      end
    end

    describe 'GET show' do
      let(:mock_response) { double }
      let(:document_list) { double }
      before do
        allow(controller).to receive_messages(search_results: [mock_response, document_list])
      end
      it 'shows the items in the category' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_browse_index_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(search.title, exhibit_browse_path(exhibit, search))
        get :show, id: search, exhibit_id: exhibit
        expect(response).to be_successful
        expect(assigns[:search]).to be_a Spotlight::Search
        expect(assigns[:response]).to eq mock_response
        expect(assigns[:document_list]).to eq document_list
        expect(response).to render_template 'spotlight/browse/show'
      end

      it 'removes all the document actions' do
        get :show, id: search, exhibit_id: exhibit
        expect(controller.blacklight_config.index.document_actions).to be_blank
      end

      it 'uses the blacklight.browse configuration for the document actions' do
        config = Blacklight::Configuration.new do |c|
          c.browse.document_actions = [:a, :b, :c]
        end

        allow(controller). to receive(:blacklight_config).and_return(config)

        get :show, id: search, exhibit_id: exhibit
        expect(controller.blacklight_config.index.document_actions).to match_array [:a, :b, :c]
      end
    end
  end
end
