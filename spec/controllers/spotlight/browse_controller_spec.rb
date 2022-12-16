# frozen_string_literal: true

describe Spotlight::BrowseController, type: :controller do
  routes { Spotlight::Engine.routes }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let!(:search) { FactoryBot.create(:published_search, exhibit: exhibit) }
  let(:group) { FactoryBot.create(:group, published: true, title: 'Good group', exhibit: exhibit, searches: [search]) }
  let(:group_unpublished) { FactoryBot.create(:group, title: 'Secret group', exhibit: exhibit, searches: [search]) }
  let!(:unpublished) { FactoryBot.create(:search, exhibit: exhibit) }
  let(:admin) { FactoryBot.create(:site_admin) }

  describe 'protected methods' do
    it 'uses the blacklight.browse configuration for the document actions when additional configuration layers are not defined' do
      expect(controller).to receive(:view_available?).and_return true
      expect(controller.send(:document_index_view_type)).to equal :gallery
    end

    it 'uses the blacklight_config view configuration when there are no params' do
      allow(controller).to receive(:current_exhibit).and_return exhibit
      expect(controller).to receive(:view_available?).and_return false
      expect(controller.send(:document_index_view_type)).to equal :list
    end

    it 'returns document_index_view_type from a search object' do
      allow(controller).to receive(:current_exhibit).and_return exhibit
      expect(controller).to receive(:view_available?).and_return true
      search.default_index_view_type = 'gallery'
      controller.instance_variable_set(:@search, search)
      expect(controller.send(:default_document_index_view_type)).to equal :gallery
    end

    it 'returns default_document_index_view_type from super when there is no view available' do
      allow(controller).to receive(:current_exhibit).and_return exhibit
      expect(controller).to receive(:view_available?).and_return false
      expect(controller.send(:default_document_index_view_type)).to equal :list
    end

    it 'returns the default_browse_index_view_type from exhibit configuration' do
      allow(controller).to receive(:current_exhibit).and_return exhibit
      expect(controller.send(:default_browse_index_view_type)).to equal :gallery
    end
  end

  describe 'when authenticated as an admin' do
    before { sign_in admin }

    describe 'GET index' do
      it 'does not show unpublished categories' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_browse_index_path(exhibit))
        get :index, params: { exhibit_id: exhibit }
        expect(response).to be_successful
        expect(assigns[:searches]).to eq [search]
        expect(assigns[:searches]).not_to include unpublished
        expect(assigns[:exhibit]).to eq exhibit
        expect(response).to render_template 'spotlight/browse/index'
      end

      it 'includes the browse groups' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_browse_index_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Good group', exhibit_browse_groups_path(exhibit, group))
        get :index, params: { exhibit_id: exhibit, group_id: group.id }
        expect(response).to be_successful
        expect(assigns[:groups]).to eq [group]
        expect(response).to render_template 'spotlight/browse/index'
      end
    end
  end

  describe 'when unauthenticated' do
    describe 'GET index' do
      it 'shows the list of browse categories' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_browse_index_path(exhibit))
        get :index, params: { exhibit_id: exhibit }
        expect(response).to be_successful
        expect(assigns[:searches]).to eq [search]
        expect(assigns[:searches]).not_to include unpublished
        expect(assigns[:exhibit]).to eq exhibit
        expect(response).to render_template 'spotlight/browse/index'
      end
    end

    describe 'GET show' do
      let(:mock_response) { double documents: document_list, aggregations: {} }
      let(:document_list) { double }

      before do
        allow(controller).to receive_messages(search_service: double(search_results: [mock_response, document_list]))
      end

      it 'shows the items in the category' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_browse_index_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with(search.title, exhibit_browse_path(exhibit, search))
        get :show, params: { id: search, exhibit_id: exhibit }
        expect(response).to be_successful
        expect(assigns[:search]).to be_a Spotlight::Search
        expect(assigns[:response]).to eq mock_response
        expect(response).to render_template 'spotlight/browse/show'
      end

      it 'includes the browse group when a group_id is provided' do
        expect(controller).to receive(:add_breadcrumb).with('Home', exhibit)
        expect(controller).to receive(:add_breadcrumb).with('Browse', exhibit_browse_index_path(exhibit))
        expect(controller).to receive(:add_breadcrumb).with('Good group', exhibit_browse_groups_path(exhibit, group))
        expect(controller).to receive(:add_breadcrumb).with(search.title, exhibit_browse_group_path(exhibit, group, search))
        get :show, params: { id: search, exhibit_id: exhibit, group_id: group.id }
        expect(response).to be_successful
        expect(assigns[:group]).to eq group
        expect(response).to render_template 'spotlight/browse/show'
      end

      it 'removes all the document actions' do
        get :show, params: { id: search, exhibit_id: exhibit }
        expect(controller.blacklight_config.index.document_actions).to be_blank
      end

      it 'uses the blacklight.browse configuration for the document actions' do
        config = Blacklight::Configuration.new do |c|
          c.browse.document_actions = %i[a b c]
        end

        allow(controller).to receive(:blacklight_config).and_return(config)

        get :show, params: { id: search, exhibit_id: exhibit }
        expect(controller.blacklight_config.index.document_actions).to match_array %i[a b c]
      end
    end
  end
end
